from __future__ import absolute_import, unicode_literals
from celery import shared_task
from .models import Job, SubTask
from RobustQ.celery import app
# from multiprocessing import Pool
from billiard.pool import Pool
from multiprocessing import cpu_count
import time
import random
from django.utils import timezone
from datetime import timedelta
import subprocess
from celery.utils.log import get_task_logger
import sys
import os
from shutil import copyfile
import logging
import numpy as np
from django.core.cache import cache
import shutil
from celery.schedules import crontab
from celery.contrib.abortable import AbortableTask, AbortableAsyncResult
from celery.result import AsyncResult
import threading
from .custom_wraps import revoke_chain_authority, RevokeChainRequested
from django.conf import settings
import io
from django.core.mail import send_mail

BASE_DIR = os.getcwd()


def log_subprocess_output(pipe, logger=None):
    formatter_new = logging.Formatter('[%(asctime)s] %(message)s')
    # change logger format temporarily while reading stdout - dirty solution?
    for loggr in logger.handlers:
        loggr.setFormatter(formatter_new)
    for line in iter(pipe.readline, b''): # b'\n'-separated lines
        logger.info('%s', line.decode('utf-8').strip().strip('\"').replace(r'\n', '\n'))
    # return back to normal formatting
    for loggr in logger.handlers:
        loggr.setFormatter(logging.Formatter('[%(asctime)s][%(levelname)s] %(message)s'))


def check_abort_state(task_id, proc, logger):
    result = AbortableAsyncResult(task_id)
    if result.is_aborted() or result.state == 'REVOKED':
        # respect aborted state, and terminate gracefully
        logger.warning('Task aborted')
        proc.kill()
        logger.warning('Task killed')
        raise ChildProcessError(f'Task with PID {proc.pid} aborted by user')


def call_repeatedly(secs, func, task_id, proc, logger):
    while proc.poll() is None:
        time.sleep(secs)
        func(task_id, proc, logger)


@app.task(ignore_result=True)
def cleanup_expired_results():
    """ """
    # objects older than x (default 14) days will be deleted
    expired = timezone.now() - timedelta(days=settings.DAYS_UNTIL_JOB_DELETE)
    print(f'Deleting expired jobs. All jobs before {expired} will be deleted now.')
    jobs = Job.objects.filter(start_date__lt=expired, is_finished=True)
    for job in jobs:
        shutil.rmtree(os.path.dirname(job.sbml_file.path), ignore_errors=True)
    jobs.delete()
    # TODO delete taskresults?


# Celery app scheduler
app.conf.beat_schedule = {
    'cleanup': {
        'task': 'jobs.tasks.cleanup_expired_results',
        'schedule': 3600
    }
}


def setup_process(self, result, job_id, *args, **kwargs):
    """ Basic setup for most tasks. Configures task based logger and filepath variables """

    cache.set("current_task", self.request.id, timeout=None)
    # Logging
    logger = get_task_logger(self.request.id)
    app.log.redirect_stdouts_to_logger(logger, loglevel=logging.INFO)
    logger.info(f'Result/returncode of previous task was {result}')
    logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}. Job ID = {job_id}')

    # Filepath extractions
    fpath = Job.objects.get(id=job_id).sbml_file.path
    path = os.path.dirname(fpath)
    fname = os.path.basename(fpath)
    model_name, extension = os.path.splitext(fname)

    return logger, fpath, path, fname, model_name, extension


@shared_task(bind=True)
def update_db_post_run(self, result=None, job_id=None, *args, **kwargs):
    job = Job.objects.filter(id=job_id)
    job.update(is_finished=True, finished_date=timezone.now(), status="Done", result=result)


@shared_task(bind=True)
def email_when_finished(self, result=None, job_id=None, *args, **kwargs):
    job = Job.objects.get(id=job_id)
    hours, remainder = divmod((job.finished_date - job.start_date).total_seconds(), 3600)
    minutes, seconds = divmod(remainder, 60)
    duration = '{:02}:{:02}:{:02}'.format(int(hours), int(minutes), int(seconds))
    print(f'Trying to send email to {job.user.email}')
    message = f'Dear {job.user}, \n\n your RobustQ job has just finished (total time: {duration}). The task finished ' \
              f'with result {job.result} and status {job.status}. \nThank you for using our service.'
    try:
        send_mail(
            'Your RobustQ job has finished',
            'robustq.info@gmail.com',
            message,
            [job.user.email]
        )
    except Exception as e:
        print('Failed to send email: ', repr(e))


