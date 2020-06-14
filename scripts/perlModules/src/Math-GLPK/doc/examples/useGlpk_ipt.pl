#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Fri Nov 15 11:30:30 CET 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Math::GLPK::EnvIpt;
use Math::GLPK::Base;

################################################################################
################################################################################
my $glpk_env = Math::GLPK::EnvIpt->new();
die "ERROR: openGLPK() failed!" unless $glpk_env;
print "GLPK: version: ", $glpk_env->version(), "\n";
################################################################################


################################################################################
################################################################################
print "message level: ", $glpk_env->get_msg_level(), "\n";
$glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);
print "message level: ", $glpk_env->get_msg_level(), "\n";
print "ordering algorithm: ", $glpk_env->get_ord_alg(), "\n";
$glpk_env->set_ord_alg(&Math::GLPK::Base::GLP_ORD_QMD);
print "ordering algorithm: ", $glpk_env->get_ord_alg(), "\n";
################################################################################

################################################################################
################################################################################
my $lp = $glpk_env->createLP();
die "ERROR: couldn't create Linear Program\n" unless $lp;
################################################################################


################################################################################
################################################################################
die "ERROR: maximize() failed\n" unless $lp->maximize();


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
             # col_types => [ $cv,  $cv],
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
die "ERROR: interior() failed\n" unless $lp->interior();
################################################################################


################################################################################
################################################################################
$filename = "/tmp/solution.txt";
print "INFO: write solution to $filename\n";
die "ERROR: write_sol() failed\n" unless $lp->write_sol($filename);
################################################################################


################################################################################
################################################################################
print "INFO: get_status returned: ", $lp->ipt_status(), "\n";
################################################################################


################################################################################
################################################################################
print "objective value: ", $lp->ipt_obj_val(), "\n";

for( my $c = 1; $c <= $lp->get_num_cols; $c++ )
{
   print "column '", $lp->get_col_name($c), "': ", $lp->ipt_col_prim($c), "\n";
}
################################################################################


################################################################################
################################################################################
die "ERROR: free() failed\n" unless $lp->free();
die "ERROR: close() failed\n" unless $glpk_env->close();
################################################################################
