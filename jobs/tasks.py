from __future__ import absolute_import, unicode_literals
from celery import shared_task
from .models import Job, SubTask
from RobustQ.celery import app
import time
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
from celery import chain
from celery.contrib.abortable import AbortableTask, AbortableAsyncResult
import threading
from .custom_wraps import revoke_chain_authority, ExecutionAbortedError, test
from django.conf import settings
from django.core.mail import send_mail
import signal
from celery.exceptions import SoftTimeLimitExceeded
import pandas as pd


# TODO styling (also all browsers), production ready, task timeout limits (exc pipeline finishes before pofcalc)
# TODO start writing
# TODO figure out pipeline stuff
# TODO about/help page, footer etc.
# TODO split this file up - pipeline tasks and this
# TODO - No such file or directory tmp file error

BASE_DIR = os.getcwd()


def revoke_job(job):
    # terminate the running and all subsequent tasks of the job
    task_id_job = job.task_id_job
    if not task_id_job:
        # something went wrong
        Job.objects.filter(id=job.id).update(status="Cancelled", is_finished=True)
        return

    result = AbortableAsyncResult(task_id_job)
    # calling abort() and/or revoke() on this result will result in a cascade of revokes of uncompleted tasks
    # as in the execute_pipeline() task all chain tasks get called .revoke() on them
    result.revoke()
    result.abort()
    logger = get_task_logger(task_id_job)
    print(f'REVOKING JOB {task_id_job}')
    if settings.DEBUG:
        logger.warning("Revoking from within REVOKE_JOB")
    job.refresh_from_db()
    # result.revoke(terminate=True)
    if job.status != 'Cancelled':  # should be set to cancelled in task_revoked_handler (signals)
        #  does not work e.g. when celery is not running
        Job.objects.filter(id=job.id).update(status="Cancelled", is_finished=True)

    # Get the currently running task/job set by the task_prerun_handler (signals.py)
    # current_task = cache.get('current_task')
    current_job = cache.get('current_job')  # more reliable than 'running_job'
    # as running_job is only set by exec_pipline task
    pid = cache.get("running_task_pid")
    if current_job == job.id:  # make sure we dont kill the running task from the wrong view
        # kill the process with the pid - this is only applicable for subprocesses spawned by the worker with Popen
        print(f"Attempting to close process from revoke_job. pid={pid}, job={job.id}")
        if pid is not None:
            try:
                os.kill(pid, signal.SIGKILL)  # if it is running, kill it
            except ProcessLookupError:
                pass
    pipe_dict = cache.get(f'pipeline_{job.id}')
    if pipe_dict:
        try:
            if pid == pipe_dict['pid']:
                return
            if settings.DEBUG:
                logger.warning("trying with pipe dict")
                logger.warning(repr(pipe_dict))
                logger.warning(f'PID IS DIFFERENT: {pid}, {pipe_dict["pid"]}')
            os.kill(pipe_dict['pid'], signal.SIGTERM)
        except:
            pass


def update_meta_info(self, job_id, pid):
    # update meta info
    cache.set("running_task_pid", pid)
    pipe_dict = cache.get(f"pipeline_{job_id}", {})
    pipe_dict.update({
        'pid': pid,
        'job_id': job_id,
        'task_id': self.request.id,
        'name': self.request.task
    })
    cache.set(f"pipeline_{job_id}", pipe_dict)
    self.update_state(state='STARTED', meta={'pid_subprocess': pid})


def log_subprocess_output(pipe, logger=None, **kwargs):
    """logs stdout from a subprocess pipe to the individual task logger"""
    formatter_new = logging.Formatter('[%(asctime)s] %(message)s')
    self = kwargs.pop('self', 0)
    # change logger format temporarily while reading stdout - dirty solution?
    for loggr in logger.handlers:
        loggr.setFormatter(formatter_new)
    for line in iter(pipe.readline, b''): # b'\n'-separated lines
        logger.info('%s', line.decode('utf-8').strip().strip('\"').replace(r'\n', '\n'))
        if self and self.is_aborted():
            raise ExecutionAbortedError("Task aborted mid-execution")
    # return back to normal formatting
    for loggr in logger.handlers:
        loggr.setFormatter(logging.Formatter('[%(asctime)s][%(levelname)s] %(message)s'))


