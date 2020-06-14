################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Mon Nov 18 12:13:12 CET 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Test::More tests => 32;
BEGIN { use_ok('Math::GLPK::Base') };
BEGIN { use_ok('Math::GLPK::LPMip') };
BEGIN { use_ok('Math::GLPK::EnvMip') };

# create GLPK MIP environment
my $glpk_env = Math::GLPK::EnvMip->new();
isa_ok( $glpk_env, 'Math::GLPK::EnvMip');

# turn presolve on
$glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON);
ok( $glpk_env->get_presolve() == &Math::GLPK::Base::GLP_ON, "turning on presolve" );

# getMIP problem
my $lp = $glpk_env->createLP();
isa_ok( $lp, 'Math::GLPK::LPMip');

# set objective direction
ok( $lp->maximize(), "setting objective direction to 'maximize'" );

# check if set objective direction was successful
ok( $lp->get_obj_dir() == &Math::GLPK::Base::GLP_MAX, "checking objective direction" );


# define columns
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
ok( $lp->newcols($cols) , "adding columns" );

# add rows
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
ok( $lp->addrows($rows), "adding rows" );

# test some of the setting methods
# objective name
my $obj_name_set = 'myObective';
ok( $lp->set_obj_name($obj_name_set), "setting objective name" );
ok( $lp->get_obj_name() eq $obj_name_set, "getting new objective name" );
# row name
ok( $lp->set_row_name(1, "Flying Spaghetti Monster"), "setting row name" );
ok( $lp->get_row_name(1) eq "Flying Spaghetti Monster", "getting row name" );
# column name
ok( $lp->set_col_name(2, "newName"), "setting row name" );
ok( $lp->get_col_name(2) eq "newName", "getting row name" );
# problem name
ok( $lp->set_prob_name("greatProb"), "setting problem name" );
ok( $lp->get_prob_name() eq "greatProb", "getting problem name" );

# get info about MIP problem
# number of integer variables
ok( $lp->get_num_rows() == 2, "checking number of rows" );
ok( $lp->get_num_cols() == 2, "checking number of columns" );
ok( $lp->get_num_int()  == 1, "checking number of integer variables" );
ok( $lp->get_num_bin()  == 0, "checking number of binary variables" );
ok( $lp->get_num_nz()   == 4, "checking number of non-zero constraint coefficients" );

# solve problem using mip solver
ok( $lp->intopt, "solving problem using MIP solver" );

# checking MIP status
ok( $lp->mip_status() == &Math::GLPK::Base::GLP_OPT, "checking MIP status" );
ok( $lp->mip_obj_val() < 0.25001, "checking objective value" );
ok( $lp->mip_obj_val() > 0.24999, "checking objective value" );

ok( $lp->mip_col_val(1) == 0, "checking value of column/variable 1" );
ok( $lp->mip_col_val(2) < 0.50001, "checking value of column/variable 2" );
ok( $lp->mip_col_val(2) > 0.49999, "checking value of column/variable 2" );


# free/close resources
ok( $lp->free(), "freeing problem resources" );
ok( $glpk_env->close(), "closing GLPK environment" );
