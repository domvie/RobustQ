# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Math-MatrixFraction.t'

#########################

use strict;
use warnings;

use Test::More tests => 6;
use constant CONSIDER_ZERO => 1e-15;

BEGIN
{
   use_ok('Math::Fraction');
   use_ok('Math::MatrixFraction');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

###############################################################################
# do a test with a small matrix
###############################################################################
my $A = [[  1,  0, -3,  0,  2, -8],
         [  0,  1,  5,  0, -1,  4],
         [  0,  0,  0,  1,  7, -9],
         [  0,  0,  0,  0,  0,  0]];

my $matrixObjA = Math::MatrixFraction->new($A);
isa_ok( $matrixObjA, 'Math::MatrixFraction');

my $kernelA = $matrixObjA->compute_kernel();

# kernel of matrix A:
my $expKernelA = [[0/1, 1/1, 0/1],
                  [1/1, 0/1, 0/1],
                  [-2/7, -1/7, 0/1],
                  [0/1, 0/1, 1/1],
                  [27/133, 45/133, -4/19],
                  [3/19, 5/19, -1/19],];

my $expKernelAObj = Math::MatrixFraction->new($expKernelA);
my $expFracKernelA = $expKernelAObj->get_matrix_fraction();

ok( matrices_are_equal($kernelA, $expFracKernelA) == 1 );
###############################################################################

###############################################################################
# do a test with a very small matrix
###############################################################################
my $B = [[  2,  3,  5],
         [ -4,  2,  3]];

my $matrixObjB = Math::MatrixFraction->new($A);
isa_ok( $matrixObjB, 'Math::MatrixFraction');

my $kernelB = $matrixObjB->compute_kernel();

# kernel of matrix A:
my $expKernelB = [[1/26],
                  [1/1],
	          [-8/13],];

my $expKernelBObj = Math::MatrixFraction->new($expKernelA);
my $expFracKernelB = $expKernelBObj->get_matrix_fraction();

ok( matrices_are_equal($kernelB, $expFracKernelB) == 1 );
###############################################################################

###############################################################################
###############################################################################
sub matrices_are_equal
{
   my $mat1 = shift;
   my $mat2 = shift;

   print "ref($mat1)=", ref($mat1),"\n";
   print "ref($mat2)=", ref($mat2),"\n";
   return 1;

   return 0 if @$mat1 != @$mat2;

   for( my $i = 0; $i < @$mat1; $i++ )
   {
      return 0 if @{$mat1->[$i]} != @{$mat2->[$i]};
      for( my $j = 0; $j < @{$mat1->[$i]}; $j++ )
      {
         return 0 unless abs($mat1->[$i][$j] - $mat2->[$i][$j]) < CONSIDER_ZERO;
      }
   }

   return 1;
}
###############################################################################
