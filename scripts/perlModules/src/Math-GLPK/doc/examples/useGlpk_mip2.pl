#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Fri Nov 15 07:43:40 CET 2013
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
# turn presolve on
$glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON);
################################################################################

################################################################################
################################################################################
my $lp = $glpk_env->createLP();
die "ERROR: couldn't create Linear Program\n" unless $lp;
################################################################################


################################################################################
################################################################################
die "ERROR: maximize() failed\n" unless $lp->maximize();
################################################################################


################################################################################
# define columns
################################################################################
my $cv = &Math::GLPK::Base::GLP_CV; # continuous variable;
my $iv = &Math::GLPK::Base::GLP_IV; # integer variable;
my $bv = &Math::GLPK::Base::GLP_BV; # binary variable.

my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
my $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable

my $num_cols = 2;
my $obj_coefs = [ 0.6,  0.5];
my $types_bnd = [ $lo,  $lo],
my $lower_bnd = [ 0.0,  0.0],
my $upper_bnd = [ 0.0,  0.0],
my $col_types = [ $iv,  $cv],
my $col_names = ['c1', 'c2'];

$lp->add_cols($num_cols);
for(my $c = 1; $c <= $num_cols; $c++ )
{
   die "setting objective coefficient $c failed\n"  unless $lp->set_obj_coef($c, $obj_coefs->[$c-1]);
   die "setting column name for column $c failed\n" unless $lp->set_col_name($c, $col_names->[$c-1]);
   die "setting column kind for column $c failed\n" unless $lp->set_col_kind($c, $col_types->[$c-1]);
   die "setting bounds for column $c failed\n"      unless $lp->set_col_bnds($c, $types_bnd->[$c-1], $lower_bnd->[$c-1], $upper_bnd->[$c-1]);
}
################################################################################


################################################################################
# define rows
################################################################################
my $num_rows  = 2,
my $ub        = [1.0, 2.0],
my $lb        = [0.0, 0.0],
my $sense     = [ $up, $up],
my $row_names = ["row1", "row2"],
my $newRows;
$newRows->[0][0] = 1.0;
$newRows->[0][1] = 2.0;
$newRows->[1][0] = 3.0;
$newRows->[1][1] = 1.0;

$lp->add_rows($num_rows);
for( my $r = 1; $r <= $num_rows; $r++ )
{
   die "setting name of row $r failed"      unless $lp->set_row_name($r, $row_names->[$r-1]);
   die "setting bounds for row $r failed\n" unless $lp->set_row_bnds($r, $sense->[$r-1], $lb->[$r-1], $ub->[$r-1]);
}
$lp->load_matrix($newRows);
################################################################################

################################################################################
# search for rows and columns
################################################################################
$lp->create_index();
print "row 'row1' found at index ",  $lp->find_row("row1"), "\n";
print "row 'row2' found at index ",  $lp->find_row("row2"), "\n";
print "column 'c1' found at index ", $lp->find_col("c1"), "\n";
print "column 'c2' found at index ", $lp->find_col("c2"), "\n";
$lp->delete_index();
################################################################################

################################################################################
# row and column types
################################################################################
print "type of row 1: ", $lp->get_row_type(1), "\n";
print "type of col 2: ", $lp->get_col_type(2), "\n";
print "valid types are:\n";
print "   GLP_FR=", &Math::GLPK::Base::GLP_FR, "\n";
print "   GLP_LO=", &Math::GLPK::Base::GLP_LO, "\n";
print "   GLP_UP=", &Math::GLPK::Base::GLP_UP, "\n";
print "   GLP_DB=", &Math::GLPK::Base::GLP_DB, "\n";
print "   GLP_FX=", &Math::GLPK::Base::GLP_FX, "\n";
################################################################################


################################################################################
# get lower und upper bounds
################################################################################
print "lower bound of row 2: ", $lp->get_row_lb(2), "\n";
print "upper bound of row 2: ", $lp->get_row_ub(2), "\n";
print "lower bound of col 1: ", $lp->get_col_lb(1), "\n";
print "upper bound of col 1: ", $lp->get_col_ub(1), "\n";
################################################################################