@shared_task(bind=True, name="SBML_processing")
def sbml_processing(self, job_id=None, *args, **kwargs):
    """ """
    import cobra
    from cobra.flux_analysis.variability import find_blocked_reactions
    # import cobra.manipulation

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=None, *args, **kwargs)

    #  Set start date to now
    Job.objects.filter(id=job_id).update(start_date=timezone.now())

    logger.info(f'Trying to load SBML model {fname} in directory {path}')

    if extension == '.json':
        m = cobra.io.load_json_model(fpath)
    elif extension == '.xml' or extension == '.sbml':
        m = cobra.io.read_sbml_model(fpath)
    else:
        logger.error(f'ERROR: input file ({fname}) missing matching extension (.json/.xml/.sbml)')
        raise Exception(f'ERROR: input file ({fname}) missing matching extension (.json/.xml/.sbml)')
    logger.info('Successfully loaded model.')

    reactions = len(m.reactions)
    metabolites = len(m.metabolites)
    genes = len(m.genes)

    # Make model consistent - commented out for testing
    # fba_orig = m.slim_optimize()
    # rxns_orig = len(m.reactions)
    # mets_orig = len(m.metabolites)
    # tol_orig = m.tolerance
    #
    # m.remove_reactions(find_blocked_reactions(m))
    # # TODO look for possible fix for Pool issue
    # m, _ = cobra.manipulation.delete.prune_unused_metabolites(m)
    #
    # fba_cons = m.slim_optimize()
    # rxns_cons = len(m.reactions)
    # mets_cons = len(m.metabolites)
    #
    # if abs(fba_orig - fba_cons) > (fba_orig * tol_orig):
    #     logger.error(f'{fname}: difference in FBA objective is too large')
    #     raise Exception(f'ERROR: {fname}: difference in FBA objective is too large')
    #
    # logger.info(f'{model_name}:\n{rxns_orig} rxns, {mets_orig} mets, obj: {fba_orig} '
    #             f'--> {rxns_cons} rxns, {mets_cons} mets, obj: {fba_cons}\n')

    # Get Biomass reaction
    # bm_rxn = m.objective.expression  # doesnt return pure id
    bm_rxn = list(cobra.util.solver.linear_reaction_coefficients(m))[0].id
    logger.info(f'Biomass reaction was found to be {bm_rxn}')

    job = Job.objects.filter(id=job_id)
    job.update(reactions=reactions, metabolites=metabolites, genes=genes, objective_expression=bm_rxn)

    # Extract info from model and write to respective files
    try:
        # write sfile - stoichiometric matrix
        np.savetxt(os.path.join(path, f'{model_name}.sfile'),
                   cobra.util.array.create_stoichiometric_matrix(m),
                   delimiter='\t', fmt='%g')
        logger.info(f'Created {model_name}.sfile')

        # write mfile - metabolites
        with open(os.path.join(path, f'{model_name}.mfile'), 'w') as f:
            f.write(' '.join([met.id for met in m.metabolites]))
        f.close()
        logger.info(f'Created {model_name}.mfile')

        # write rfile - reactions
        with open(os.path.join(path, f'{model_name}.rfile'), 'w') as f:
            f.write(' '.join([rxn.id for rxn in m.reactions]))
        f.close()
        logger.info(f'Created {model_name}.rfile')

        # write rvfile - reversible reactions
        with open(os.path.join(path, f'{model_name}.rvfile'), 'w') as f:
            f.write(' '.join(['1' if rxn.reversibility \
                                  else '0' for rxn in m.reactions]))
        f.close()
        logger.info(f'Created {model_name}.rvfile')

        # write nfile - biomass reaction
        with open(os.path.join(path, f'{model_name}.nfile'), 'w') as f:
            f.write(bm_rxn)
        f.close()
        logger.info(f'Created {model_name}.nfile')

    except Exception as e:
        logger.error(repr(e))
        raise e

    # return biomass reaction for next task
    return bm_rxn