def check_abort_state(task_id, proc, logger):
    """checks if a task gets revoked/aborted
    if it does, try to kill the subprocess"""
    result = AbortableAsyncResult(task_id)
    if result.is_aborted() or result.state == 'REVOKED':
        # respect aborted state, and terminate gracefully
        proc.kill()
        raise ExecutionAbortedError(f'Task aborted by user')


def call_repeatedly(secs, func, task_id, proc, logger):
    while proc.poll() is None:
        time.sleep(secs)
        func(task_id, proc, logger)


@app.task(ignore_result=True)
def cleanup_expired_results():
    """Beat scheduled task, gets executed periodically. Removes expired results (after x amount of days,
    specified in the settings) and deletes corresponding files
    """
    # objects older than x (default 14) days will be deleted
    expired = timezone.now() - timedelta(days=settings.DAYS_UNTIL_JOB_DELETE)
    print(f'Deleting expired jobs. All jobs, that have started before {expired} will be deleted now.')
    jobs = Job.objects.filter(start_date__lt=expired, is_finished=True)
    for job in jobs: # TODO
        shutil.rmtree(os.path.dirname(job.sbml_file.path), ignore_errors=True)
        try:
            shutil.rmtree(os.path.dirname(job.public_path))
        except:
            pass
    jobs.delete()

    # sometimes jobs get "stuck"
    Job.objects.filter(is_finished=True, status="Queued").update(status="Failed")

    # TODO delete taskresults?


# Celery app scheduler for periodically scheduled task
app.conf.beat_schedule = {
    'cleanup': {
        'task': 'jobs.tasks.cleanup_expired_results',
        'schedule': 3600 # once an hour
    }
}


def setup_process(self, result, job_id, *args, **kwargs):
    """ Basic setup for most tasks. Configures task based logger and filepath variables """

    cache.set("current_task", self.request.id, timeout=None)
    # Logging
    logger = get_task_logger(self.request.id)
    app.log.redirect_stdouts_to_logger(logger, loglevel=logging.INFO)
    if settings.DEBUG:
        logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}. Job ID = {job_id}')

    # Filepath extractions
    fpath = Job.objects.get(id=job_id).sbml_file.path
    path = os.path.dirname(fpath)
    fname = os.path.basename(fpath)
    model_name, extension = os.path.splitext(fname)

    return logger, fpath, path, fname, model_name, extension


@shared_task(bind=True, name="update_db")
def update_db_post_run(self, result=None, job_id=None, *args, **kwargs):
    """updates database entries after a chain/pipeline is finished. Updates duration, status, finish time"""
    job = Job.objects.filter(id=job_id)
    finished_date = timezone.now()
    duration = finished_date - job.get().start_date
    hours, remainder = divmod(duration.total_seconds(), 3600)
    minutes, seconds = divmod(remainder, 60)
    duration = '{:02}:{:02}:{:02}'.format(int(hours), int(minutes), int(seconds))

    job.update(is_finished=True, finished_date=finished_date, status="Done", result=result, duration=duration)


@shared_task(bind=True, name="result_email")  # TODO
def send_result_email(self, result, job_id=None, *args, **kwargs):
    pass
    # """Mock SMTP result mail"""
    # job = Job.objects.get(id=job_id)
    #
    # print(f'Trying to send email to {job.user.email}')
    # message = f'Dear {job.user}, \n\nyour RobustQ job has just finished after {job.duration}. \n' \
    #           f'The task finished with result PoF={job.result} and status {job.status}. ' \
    #           f'\nThank you for using our service!'
    # try:
    #     send_mail(
    #         'Your RobustQ job has finished',
    #         message,
    #         'robustq.info@gmail.com',
    #         [job.user.email]
    #     )
    # except Exception as e:
    #     print('Failed to send email: ', repr(e))


###
"""
PIPELINE LOGIC BEGINS HERE 
"""
###


