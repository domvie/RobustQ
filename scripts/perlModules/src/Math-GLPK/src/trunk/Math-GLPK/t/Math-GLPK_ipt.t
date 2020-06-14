################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Mon Nov 18 12:14:05 CET 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Test::More tests => 22;

BEGIN { use_ok('Math::GLPK::Base') };
BEGIN { use_ok('Math::GLPK::EnvIpt') };
BEGIN { use_ok('Math::GLPK::LPIpt') };

# get GLPK environment
my $glpk_env = Math::GLPK::EnvIpt->new();
isa_ok( $glpk_env, 'Math::GLPK::EnvIpt' );

# test iptcp structure setting/getting
ok( $glpk_env->set_ord_alg(&Math::GLPK::Base::GLP_ORD_QMD), "setting ordering algorithm" );
ok( $glpk_env->get_ord_alg() == &Math::GLPK::Base::GLP_ORD_QMD, "checking newly set ordering algorithm" );
ok( $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR), "setting GLPK's messaging level" );
ok( $glpk_env->get_msg_level() == &Math::GLPK::Base::GLP_MSG_ERR, "checking newly set messaging level" );

# create IPT linear program
my $lp = $glpk_env->createLP();
isa_ok( $lp, 'Math::GLPK::LPIpt' );

# it is a maximizing problem
ok( $lp->maximize(), "setting objective direction to 'maximize'" );


# set columns of problem
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
             col_names => ['c1', 'c2']};
ok( $lp->newcols($cols), "setting columns of linear program" );

# set rows of problem
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
ok( $lp->addrows($rows), "setting rows of linear program" );

# solve linear program using Interior-Point Solver
ok( $lp->interior(), "solving IPT problem" );

# get solution status
ok( $lp->ipt_status() == &Math::GLPK::Base::GLP_OPT, "checking IPT status" );

# get obtained objective value
ok( $lp->ipt_obj_val() < 0.46001, "checking objective value (lt)" );
ok( $lp->ipt_obj_val() > 0.45999, "checking objective value (gt)" );

ok( $lp->ipt_col_prim(1) < 0.60001, "checking value of variable/column 1 (lt)" );
ok( $lp->ipt_col_prim(1) > 0.59999, "checking value of variable/column 1 (gt)" );
ok( $lp->ipt_col_prim(2) < 0.20001, "checking value of variable/column 2 (lt)" );
ok( $lp->ipt_col_prim(2) > 0.19999, "checking value of variable/column 2 (gt)" );


ok( $lp->free(), 'free problem resources' );
ok( $glpk_env->close(), 'close GLPK environment' );