@shared_task(bind=True, name="compress_network", base=AbortableTask)
@revoke_chain_authority
def compress_network(self, result, job_id, *args, **kwargs):
    """ """

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)
    # change WD to folder containing the model and files etc. (upload folder)
    os.chdir(path)

    if not kwargs['do_compress']:
        logger.info('Compression set to False, skipping compression')
        return

    # call the script process
    cmd_args = [os.path.join(BASE_DIR, 'scripts/compress_network.pl'),
                                         '-s', f'{model_name}.sfile',
                                         '-m', f'{model_name}.mfile',
                                         '-r', f'{model_name}.rfile',
                                         '-v', f'{model_name}.rvfile',
                                         # '-n', f'{model_name}.nfile',
                                         '-i', f'{model_name}.nfile',
                                         '-p', 'chg_proto.txt',
                                         '-o', '_comp',
                                         '-l',
                                         '-k',
                                         ]
    logger.info(f'Starting network compression script with the following arguments: {" ".join(cmd_args)}')

    if settings.DEBUG:
        subtask = SubTask.objects.filter(task_id=self.request.id)
        subtask.update(command_arguments=" ".join(cmd_args))

    try:
        compress_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        cache.set("running_task_pid", compress_process.pid)
        threading.Thread(target=call_repeatedly, args=(3, check_abort_state, self.request.id, compress_process,
                                                       logger)).start()

        with compress_process.stdout:
            log_subprocess_output(compress_process.stdout, logger=logger)

        compress_process.wait()

    except Exception as e:
        logger.error(repr(e))
        raise e

    # write/copy growth reaction
    copyfile(os.path.join(path, f'{model_name}.nfile'), os.path.join(path, f'{model_name}.tfile_comp'))

    os.chdir(BASE_DIR)

    if compress_process.returncode:
        raise RevokeChainRequested(f'Process {self.name} had non-zero exit status')

    return compress_process.returncode


@shared_task(bind=True, name="create_dual_system")
@revoke_chain_authority
def create_dual_system(self, result, job_id, *args, **kwargs):
    """ """

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    # change WD to folder containing the model and files etc. (upload folder)
    os.chdir(path)

    # write inputs to file
    filetypes = ['r', 'm', 's', 'rv', 't']
    with open(os.path.join(path, f'{model_name}.inp'), 'w') as f:
        for type in filetypes:
            if kwargs['do_compress']:
                if type != "t":
                    f.write(f'{model_name}.{type}file_comp,')
                else:
                    f.write(f'{model_name}.{type}file_comp')
            else:  # if we don't compress the network
                if type != "t":
                    f.write(f'{model_name}.{type}file,')
                else:
                    f.write(f'{model_name}.{type}file')
                    copyfile(os.path.join(path, f'{model_name}.nfile'), os.path.join(path, f'{model_name}.tfile'))

    f.close()
    comp_suffix = 'comp' if kwargs['do_compress'] else 'uncomp'

    cmd_args = [os.path.join(BASE_DIR, 'scripts/create_ccds_files.pl'),
                                         '-c', f'{model_name}.inp',
                                         '-o', f'{model_name}_{comp_suffix}'
                ]

    if settings.DEBUG:
        subtask = SubTask.objects.filter(task_id=self.request.id)
        subtask.update(command_arguments=" ".join(cmd_args))

    # Start the process
    try:
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

        create_dual_system_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        with create_dual_system_process.stdout:
            log_subprocess_output(create_dual_system_process.stdout, logger=logger)
        create_dual_system_process.wait()

    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)

    if create_dual_system_process.returncode:
        raise RevokeChainRequested(f'Process {self.name} had non-zero exit status')

    return create_dual_system_process.returncode


@shared_task(bind=True, name="defigueiredo", base=AbortableTask)
@revoke_chain_authority
def defigueiredo(self, result, job_id, cardinality, *args, **kwargs):
    """ """

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    dm = cardinality
    # threads - parameter?
    t = 10
    comp_suffix = 'comp' if kwargs['do_compress'] else 'uncomp'

    logger.info(f'Getting MCS: using up to d={dm} and t={t} thread(s)')
    os.chdir(path)
    cmd_args = [os.path.join(BASE_DIR, 'bin/defigueiredo'),
                                         '-m', f'{model_name}_{comp_suffix}_dual.mfile',
                                         '-r', f'{model_name}_{comp_suffix}_dual.rfile',
                                         '-s', f'{model_name}_{comp_suffix}_dual.sfile',
                                         '-v', f'{model_name}_{comp_suffix}_dual.vfile',
                                         '-c', f'{model_name}_{comp_suffix}_dual.cfile',
                                         '-x', f'{model_name}_{comp_suffix}_dual.xfile',
                                         '-o', f'{model_name}.mcs.{comp_suffix}',
                                         '-t', f'{t}',
                                         '-u', f'{dm}',
                                         # '-l',
                                         '-p',
                                         '-i'
                ]

    if settings.DEBUG:
        subtask = SubTask.objects.filter(task_id=self.request.id)
        subtask.update(command_arguments=" ".join(cmd_args))

    # Start the process
    try:
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

        defigueiredo_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        with defigueiredo_process.stdout:
            log_subprocess_output(defigueiredo_process.stdout, logger=logger)
            if self.is_aborted():
                # respect aborted state, and terminate gracefully.
                logger.warning('Task aborted')
                defigueiredo_process.kill()

        defigueiredo_process.wait()

    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)

    # if defigueiredo_process.returncode:
    #     raise RevokeChainRequested(f'Process {self.name} had non-zero exit status')

    return defigueiredo_process.returncode