@shared_task(bind=True, name="SBML_processing")
def sbml_processing(self, job_id=None, make_consistent=False, *args, **kwargs):
    """First task in the workflow. Extracts info from the SBML file and if specified,
    tries to make model consistent. Writes info to files and returns the objective biomass rxn"""
    import cobra

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=None, *args, **kwargs)

    #  Set start date to now
    Job.objects.filter(id=job_id).update(start_date=timezone.now())
    logger.info(f'Make model consistent = {make_consistent}')
    logger.info(f'Trying to load SBML model {fname}')

    if extension == '.json':
        m = cobra.io.load_json_model(fpath)
    elif extension == '.xml' or extension == '.sbml':
        m = cobra.io.read_sbml_model(fpath)
    elif extension == '.mat':
        m = cobra.io.load_matlab_model(fpath)
    else:
        logger.error(f'ERROR: input file ({fname}) missing matching extension (.json/.xml/.sbml)')
        raise Exception(f'ERROR: input file ({fname}) missing matching extension (.json/.xml/.sbml)')

    logger.info('Successfully loaded model.')

    reactions = len(m.reactions)
    metabolites = len(m.metabolites)
    genes = len(m.genes)

    # Get Biomass reaction
    # bm_rxn = m.objective.expression  # doesnt return pure id
    exp_list = list(cobra.util.solver.linear_reaction_coefficients(m))
    if len(exp_list) > 1:
        logger.warning(f'Multiple objective expression functions found. We will try to infer the biomass reaction from '
                       f'this list. Other reactions may be removed by compression if you chose to compress.')
        for rxn in exp_list:
            if ("BIOMASS" or "biomass") in rxn.id:
                bm_rxn = rxn.id
    else:
        bm_rxn = exp_list[0].id
    logger.info(f'Biomass reaction was found to be {bm_rxn}')

    job = Job.objects.filter(id=job_id)

    if make_consistent:
        # Make model consistent
        from cobra.flux_analysis.variability import find_blocked_reactions
        import cobra.manipulation
        logger.info('Next step: try to make model consistent')
        fba_orig = m.slim_optimize()
        rxns_orig = len(m.reactions)
        mets_orig = len(m.metabolites)
        tol_orig = m.tolerance

        m.remove_reactions(find_blocked_reactions(m))
        # TODO look for possible fix for Pool issue
        m, _ = cobra.manipulation.delete.prune_unused_metabolites(m)

        fba_cons = m.slim_optimize()
        rxns_cons = len(m.reactions)
        mets_cons = len(m.metabolites)

        if abs(fba_orig - fba_cons) > (fba_orig * tol_orig):
            logger.error(f'{fname}: difference in FBA objective is too large')
            raise Exception(f'ERROR: {fname}: difference in FBA objective is too large')

        logger.info(f'{model_name}:\n{rxns_orig} rxns, {mets_orig} mets, obj: {fba_orig} '
                    f'--> {rxns_cons} rxns, {mets_cons} mets, obj: {fba_cons}\n')

        job.update(reactions=rxns_cons, metabolites=mets_cons, genes=len(m.genes), objective_expression=bm_rxn)
    else:
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
        logger.info(f'Created {model_name}.mfile')

        # write rfile - reactions
        with open(os.path.join(path, f'{model_name}.rfile'), 'w') as f:
            f.write(' '.join([rxn.id for rxn in m.reactions]))
        logger.info(f'Created {model_name}.rfile')

        # write rvfile - reversible reactions
        with open(os.path.join(path, f'{model_name}.rvfile'), 'w') as f:
            f.write(' '.join(['1' if rxn.reversibility \
                                  else '0' for rxn in m.reactions]))
        logger.info(f'Created {model_name}.rvfile')

        # write nfile - biomass reaction
        with open(os.path.join(path, f'{model_name}.nfile'), 'w') as f:
            f.write(bm_rxn)
        logger.info(f'Created {model_name}.nfile')

    except Exception as e:
        if settings.DEBUG:
            logger.error(repr(e))
            raise e
        else:
            raise Exception('There was an error writing out files.')
    # return biomass reaction for next task
    return bm_rxn


