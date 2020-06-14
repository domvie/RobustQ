#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Fri Oct 25 13:41:39 CEST 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Math::GLPK::EnvMip;
use Math::GLPK::Base;

################################################################################
################################################################################
my $glpk_env = Math::GLPK::EnvMip->new();
die "ERROR: openGLPK() failed!" unless $glpk_env;
################################################################################

################################################################################
################################################################################
my $lp = $glpk_env->createLP();
die "ERROR: couldn't create Linear Program\n" unless $lp;
################################################################################

################################################################################
# message level
################################################################################
print "message level: ", $glpk_env->get_msg_level(), "\n";
print "set message level to 'ERR': ", &Math::GLPK::Base::GLP_MSG_ERR,"\n";
print "message level: ", $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR), "\n";
print "message level: ", $glpk_env->get_msg_level(), "\n";
################################################################################

################################################################################
# branching technique
################################################################################
print "branching technique: ", $glpk_env->get_br_tech(), "\n";
print "set branching technique to 'FFV': ", &Math::GLPK::Base::GLP_BR_FFV,"\n";
print "branching technique: ", $glpk_env->set_br_tech(&Math::GLPK::Base::GLP_BR_FFV), "\n";
print "branching technique: ", $glpk_env->get_br_tech(), "\n";
################################################################################

################################################################################
# backtracking technique
################################################################################
print "backtracking technique: ", $glpk_env->get_bt_tech(), "\n";
print "set backtracking technique to 'DFS': ", &Math::GLPK::Base::GLP_BT_DFS,"\n";
print "backtracking technique: ", $glpk_env->set_bt_tech(&Math::GLPK::Base::GLP_BT_DFS), "\n";
print "backtracking technique: ", $glpk_env->get_bt_tech(), "\n";
################################################################################

################################################################################
# preprocessing technique
################################################################################
print "preprocessing technique: ", $glpk_env->get_pp_tech(), "\n";
print "set preprocessing technique to 'NONE': ", &Math::GLPK::Base::GLP_PP_NONE,"\n";
print "preprocessing technique: ", $glpk_env->set_pp_tech(&Math::GLPK::Base::GLP_PP_NONE), "\n";
print "preprocessing technique: ", $glpk_env->get_pp_tech(), "\n";
################################################################################

################################################################################
# feasibility pump heuristics
################################################################################
print "feasibility pump heuristics: ", $glpk_env->get_fp_heur(), "\n";
print "set feasibility pump heuristics to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
print "feasibility pump heuristics: ", $glpk_env->set_fp_heur(&Math::GLPK::Base::GLP_ON), "\n";
print "feasibility pump heuristics: ", $glpk_env->get_fp_heur(), "\n";
################################################################################

################################################################################
# Gomory's mixed integer cut option
################################################################################
print "Gomory's mixed integer cut option: ", $glpk_env->get_gmi_cuts(), "\n";
print "set Gomory's mixed integer cut option to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
print "Gomory's mixed integer cut option: ", $glpk_env->set_gmi_cuts(&Math::GLPK::Base::GLP_ON), "\n";
print "Gomory's mixed integer cut option: ", $glpk_env->get_gmi_cuts(), "\n";
################################################################################

################################################################################
# Mixed integer rounding (MIR) cut option
################################################################################
print "Mixed integer rounding (MIR) cut option: ", $glpk_env->get_mir_cuts(), "\n";
print "set Mixed integer rounding (MIR) cut option to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
print "Mixed integer rounding (MIR) cut option: ", $glpk_env->set_mir_cuts(&Math::GLPK::Base::GLP_ON), "\n";
print "Mixed integer rounding (MIR) cut option: ", $glpk_env->get_mir_cuts(), "\n";
################################################################################

################################################################################
# Mixed cover cut option
################################################################################
print "Mixed cover cut option: ", $glpk_env->get_cov_cuts(), "\n";
print "set Mixed cover cut option to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
print "Mixed cover cut option: ", $glpk_env->set_cov_cuts(&Math::GLPK::Base::GLP_ON), "\n";
print "Mixed cover cut option: ", $glpk_env->get_cov_cuts(), "\n";
################################################################################

################################################################################
# Clique cut option
################################################################################
# print "Clique cut option: ", $glpk_env->get_clq_cuts(), "\n";
# print "set Clique cut option to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
# print "Clique cut option: ", $glpk_env->set_clq_cuts(&Math::GLPK::Base::GLP_ON), "\n";
# print "Clique cut option: ", $glpk_env->get_clq_cuts(), "\n";
################################################################################

################################################################################
# Absolute Tolerance
################################################################################
print "absolute tolerance: ", $glpk_env->get_tol_int(), "\n";
print "absolute tolerance to 1e-06: ", $glpk_env->set_tol_int(1e-06), "\n";
print "absolute tolerance: ", $glpk_env->get_tol_int(), "\n";
################################################################################

################################################################################
# Relative Tolerance
################################################################################
print "relative tolerance: ", $glpk_env->get_tol_obj(), "\n";
print "relative tolerance to 1e-08: ", $glpk_env->set_tol_obj(1e-08), "\n";
print "relative tolerance: ", $glpk_env->get_tol_obj(), "\n";
################################################################################

################################################################################
# MIP Gap
################################################################################
print "MIP gap: ", $glpk_env->get_mip_gap(), "\n";
print "MIP gap to 1e-10: ", $glpk_env->set_mip_gap(1e-10), "\n";
print "MIP gap: ", $glpk_env->get_mip_gap(), "\n";
################################################################################

################################################################################
# time limit
################################################################################
print "time limit: ", $glpk_env->get_tm_lim(), "\n";
print "set time limit to 454545: ", $glpk_env->set_tm_lim(454545), "\n";
print "time limit: ", $glpk_env->get_tm_lim(), "\n";
################################################################################