################################################################################
print "objective coefficient 1: ", $lp->get_obj_coef(1), "\n";
print "objective coefficient 2: ", $lp->get_obj_coef(2), "\n";
################################################################################

################################################################################
# sort matrix
################################################################################
$lp->sort_matrix();
################################################################################


################################################################################
################################################################################
my $filename = "/tmp/myGLPK.lp";
print "INFO: going to write lp-file '$filename'\n";
die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);
################################################################################

################################################################################
################################################################################
die "ERROR: intopt() failed\n" unless $lp->intopt();
################################################################################

################################################################################
################################################################################
print "MIP status: ", $lp->mip_status(), "\n";
print "MIP objective value: ", $lp->mip_obj_val(), "\n";
################################################################################

################################################################################
################################################################################
print "scaling factor of row 1: ", $lp->get_rii(1), "\n";
print "set scaling factor of row 1 to 0.5: ", $lp->set_rii(1, 0.5), "\n";
print "scaling factor of row 1: ", $lp->get_rii(1), "\n";
print "scaling factor of col 2: ", $lp->get_sjj(2), "\n";
print "set scaling factor of col 2 to 2.0: ", $lp->set_sjj(2, 2.0), "\n";
print "scaling factor of col 2: ", $lp->get_sjj(2), "\n";
################################################################################

################################################################################
# scale probe
################################################################################
print "valid scaling routines (can be combined by bitwise OR):\n";
print  "   GLP_SF_GM perform geometric mean scaling: ", &Math::GLPK::Base::GLP_SF_GM , "\n";
print  "   GLP_SF_EQ perform equilibration scaling: ", &Math::GLPK::Base::GLP_SF_EQ , "\n";
print  "   GLP_SF_2N round scale factors to nearest power of two: ", &Math::GLPK::Base::GLP_SF_2N , "\n";
print  "   GLP_SF_SKIP skip scaling, if the problem is well scaled: ", &Math::GLPK::Base::GLP_SF_SKIP , "\n";
print  "   GLP_SF_AUTO routine chooses the scaling options automatically: ", &Math::GLPK::Base::GLP_SF_SKIP , "\n";
$lp->scale_prob(&Math::GLPK::Base::GLP_SF_GM | &Math::GLPK::Base::GLP_SF_2N);
$lp->unscale_prob();
###############################################################################


################################################################################
# GLP_BS make the column basic;
# GLP_NL make the column non-basic;
# GLP_NU make the column non-basic and set it to the upper bound; if
# the column is not double-bounded, this status is equivalent to
# GLP_NL (only in the case of this routine);
# GLP_NF the same as GLP_NL (only in the case of this routine);
# GLP_NS the same as GLP_NL (only in the case of this routine).
################################################################################
$lp->set_row_stat(1, &Math::GLPK::Base::GLP_BS);
$lp->set_col_stat(2, &Math::GLPK::Base::GLP_BS);
################################################################################


################################################################################
################################################################################
print "mip value of row 1: ", $lp->mip_row_val(1), "\n";
print "mip value of col 2: ", $lp->mip_col_val(2), "\n";
################################################################################


################################################################################
################################################################################
$lp->std_basis();
$lp->adv_basis();
$lp->cpx_basis();
################################################################################


################################################################################
# delele some rows and columns
################################################################################
# delete first row
$lp->del_rows([1]);
# delete second column
$lp->del_cols([2]);
# to delete row 1, 7, and 9
# $lp->del_rows([1,7,9]);
################################################################################


################################################################################
# write reduce system to file
################################################################################
my $filename = "/tmp/myGLPK_reduced.lp";
print "INFO: going to write lp-file '$filename'\n";
die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);
################################################################################


################################################################################
################################################################################
die "ERROR: free() failed\n" unless $lp->free();
die "ERROR: close() failed\n" unless $glpk_env->close();
################################################################################