@shared_task(bind=True, name="compress_network", base=AbortableTask)
@revoke_chain_authority
def compress_network(self, result, job_id, *args, **kwargs):
    """If specified, compresses the metabolic model. This essentially runs
    the perl scripts that takes care of it as a subprocess"""

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
                                         '-n', f'{model_name}.nfile',
                                         '-i', f'{model_name}.nfile',
                                         '-p', 'chg_proto.txt',
                                         '-o', '_comp',
                                         '-l',
                                         '-k',
                                         ]

    if settings.DEBUG:
        logger.info(f'Starting network compression script with the following arguments: {" ".join(cmd_args)}')
        subtask = SubTask.objects.filter(task_id=self.request.id)
        subtask.update(command_arguments=" ".join(cmd_args))

    try:
        compress_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        update_meta_info(self, job_id, compress_process.pid)
        threading.Thread(target=call_repeatedly, args=(1, check_abort_state, self.request.id, compress_process,
                                                       logger)).start()

        with compress_process.stdout:
            log_subprocess_output(compress_process.stdout, logger=logger)

        compress_process.wait()
    except SoftTimeLimitExceeded as e:
        AbortableAsyncResult(self.request.id).abort()
        compress_process.kill()
        raise e
    except ExecutionAbortedError as e:
        compress_process.kill()
        raise e
    except Exception as e:
        logger.error(repr(e))
        raise e

    # write/copy growth reaction
    copyfile(os.path.join(path, f'{model_name}.nfile'), os.path.join(path, f'{model_name}.tfile_comp'))

    os.chdir(BASE_DIR)

    if compress_process.returncode:
        raise ExecutionAbortedError(f'Process {self.name} had non-zero exit status')

    return compress_process.returncode


@shared_task(bind=True, name="create_dual_system")
@revoke_chain_authority
def create_dual_system(self, result, job_id, *args, **kwargs):
    """Create a dual system EFM/MCS for the following MCS calculation"""

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
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

    # Start the process
    try:

        create_dual_system_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        cache.set("running_task_pid", create_dual_system_process.pid)

        with create_dual_system_process.stdout:
            log_subprocess_output(create_dual_system_process.stdout, logger=logger)
        create_dual_system_process.wait()

    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)

    if create_dual_system_process.returncode:
        raise ExecutionAbortedError(f'Process {self.name} had non-zero exit status')

    return create_dual_system_process.returncode


@shared_task(bind=True, name="defigueiredo", base=AbortableTask)
@revoke_chain_authority
def defigueiredo(self, result, job_id, cardinality, *args, **kwargs):
    """Calls the defigueiredo binary with the specified arguments. This subprocess
    can take multiple hours to complete, especially with a higher cardinality"""

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    dm = cardinality
    # threads - parameter?
    t = 10
    comp_suffix = 'comp' if kwargs['do_compress'] else 'uncomp'

    logger.info(f'Getting MCS: using up to d={dm} (cardinality) and t={t} thread(s)')
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
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

    # Start the process
    try:
        defigueiredo_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        update_meta_info(self, job_id, defigueiredo_process.pid)
        threading.Thread(target=call_repeatedly, args=(1, check_abort_state, self.request.id, defigueiredo_process,
                                                       logger)).start()

        with defigueiredo_process.stdout:
            log_subprocess_output(defigueiredo_process.stdout, logger=logger, self=self, pid=defigueiredo_process.pid)

        defigueiredo_process.wait()

    except SoftTimeLimitExceeded as e:
        try:
            defigueiredo_process.kill()
            os.kill(defigueiredo_process.pid, signal.SIGKILL)
            AbortableAsyncResult(self.request.id).abort()
        except ProcessLookupError:
            pass
        raise e

    except ExecutionAbortedError as e:
        defigueiredo_process.kill()
        raise e

    except Exception as e:
        logger.error(repr(e))
        raise ExecutionAbortedError(repr(e))

    os.chdir(BASE_DIR)

    # one final check - sleep to let the other worker catch up
    time.sleep(2)
    if self.is_aborted():
        raise ExecutionAbortedError("Task aborted!")
    time.sleep(1)
    return defigueiredo_process.returncode


@shared_task(bind=True, name="mcs_to_binary")
def mcs_to_binary(self, result, job_id, *args, **kwargs):
    """converts the MCS found by defigeuiredo to a binary representation. Also calls a subprocess,
    short runtime
    """
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

        with open(os.path.join(path, mcs_fname), 'r') as mcsfile, \
                open(os.path.join(path, output_file), 'w') as outfile:
            mcs_list = mcsfile.readlines()
            mcs_set = set(mcs_list)
            for line in mcs_set:  # TODO "FIX" - removes duplicate MCS from binary MCS file
                arr = ['0'] * len(rxns)
                sep = ' ' if ' ' in line else ','
                mcs = line.strip().split(sep)
                for rxn in mcs:
                    arr[rxns.index(rxn)] = '1'
                outfile.write(''.join(arr) + '\n')

        if len(mcs_list) > len(mcs_set):
            logger.warning(f'Duplicate MCS entries were found in {mcs_fname} (total {len(mcs_list)} vs {len(mcs_set)} unique).'
                           f' Duplicate entries were removed for PoF calculation and written to {output_file}')

        logger.info(f'Successfully read {mcs_fname} and {rxns_fname} and wrote output to {output_file}')

    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)