################################################################################
# output frequency
################################################################################
print "output frequency: ", $glpk_env->get_out_frq(), "\n";
print "set output frequency to 750: ", $glpk_env->set_out_frq(750), "\n";
print "output frequency: ", $glpk_env->get_out_frq(), "\n";
################################################################################

################################################################################
# output frequency
################################################################################
print "output delay: ", $glpk_env->get_out_dly(), "\n";
print "set output delay to 10: ", $glpk_env->set_out_dly(10), "\n";
print "output delay: ", $glpk_env->get_out_dly(), "\n";
################################################################################

################################################################################
# presolve
################################################################################
print "presolve: ", $glpk_env->get_presolve(), "\n";
print "set presolve to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
print "presolve: ", $glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON), "\n";
print "presolve: ", $glpk_env->get_presolve(), "\n";
################################################################################

################################################################################
# binarize
################################################################################
print "binarize: ", $glpk_env->get_binarize(), "\n";
print "set binarize to 'ON': ", &Math::GLPK::Base::GLP_ON,"\n";
print "binarize: ", $glpk_env->set_binarize(&Math::GLPK::Base::GLP_ON), "\n";
print "binarize: ", $glpk_env->get_binarize(), "\n";
################################################################################


################################################################################
################################################################################
die "ERROR: maximize() failed\n" unless $lp->maximize();
print "optimization direction flag: ", $lp->get_obj_dir(), "\n";
print "minimizing: ", &Math::GLPK::Base::GLP_MIN, "\n";
print "minimizing: ", &Math::GLPK::Base::GLP_MAX, "\n";
################################################################################


################################################################################
################################################################################
my $cv = &Math::GLPK::Base::GLP_CV; # continuous variable;
my $iv = &Math::GLPK::Base::GLP_IV; # integer variable;
my $bv = &Math::GLPK::Base::GLP_BV; # binary variable.

my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
my $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable
my $cols = { num_cols  => 2,
             obj_coefs => [ 0.6,  0.5],
             types_bnd => [ $lo,  $lo],
             lower_bnd => [ 0.0,  0.0],
             upper_bnd => [ 0.0,  0.0],
             col_types => [ $iv,  $cv],
             col_names => ['c1', 'c2']};
die "ERROR: newcols() failed\n" unless $lp->newcols($cols);



my $newRows;
$newRows->[0][0] = 1.0;
$newRows->[0][1] = 2.0;
$newRows->[1][0] = 3.0;
$newRows->[1][1] = 1.0;
my $rows = {num_rows  => 2,
            upper_bnd => [1.0, 2.0],
            lower_bnd => [0.0, 0.0],
            sense     => [ $up, $up],
            row_names => ["row1", "row2"],
            row_coefs => $newRows};

die "ERROR: addrows() failed\n" unless $lp->addrows($rows);
################################################################################


################################################################################
################################################################################
my $obj_name_set = 'myObective';
$lp->set_obj_name($obj_name_set);
print 'objective name is ', $lp->get_obj_name(), "\n";
################################################################################

################################################################################
################################################################################
# set name of first row
$lp->set_row_name(1, "Flying Spaghetti Monster");
print "name of first row: ", $lp->get_row_name(1), "\n";
################################################################################

################################################################################
################################################################################
# set name of second column
$lp->set_col_name(2, "newName");
print "name of second column: ", $lp->get_row_name(2), "\n";
################################################################################

################################################################################
################################################################################
# set prob name
$lp->set_prob_name("coolProb");
print "new problem name: ", $lp->get_prob_name(), "\n";
################################################################################



################################################################################
################################################################################
my $filename = "/tmp/myGLPK.lp";
print "INFO: going to write lp-file '$filename'\n";
die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);

$filename = "/tmp/myGLPK.mps";
print "INFO: going to write mps-file '$filename'\n";
die "ERROR: write_mps() failed\n" unless $lp->write_mps($filename);

$filename = "/tmp/myGLPK.glpk";
print "INFO: going to write glpk-file '$filename'\n";
die "ERROR: write_prob() failed\n" unless $lp->write_prob($filename);
################################################################################

################################################################################
################################################################################
die "ERROR: intopt() failed\n" unless $lp->intopt();
################################################################################

################################################################################
################################################################################
print "MIP status: ", $lp->mip_status(), "\n";
print "MIP objective value: ", $lp->mip_obj_val(), "\n";
for( my $i = 1; $i <= $lp->get_num_cols(); $i++ )
{
   print "$i: ", $lp->get_col_name($i),": ", $lp->mip_col_val($i), "\n";
}
################################################################################

################################################################################
print "number of rows: ", $lp->get_num_rows(), "\n";
print "number of cols: ", $lp->get_num_cols(), "\n";
print "number of non-zeros: ", $lp->get_num_nz(), "\n";
print "number of binary variables: ", $lp->get_num_bin(), "\n";
print "number of binary variables: ", $lp->get_num_bin(), "\n";
print "number of integer variables: ", $lp->get_num_int(), "\n";
################################################################################

################################################################################
################################################################################
$filename = "/tmp/solution.txt";
print "INFO: write solution to $filename\n";
die "ERROR: write_sol() failed\n" unless $lp->write_sol($filename);

$filename = "/tmp/solution.mip";
print "INFO: write mip solution to $filename\n";
die "ERROR: write_mip() failed\n" unless $lp->write_mip($filename);
################################################################################


################################################################################
################################################################################
die "ERROR: free() failed\n" unless $lp->free();
die "ERROR: close() failed\n" unless $glpk_env->close();
################################################################################
