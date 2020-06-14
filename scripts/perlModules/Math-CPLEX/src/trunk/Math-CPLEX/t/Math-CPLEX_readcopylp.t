# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Math-CPLEX.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

# use Test::More tests => 21;
use Test::More 'no_plan';

BEGIN
{
   use_ok('Math::CPLEX::Base');
   use_ok('Math::CPLEX::Env');
   use_ok('Math::CPLEX::OP');
};

my $cplex_env = Math::CPLEX::Env->new();

isa_ok( $cplex_env, 'Math::CPLEX::Env');

################################################################################
################################################################################
my $lp = $cplex_env->createOP();
isa_ok( $lp, 'Math::CPLEX::OP' );
################################################################################


################################################################################
################################################################################
my $filename = "t/test.lp";
print "going to read file '$filename'\n";
print "INFO: going to read lp-file '$filename'\n";
ok( $lp->readcopyprob($filename), "read linear program from file '$filename'" );

$lp->writeprob($filename);
################################################################################

################################################################################
################################################################################
ok( $lp->mipopt(), "linear programming optimization" );
################################################################################


################################################################################
################################################################################
my $opti_status = &Math::CPLEX::Base::CPXMIP_OPTIMAL;
my $status = $lp->getstat();
# warn "status=$status, opti_status=$opti_status\n";
ok( $status == $opti_status, "optimization status" );

my ($sol_status, $obj_val, @vals) = $lp->solution();
# warn "obj_val=$obj_val\n";
ok( $sol_status == $opti_status, "optimization status via solution()" );
ok( $sol_status );
ok( abs($obj_val - 337) < 1e-5 , "objective value" );
################################################################################

################################################################################
################################################################################
ok( $lp->free(), "free linear program" );
ok( $cplex_env->close(), "close CPLEX environment" );
################################################################################