@shared_task(bind=True, name="PoFcalc", base=AbortableTask)
@revoke_chain_authority
def pofcalc(self, result, job_id, cardinality, *args, **kwargs):
    """The 'main' task - calculates the Failure probability of the given network.
    Calls the PoFcalc executable as a subprocess and once its finished, processes the stdout
    to extract and save the results"""

    # TODO binary changes iself? -> illegal instruction

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
        logger.info(f'Starting {self.request.task} with the following arguments: {" ".join(cmd_args)}')

    # Start the process
    try:
        pofcalc_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        update_meta_info(self, job_id, pofcalc_process.pid)

        threading.Thread(target=call_repeatedly, args=(3, check_abort_state, self.request.id, pofcalc_process,
                                                       logger)).start()
        stout = []
        with pofcalc_process.stdout:
            for line in iter(pofcalc_process.stdout.readline, b''):
                line = line.decode('utf-8').strip().strip('\"').replace(r'\n', '\n').replace(r'\x08', '')
                if '%' not in line:
                    stout.append(line)
                if self.is_aborted():
                    # respect aborted state, and terminate gracefully.
                    logger.warning('Task aborted (stdoutstream)')
                    os.kill(pofcalc_process.pid, signal.SIGTERM)
                    pofcalc_process.kill()

        # out, err = pofcalc_process.communicate()
        # out = out.decode('utf-8').strip().strip('\"').replace(r'\n', '\n')
        # # logger.info(out)
        # if err:
        #     logger.error(err)
        #     raise Exception(err)

        # out = out.splitlines()  # convert to list for following steps
        out = stout
        job = Job.objects.filter(id=job_id)

        # extract the table with results from stdout
        for i in range(len(out)):
            if 'weight' in out[i]:
                resulttable = out[i+2:i+2+cardinality]
                colnames = list(x.strip() for x in out[i].split('|'))
                result = list(map(lambda x: list(y.strip() for y in x.split('|')), resulttable))

                df = pd.DataFrame(data=result, columns=colnames)
                filepath = os.path.join(path, f'result_table_{model_name}.csv')
                df.to_csv(filepath, index=False)
                job.update(result_table=filepath)
                break

        logger.info('\n'.join(out))

        if 'Final PoF' in out[-1]:
            # gets the result from the process output
            try:
                pof_result = round(float(out[-1].split()[-1]), 4)
            except ValueError:
                pof_result = out[-1].split()[-1]
            job.update(result=pof_result)  # stores the string of the result

        pofcalc_process.wait()

    except SoftTimeLimitExceeded as e:
        try:
            pofcalc_process.kill()
            os.kill(pofcalc_process.pid, signal.SIGKILL)
            AbortableAsyncResult(self.request.id).abort()
        except ProcessLookupError:
            pass
        raise e

    except Exception as e:
        logger.error(repr(e))
        raise e

    os.chdir(BASE_DIR)

    if pofcalc_process.returncode:
        raise ExecutionAbortedError(f'Process {self.name} had non-zero exit status')
    else:
        return float(pof_result) if pof_result else pofcalc_process.returncode


@shared_task(bind=True, name="abort_task", ignore_result=True)
def abort_task(self, *args, **kwargs):
    res = AbortableAsyncResult(kwargs['t_id'])
    res.revoke()
    res.abort()


@shared_task(bind=True, name="execute_pipeline", base=AbortableTask, time_limit=settings.CELERY_TASK_TIME_LIMIT,
             soft_time_limit=settings.CELERY_TASK_SOFT_TIME_LIMIT)
