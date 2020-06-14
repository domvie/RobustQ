################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Mon Nov 18 12:13:30 CET 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Test::More tests => 21;
BEGIN { use_ok('Math::GLPK::Base') };
BEGIN { use_ok('Math::GLPK::EnvSimplex') };
BEGIN { use_ok('Math::GLPK::LPSimplex') };

# get GLPK Simplex Environment
my $glpk_env = Math::GLPK::EnvSimplex->new();
isa_ok( $glpk_env, 'Math::GLPK::EnvSimplex');

# set value in smcp structe
$glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);
ok( $glpk_env->get_msg_level() == &Math::GLPK::Base::GLP_MSG_ERR, "setting GLPK message level" );

# get simplex prob
my $lp = $glpk_env->createLP();
isa_ok( $lp, 'Math::GLPK::LPSimplex');

# specify that we want to maximize objective function
ok( $lp->maximize(), "setting objective direction" );

# get some useful constants
my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
my $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable

# define columns
my $cols = { num_cols  => 2,
             obj_coefs => [ 0.6,  0.5],
             types_bnd => [ $lo,  $lo],
             lower_bnd => [ 0.0,  0.0],
             upper_bnd => [ 0.0,  0.0],
             col_names => ['c1', 'c2']};

# add columns to problem
ok($lp->newcols($cols), "adding columns" );

# define rows
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

# addd rows to problem
ok( $lp->addrows($rows), "adding rows" );

# solve problem using simplex solver
ok( $lp->simplex(), "solving problem using simplex solver" );

# check status of solution
ok( $lp->get_status() == &Math::GLPK::Base::GLP_OPT, "checking status of solution" );

# check if solver return correct objectiv value
ok( $lp->get_obj_val() < 0.46001, "checking returned objective value" );
ok( $lp->get_obj_val() > 0.45999, "checking returned objective value" );

# check values of variables
ok( $lp->get_col_prim(1) < 0.60001, "checking varialbe 1" );
ok( $lp->get_col_prim(1) > 0.59999, "checking varialbe 1" );
ok( $lp->get_col_prim(2) < 0.20001, "checking varialbe 1" );
ok( $lp->get_col_prim(2) > 0.19999, "checking varialbe 1" );

# check column names
ok ($lp->get_col_name(1) eq 'c1', "checking name of column/variable 1" );
ok ($lp->get_col_name(2) eq 'c2', "checking name of column/variable 1" );


ok( $lp->free(), "freeing problem resources" );
ok( $glpk_env->close(), "closing GLPK environment" );