@shared_task(bind=True, name="mcs_to_binary")
def mcs_to_binary(self, result, job_id, *args, **kwargs):
    """ """
    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    os.chdir(path)
    comp_suffix = 'comp' if kwargs['do_compress'] else 'uncomp'

    logger.info(f'Transforming MCS to binary representation')
    mcs_fname = f'{model_name}.mcs.{comp_suffix}'
    rxns_fname = f'{model_name}.rfile_comp' if kwargs['do_compress'] else f'{model_name}.rfile'
    output_file = f'{model_name}.mcs.{comp_suffix}.binary'

    try:
        with open(os.path.join(path, rxns_fname), 'r') as f:
            rxns = f.read().strip().split()
            rxns = [r.replace('"', '') for r in rxns]
        f.close()

        with open(os.path.join(path, mcs_fname), 'r') as mcsfile, \
                open(os.path.join(path, output_file), 'w') as outfile:
            for line in mcsfile:
                arr = ['0'] * len(rxns)
                sep = ' ' if ' ' in line else ','
                mcs = line.strip().split(sep)
                for rxn in mcs:
                    arr[rxns.index(rxn)] = '1'
                outfile.write(''.join(arr) + '\n')
        outfile.close()
        logger.info(f'Successfully read {mcs_fname} and {rxns_fname} and wrote output to {output_file}')

    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)


@shared_task(bind=True, name="PoFcalc", base=AbortableTask)
@revoke_chain_authority
def pofcalc(self, result, job_id, cardinality, *args, **kwargs):
    """ """
    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    os.chdir(path)
    d = cardinality
    t = 10
    comp_suffix = 'comp' if kwargs['do_compress'] else 'uncomp'

    logger.info(f'Calculating PoF up to d={d}')

    cmd_args = [os.path.join(BASE_DIR, 'bin/PoFcalc'),
                                         '-m', f'{model_name}.mcs.{comp_suffix}.binary',
                                         # '-o', f'{model_name}.mcs.comp',
                                         '-d', f'{d}',
                                         '-t', f'{t}'
                ]

    if kwargs['do_compress']:
        # count number of reactions after compression
        infile = f'{model_name}.rfile_comp'

        outfile = f'{model_name}.num_comp_rxns'

        rxn = np.genfromtxt(os.path.join(path, infile), dtype=str)
        rxn_cnt = np.char.count(rxn, '%') + 1

        np.savetxt(os.path.join(path, outfile), rxn_cnt.reshape(1, -1), fmt='%g', delimiter=' ')

        # wordcounter
        nr_words = 0
        with open(f'{model_name}.rfile', 'r') as f:
            for line in f:
                nr_words += len(line.split())

        # additional compression arguments for PoF calculation
        cmd_args += ['-c', f'{model_name}.num_{comp_suffix}_rxns',
                     '-r', f'{nr_words}']

    if settings.DEBUG:
        subtask = SubTask.objects.filter(task_id=self.request.id)
        subtask.update(command_arguments=" ".join(cmd_args))

    # Start the process
    try:
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

        pofcalc_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        out, err = pofcalc_process.communicate()
        out = out.decode('utf-8').strip().strip('\"').replace(r'\n', '\n')
        logger.info(out)
        if err:
            logger.error(err)
            raise Exception(err)

        if 'Final PoF' in out.splitlines()[-1]:
            # gets the result from the process output
            try:
                pof_result = round(float(out.splitlines()[-1].split()[-1]), 4)
            except ValueError:
                pof_result = out.splitlines()[-1].split()[-1]
            job = Job.objects.filter(id=job_id)
            job.update(result=pof_result)  # stores the string of the result

        pofcalc_process.wait()
        logger.info(f'Finished!')
    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)

    if pofcalc_process.returncode:
        raise RevokeChainRequested(f'Process {self.name} had non-zero exit status')
    else:
        return float(pof_result) if pof_result else pofcalc_process.returncode

