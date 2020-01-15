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
import subprocess
from celery.utils.log import get_task_logger
import sys
import os
from shutil import copyfile
import logging

BASE_DIR = os.getcwd()


def log_subprocess_output(pipe, logger=None):
    for line in iter(pipe.readline, b''): # b'\n'-separated lines
        logger.info('%r', line.decode('utf-8'))


def setup_process(self, result, job_id, *args, **kwargs):
    """ Basic setup for most tasks. Configures task based logger and filepath variables """

    # Logging
    logger = get_task_logger(self.request.id)
    app.log.redirect_stdouts_to_logger(logger, loglevel=logging.INFO)
    logger.info(f'Result of previous task was {result}')
    logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}. Job ID = {job_id}')

    # Filepath extractions
    fpath = Job.objects.get(id=job_id).sbml_file.path
    path = os.path.dirname(fpath)
    fname = os.path.basename(fpath)
    model_name, extension = os.path.splitext(fname)

    return (logger, fpath, path, fname, model_name, extension)


@shared_task(bind=True, name='cpu_test_one')
def cpu_test(self, *args, **kwargs):
    logger = get_task_logger(self.request.id)
    logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}. Job ID = {self.request.kwargs}')
    cpu = subprocess.Popen("bin/cpu_fun", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with cpu.stdout:
        log_subprocess_output(cpu.stdout, logger=logger)
    cpu.wait()
    # stdout = cpu.communicate()[0]
    # logger.info(stdout)
    return cpu.returncode


@shared_task(bind=True, name='cpu_test_two')
def cpu_test_two(self, result=None, *args, **kwargs):
    print('inside cpu task 2')
    logger = get_task_logger(self.request.id)
    logger.info(f'Result of previous task was {result}')
    logger.info(f'Task {self.request.task} started with args={args}, kwargs={kwargs}')
    cpu = subprocess.Popen("bin/cpu_fun", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with cpu.stdout:
        log_subprocess_output(cpu.stdout, logger=logger)
    cpu.wait()
    # stdout = cpu.communicate()[0]
    # logger.info(stdout)
    # job = Job.objects.filter(id=id)
    return cpu.returncode


@shared_task(bind=True)
def update_db_post_run(self, result=None, job_id=None, *args, **kwargs):
    job = Job.objects.filter(id=job_id)
    job.update(is_finished=True, finished_date=timezone.now(), status="Done", result=result)


@shared_task(bind=True, name="SBML_processing")
def sbml_processing(self, job_id=None, *args, **kwargs):
    """ """
    import numpy as np
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

    # Make model consistent
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


@shared_task(bind=True, name="compress_network")
def compress_network(self, result, job_id, *args, **kwargs):
    """ """

    logger, fpath, path, fname, model_name, extension = setup_process(self, job_id=job_id, result=result, *args,
                                                                      **kwargs)

    # change to new WD
    os.chdir(path)

    # call the script process
    cmd_args = [os.path.join(BASE_DIR, 'scripts/compress_network.pl'),
                                         '-s', f'{model_name}.sfile',
                                         '-m', f'{model_name}.mfile',
                                         '-r', f'{model_name}.rfile',
                                         '-v', f'{model_name}.rvfile',
                                         '-i', f'{model_name}.nfile',
                                         '-p', 'chg_proto.txt',
                                         '-o', '_comp',
                                         '-l',
                                         '-k',
                                         ]
    logger.info(f'Starting network compression script with the following parameters: {cmd_args}')
    try:
        compress_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        with compress_process.stdout:
            log_subprocess_output(compress_process.stdout, logger=logger)
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

    # write inputs to file
    filetypes = ['r', 'm', 's', 'rv', 't']
    with open(os.path.join(path, f'{model_name}.inp'), 'w') as f:
        for type in filetypes:
            f.write(f'{model_name}.{type}file_comp')
    f.close()

    cmd_args = [os.path.join(BASE_DIR, 'scripts/create_ccds_files.pl'),
                                         '-c', f'{model_name}.inp',
                                         '-o', f'{model_name}_comp'
                ]

    # Start the process
    try:
        create_dual_system_process = subprocess.Popen(cmd_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        with create_dual_system_process.stdout:
            log_subprocess_output(create_dual_system_process.stdout, logger=logger)
        create_dual_system_process.wait()

    except Exception as e:
        logger.error(repr(e))
        raise e


@shared_task(bind=True, name="defigueiredo")
def defigueiredo(self, result, job_id, *args, **kwargs):
    """ """

    pass


