#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Fri Oct 25 13:41:39 CEST 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Math::GLPK::EnvSimplex;
use Math::GLPK::Base;

################################################################################
################################################################################
my $glpk_env = Math::GLPK::EnvSimplex->new();
die "ERROR: openGLPK() failed!" unless $glpk_env;
print "GLPK: version: ", $glpk_env->version(), "\n";
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
# simple method
################################################################################
print "simplex method: ", $glpk_env->get_meth(), "\n";
print "set method to 'DUAL': ", &Math::GLPK::Base::GLP_DUAL,"\n";
print "method: ", $glpk_env->set_meth(&Math::GLPK::Base::GLP_DUAL), "\n";
print "method: ", $glpk_env->get_meth(), "\n";
################################################################################

################################################################################
# pricing
################################################################################
print "pricing: ", $glpk_env->get_pricing(), "\n";
print "set pricing to 'STD': ", &Math::GLPK::Base::GLP_PT_STD,"\n";
print "pricing: ", $glpk_env->set_pricing(&Math::GLPK::Base::GLP_PT_STD), "\n";
print "pricing: ", $glpk_env->get_pricing(), "\n";
################################################################################

################################################################################
# ratio test technique
################################################################################
print "ratio test technique: ", $glpk_env->get_r_test(), "\n";
print "set ratio test technique to 'STD': ", &Math::GLPK::Base::GLP_RT_STD,"\n";
print "ratio test technique: ", $glpk_env->set_r_test(&Math::GLPK::Base::GLP_RT_STD), "\n";
print "ratio test technique: ", $glpk_env->get_r_test(), "\n";
print "set ratio test technique to unkown value: ", $glpk_env->set_r_test(317), "\n";
print "reset ratio test technique to kown value: ", $glpk_env->set_r_test(&Math::GLPK::Base::GLP_RT_STD), "\n";
################################################################################

################################################################################
# tolerance primal feasible
################################################################################
print "tolerance primal feasible: ", $glpk_env->get_tol_bnd(), "\n";
print "set tolerance to 1e-06: ", $glpk_env->set_tol_bnd(1e-06), "\n";
print "ratio tolerance: ", $glpk_env->get_tol_bnd(), "\n";
################################################################################

################################################################################
# tolerance primal feasible
################################################################################
print "tolerance dual feasible: ", $glpk_env->get_tol_dj(), "\n";
print "set tolerance to 1e-06: ", $glpk_env->set_tol_dj(1e-06), "\n";
print "ratio tolerance: ", $glpk_env->get_tol_dj(), "\n";
################################################################################

################################################################################
# tolerance pivot
################################################################################
print "tolerance pivot elements: ", $glpk_env->get_tol_piv(), "\n";
print "set tolerance to 1e-06: ", $glpk_env->set_tol_piv(1e-06), "\n";
print "ratio tolerance: ", $glpk_env->get_tol_piv(), "\n";
################################################################################

################################################################################
# lower limit of the objective function
################################################################################
print "lower limit of the objective function: ", $glpk_env->get_obj_ll(), "\n";
print "set lower limit to -1.79769313486232e+307: ", $glpk_env->set_obj_ll(-1.79769313486232e+307), "\n";
print "lower limit: ", $glpk_env->get_obj_ll(), "\n";
################################################################################

################################################################################
# upper limit of the objective function
################################################################################
print "upper limit of the objective function: ", $glpk_env->get_obj_ul(), "\n";
print "set upper limit to 1.79769313486232e+307: ", $glpk_env->set_obj_ul(1.79769313486232e+307), "\n";
print "upper limit: ", $glpk_env->get_obj_ul(), "\n";
################################################################################

################################################################################
# iteration limit
################################################################################
print "iteration limit: ", $glpk_env->get_it_lim(), "\n";
print "set iteration limit to 15234234: ", $glpk_env->set_it_lim(15234234), "\n";
print "iteration limit: ", $glpk_env->get_it_lim(), "\n";
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
################################################################################
my $lp = $glpk_env->createLP();
die "ERROR: couldn't create Linear Program\n" unless $lp;
################################################################################


################################################################################
################################################################################
die "ERROR: maximize() failed\n" unless $lp->maximize();


my $cv = &Math::GLPK::Base::GLP_CV; # continuous variable
my $iv = &Math::GLPK::Base::GLP_IV; # integer variable
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
             col_types => [ $cv,  $cv],
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
my $filename = "/tmp/myGLPK.lp";
print "INFO: going to write lp-file '$filename'\n";
die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);
################################################################################


################################################################################
################################################################################
# get non-zero constraint values of first row
my %nz_row_vals = $lp->get_mat_row(1);
foreach my $idx (keys %nz_row_vals)
{
   print "$idx=$nz_row_vals{$idx} ";
}
print "\n";

# get non-zero constraint values of second column
my %nz_col_vals = $lp->get_mat_col(2);
foreach my $idx (keys %nz_col_vals)
{
   print "$idx=$nz_col_vals{$idx} ";
}
print "\n";
################################################################################


################################################################################
################################################################################
# die "ERROR: simplex() failed\n" unless $lp->simplex();
die "ERROR: exact() failed\n" unless $lp->exact();
################################################################################


################################################################################
################################################################################
$filename = "/tmp/solution.txt";
print "INFO: write solution to $filename\n";
die "ERROR: write_sol() failed\n" unless $lp->write_sol($filename);
################################################################################


################################################################################
################################################################################
print "INFO: get_status returned: ", $lp->get_status(), "\n";
print "INFO: get_prim_stat returned: ", $lp->get_prim_stat(), "\n";
print "INFO: get_dual_stat returned: ", $lp->get_dual_stat(), "\n";
################################################################################


################################################################################
# constraint matrix:
#  1.0   2.0
#  3.0   1.0
################################################################################
print "objective value: ", $lp->get_obj_val(), "\n";

for( my $c = 1; $c <= $lp->get_num_cols; $c++ )
{
   print "column '", $lp->get_col_name($c), "': ", $lp->get_col_prim($c), "\n";
}
################################################################################

################################################################################
################################################################################
my @glpk_constants = &Math::GLPK::Base::get_all_GLPK_consts();
print "all supported GLPK constants @glpk_constants\n";
################################################################################


################################################################################
################################################################################
die "ERROR: free() failed\n" unless $lp->free();
die "ERROR: close() failed\n" unless $glpk_env->close();
################################################################################