def execute_pipeline(self, job_id, compression_checked, cardinality_defi,
                     cardinality_pof, make_consistent, *args, **kwargs):
    """
    Executes the pipeline for Pof calculation. Creates a celery chain from all tasks and calls it.
    Blocks celery workers from picking up another job until the execution is finished to ensure
    consecutive execution of the jobs passed to the queue
    Args:
        self: task object, passed from celery
        job_id: job id
        compression_checked: (bool) whether or not to compress the network
        cardinality_defi: (int) the cardinality specified for defigeuriedo process
        cardinality_pof: (int) cardinality specified for PoFcalc process
        make_consistent: (bool) whether or not to attempt to make network consistent
        *args:
        **kwargs:

    Returns: AsyncResult

    """
    this_result = AbortableAsyncResult(self.request.id)
    job = Job.objects.get(id=job_id)
    if this_result.is_aborted() or this_result.status == 'REVOKED' or job.status == 'Cancelled' \
            or this_result.status == 'ABORTED':
        return 'ABORTED'
    pipe_cache = f'pipeline_{job_id}'

    cache.set('running_job', job_id, timeout=10000)
    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=None, *args,
                                                                      **kwargs)

    Job.objects.filter(id=job_id).update(task_id_job=self.request.id, model_name=model_name)

    result = chain(sbml_processing.s(job_id=job_id, make_consistent=make_consistent),
                   compress_network.s(job_id=job_id, do_compress=compression_checked),
                   create_dual_system.s(job_id=job_id, do_compress=compression_checked),
                   defigueiredo.s(job_id=job_id, cardinality=cardinality_defi, do_compress=compression_checked),
                   mcs_to_binary.s(job_id=job_id, do_compress=compression_checked),
                   pofcalc.s(job_id=job_id, cardinality=cardinality_pof, do_compress=compression_checked),
                   update_db_post_run.s(job_id=job_id),
                   send_result_email.s(job_id=job_id)
                   ).on_error(abort_task.s(t_id=self.request.id)).apply_async()

    cache.set('current_chain', result.task_id, timeout=40000)

    copy = result
    parents = list()
    parents.append(copy)
    while copy.parent:
        parents.append(copy.parent)
        copy = copy.parent

    def check_parents(parents):
        """ loops through all tasks in a chain, checks their status and aborts if need be"""
        for parent in parents:
            if parent.status == 'STARTED':
                AbortableAsyncResult(parent.id).abort()
                parent.revoke()
                if settings.DEBUG:
                    logger.warning(f'Cancelling current running task {parent.id}')
                if job_id == cache.get('current_job'):
                    try:
                        os.kill(cache.get('running_task_pid'), signal.SIGTERM)
                    except ProcessLookupError:
                        logger.warning(f'No (valid) PID found for task cancel.')
            if parent.status == 'PENDING':
                logger.warning(f'Revoking pending task {parent.id}')
                parent.revoke()

    try:
        while not result.ready():  # this blocks the worker from starting another task before the previous one has finished
            for parent in parents:
                if parent.status == 'FAILURE' or parent.status == 'REVOKED' or AbortableAsyncResult(parent.id).is_aborted():
                    try:
                        name = parent._cache['task_name']
                    except:  # broad exception clause because could be AttributeError or ValueError or TypeError
                        name = None
                    logger.error(f'Task {parent.id}, {name} ended with status {parent.status}!')
                    this_result.abort()
                    self.update_state(state='FAILURE', meta={'reason': f'{name} failed/got aborted'})
                if parent.status == 'STARTED':
                    if not cache.get(pipe_cache):
                        name = parent.name or 'unspecified'
                        cache.set(pipe_cache, {
                            'name': name,
                            'task_id': parent.id,
                            'status': parent.status,
                            'pipeline_id': this_result.id,
                            'job_id': job_id
                        }, timeout=86400)
            job.refresh_from_db()
            if this_result.is_aborted() or this_result.status == 'REVOKED' or job.status == 'Cancelled':
                # if this (execute_pipeline) task has been revoked (by clicking 'cancel'), revoke all tasks in the chain
                # as well to stop them from being executed
                logger.warning(f'Task {self.request.id} was flagged as revoked or got aborted, status {this_result.status}')
                result.revoke()
                check_parents(parents)
                logger.warning(f'Job {job_id} now has status {job.status} (after loop)')
                break

            time.sleep(1)

        return result.task_id
    except SoftTimeLimitExceeded as e:
        this_result.abort()
        check_parents(parents)
        revoke_job(job)
        logger.error(repr(e))
        raise e
