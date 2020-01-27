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

BASE_DIR = os.getcwd()


def log_subprocess_output(pipe, logger=None):
    for line in iter(pipe.readline, b''): # b'\n'-separated lines
        logger.info('%r', line.decode('utf-8'))


def check_abort_state(task_id, proc):
    result = AbortableAsyncResult(task_id)
    if result.is_aborted() or result.state == 'REVOKED':
        logger = get_task_logger(task_id)
        # respect aborted state, and terminate gracefully.
        logger.warning('Task aborted')
        proc.kill()


def call_repeatedly(secs, func, task_id, proc):
    while proc.poll() is None:
        print(f'inside call_repeatedly for {task_id}')
        logger = get_task_logger(task_id)
        logger.info(f'inside call_repeatedly for {task_id}')
        time.sleep(secs)
        func(task_id, proc)
    return True


@app.task
def cleanup_expired_results():
    """ """
    expired = timezone.now() - timedelta(days=7)  # objects older than 7 days will be deleted
    print(f'Deleting expired jobs. All jobs before {expired} will be deleted now.')
    jobs = Job.objects.filter(start_date__lt=expired, is_finished=True)
    for job in jobs:
        shutil.rmtree(os.path.dirname(job.sbml_file.path), ignore_errors=True)
    jobs.delete()


# Celery app scheduler
app.conf.beat_schedule = {
    'cleanup': {
        'task': 'jobs.tasks.cleanup_expired_results',
        'schedule': 3600  # once a day
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


@shared_task(bind=True, name="SBML_processing")
def sbml_processing(self, job_id=None, *args, **kwargs):
    """ """
    import cobra
    from cobra.flux_analysis.variability import find_blocked_reactions
    # import cobra.manipulation

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=None, *args, **kwargs)

    logger.info(f'Trying load SBML model {fname} in directory {path}')

    if extension == '.json':
        m = cobra.io.load_json_model(fpath)
    elif extension == '.xml' or extension == '.sbml':
        m = cobra.io.read_sbml_model(fpath)
    else:
        logger.error(f'ERROR: input file ({fname}) missing matching extension (.json/.xml/.sbml)')
        raise Exception(f'ERROR: input file ({fname}) missing matching extension (.json/.xml/.sbml)')
    logger.info('Successfully loaded model.')

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
def compress_network(self, result, job_id, *args, **kwargs):
    """ """

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    # change WD to folder containing the model and files etc. (upload folder)
    os.chdir(path)

    # call the script process
    cmd_args = [os.path.join(BASE_DIR, 'scripts/compress_network.pl'),
                                         '-s', f'{model_name}.sfile',
                                         '-m', f'{model_name}.mfile',
                                         '-r', f'{model_name}.rfile',
                                         '-v', f'{model_name}.rvfile',
                                         '-n', f'{model_name}.nfile',
                                         '-p', 'chg_proto.txt',
                                         '-o', '_comp',
                                         '-l',
                                         '-k',
                                         ]
    logger.info(f'Starting network compression script with the following arguments: {" ".join(cmd_args)}')
    try:
        compress_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        with compress_process.stdout:
            log_subprocess_output(compress_process.stdout, logger=logger)
        print(f'poll = {compress_process.poll()}')
        compress_network.cancel_future_calls = call_repeatedly(5, check_abort_state, self.request.id, compress_process)

        compress_process.wait()

    except Exception as e:
        logger.error(repr(e))
        raise e

    # write/copy growth reaction
    copyfile(os.path.join(path, f'{model_name}.nfile'), os.path.join(path, f'{model_name}.tfile_comp'))

    os.chdir(BASE_DIR)
    return compress_process.returncode


@shared_task(bind=True, name="create_dual_system")
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
            if type != "t":
                f.write(f'{model_name}.{type}file_comp,')
            else:
                f.write(f'{model_name}.{type}file_comp')
    f.close()

    cmd_args = [os.path.join(BASE_DIR, 'scripts/create_ccds_files.pl'),
                                         '-c', f'{model_name}.inp',
                                         '-o', f'{model_name}_comp'
                ]

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
    return create_dual_system_process.returncode


@shared_task(bind=True, name="defigueiredo", base=AbortableTask)
def defigueiredo(self, result, job_id, *args, **kwargs):
    """ """

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    # cardinality - set as parameter?
    dm = 2
    # threads - parameter?
    t = 10

    logger.info(f'Getting MCS: using up to d={dm} and t={t} thread(s)')
    os.chdir(path)
    cmd_args = [os.path.join(BASE_DIR, 'bin/defigueiredo'),
                                         '-m', f'{model_name}_comp_dual.mfile',
                                         '-r', f'{model_name}_comp_dual.rfile',
                                         '-s', f'{model_name}_comp_dual.sfile',
                                         '-v', f'{model_name}_comp_dual.vfile',
                                         '-c', f'{model_name}_comp_dual.cfile',
                                         '-x', f'{model_name}_comp_dual.xfile',
                                         '-o', f'{model_name}.mcs.comp',
                                         '-t', f'{t}',
                                         '-u', f'{dm}',
                                         # '-l',
                                         '-p',
                                         '-i'
                ]
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
    #     raise subprocess.CalledProcessError(defigueiredo_process.returncode, cmd=)

    return defigueiredo_process.returncode


@shared_task(bind=True, name="mcs_to_binary")
def mcs_to_binary(self, result, job_id, *args, **kwargs):
    """ """
    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    os.chdir(path)
    logger.info(f'Transforming compressed MCS to binary representation')
    mcs_fname = f'{model_name}.mcs.comp'
    rxns_fname = f'{model_name}.rfile_comp'
    output_file = f'{model_name}.mcs.comp.binary'

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
def pofcalc(self, result, job_id, *args, **kwargs):
    """ """
    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    os.chdir(path)
    d = 3  # TODO parameterize
    t = 10

    logger.info(f'Transforming compressed MCS to binary representation')
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

    logger.info(f'Calculating PoF up to d={d}')

    cmd_args = [os.path.join(BASE_DIR, 'bin/PoFcalc'),
                                         '-m', f'{model_name}.mcs.comp.binary',
                                         '-c', f'{model_name}.num_comp_rxns',
                                         '-r', f'{nr_words}',
                                         # '-o', f'{model_name}.mcs.comp',
                                         '-d', f'{d}',
                                         '-t', f'{t}'
                ]
    # Start the process
    try:
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

        pofcalc_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        with pofcalc_process.stdout:
            log_subprocess_output(pofcalc_process.stdout, logger=logger)
        pofcalc_process.wait()
        logger.info(f'Finished!')
    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)
    return pofcalc_process.returncode
