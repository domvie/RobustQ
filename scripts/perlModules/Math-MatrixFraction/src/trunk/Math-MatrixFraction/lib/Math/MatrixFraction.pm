package Math::MatrixFraction;

use 5.018002;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);
use Carp;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Math::MatrixFraction ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = '0.01';


# Preloaded methods go here.
use Math::Fraction;
use constant CONSIDER_ZERO => 1e-10;

###############################################################################
###############################################################################
sub new
{
   my $whoami        = _whoami();
   my $class         = shift;
   my $matrix_double = _clone_matrix(shift);
   my $consider_zero = shift || CONSIDER_ZERO;
   my $self;

   $self->{matrix_double}   = $matrix_double;
   $self->{num_rows}        = @$matrix_double;
   $self->{num_cols}        = @{$matrix_double->[0]};
   $self->{matrix_fraction} = _double2fraction($matrix_double, $consider_zero);
   $self->{consider_zero}   = $consider_zero;

   $self = bless $self, $class;
   return $self;
}
###############################################################################


###############################################################################
###############################################################################
sub new_from_fraction
{
   my $whoami          = _whoami();
   my $class           = shift;
   my $matrix_fraction = _clone_matrix(shift);
   my $consider_zero   = shift || CONSIDER_ZERO;
   my $self;

   $self->{matrix_fraction} = $matrix_fraction;
   $self->{num_rows}        = @$matrix_fraction;
   $self->{num_cols}        = @{$matrix_fraction->[0]};
   $self->{matrix_double}   = _fraction2double($matrix_fraction, $consider_zero);
   $self->{consider_zero}   = $consider_zero;

   $self = bless $self, $class;
   return $self;
}
###############################################################################


################################################################################
################################################################################
sub print_matrix_double
{
   my $self = shift;
   my $mat = $self->{matrix_double};

   for( my $r = 0; $r < @$mat; $r++ )
   {
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         # print " $mat->[$r][$c]";
         print "\t$mat->[$r][$c]";
      }
      print "\n";
   }
}
################################################################################


################################################################################
################################################################################
sub _print_matrix
{
   my $mat = shift;

   for( my $r = 0; $r < @$mat; $r++ )
   {
      # print "r=$r:";
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         # print " $mat->[$r][$c]";
         print "\t$mat->[$r][$c]";
      }
      print "\n";
   }
}
################################################################################


################################################################################
################################################################################
sub print_matrix_fraction
{
   my $self = shift;
   my $mat = $self->{matrix_fraction};

   for( my $r = 0; $r < @$mat; $r++ )
   {
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         # print " $mat->[$r][$c]";
         print "\t$mat->[$r][$c]";
      }
      print "\n";
   }
}
################################################################################


################################################################################
################################################################################
sub _clone_matrix
{
   my $mat = shift;
   my $clone = [];

   for( my $r = 0; $r < @$mat; $r++ )
   {
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         if( ref $mat->[$r][$c] eq 'Math::Fraction' )
         {
            $clone->[$r][$c] = Math::Fraction->new($mat->[$r][$c]);
         }
         else
         {
            $clone->[$r][$c] = $mat->[$r][$c];
         }
      }
   }

   return $clone;
}
################################################################################


################################################################################
# computes A x B
################################################################################
sub multiply
{
   my $self = shift;
   my $A = $self->{matrix_fraction};
   my $B = shift;
   my $C = [];

   my $whoami = _whoami();

   # if B is a Math::MatrixFraction object get fraction representation
   $B = $B->get_matrix_fraction() if ref $B eq __PACKAGE__;

   my $num_row_As = @$A;
   my $num_col_As = @{$A->[0]};
   my $num_row_Bs = @$B;
   my $num_col_Bs = @{$B->[0]};

   if( $num_col_As != $num_row_Bs )
   {
      die "ERROR: $whoami: number of columns of matrix #1 ($num_col_As) is not equal to number rows of matrix #2 ($num_row_Bs)\n"
   }

   for( my $r = 0; $r < $num_row_As; $r++ )
   {
      for( my $c = 0; $c < $num_col_Bs; $c++ )
      {
         my $sum = 0;
         for( my $i = 0; $i < $num_col_As; $i++ )
         {
            $sum += $A->[$r][$i]*$B->[$i][$c];
         }
         $C->[$r][$c] = $sum;
      }
   }

   my $Cobj = __PACKAGE__->new_from_fraction($C);
   return $Cobj;
}
################################################################################


################################################################################
################################################################################
sub get_num_rows
{
   return $_[0]->{num_rows};
}
################################################################################


################################################################################
################################################################################
sub get_num_cols
{
   return $_[0]->{num_cols};
}
################################################################################


################################################################################
################################################################################
sub get_matrix_fraction
{
   return $_[0]->{matrix_fraction};
}
################################################################################


################################################################################
################################################################################
sub get_matrix_double
{
   return $_[0]->{matrix_double};
}
################################################################################


################################################################################
################################################################################
sub compute_kernel
{
   my $self = shift;
   my $mat_frac = _clone_matrix($self->get_matrix_fraction);

   # print "before putting all zero-rows to bottom:\n";
   # _print_matrix($mat_frac);

   my $num_rows = @$mat_frac;
   my $num_cols = @{$mat_frac->[0]};

   ############################################################################
   # put all zero-rows to bottom
   ############################################################################
   my $num_zero_rows = 0;
   my $r_wk = 0;
   for( my $r = 0; $r < $num_rows; $r++ )
   {
      my $all_zero = 1;
      for( my $c = 0; $c < $num_cols; $c++ )
      {
         if( $mat_frac->[$r_wk][$c] != 0 )
         {
            $all_zero = 0;
            last;
         }
      }

      if( $all_zero )
      {
         $num_zero_rows++;
         # print "r=$r, r_wk=$r_wk - all zeros\n";
         my $row = splice @$mat_frac, $r_wk, 1;
         push @$mat_frac, $row;
      }
      else
      {
         $r_wk++;
      }
   }
   print "INFO: number of zero-rows in stoichiometric matrix: $num_zero_rows\n";
   # print "after putting all zero-rows to bottom:\n";
   # _print_matrix($mat_frac);
   ############################################################################

   $num_rows = @$mat_frac;
   my $kernel;
   ############################################################################
   # add unity matrix at the bottom of matrix we want to compute the kernel for
   ############################################################################
   for( my $r = 0; $r < $num_cols; $r++ )
   {
      for( my $c = 0; $c < $num_cols; $c++ )
      {
         my $frac;
         if( $r == $c )
         {
            $frac = frac(1, 1);
         }
         else
         {
            $frac = frac(0, 1);
         }
         $mat_frac->[$r + $num_rows][$c] = $frac;
      }
   }
   # print "added unity matrix at the bottom:\n";
   # _print_matrix($mat_frac);
   ############################################################################

   ############################################################################
   ############################################################################
   $kernel = _do_gaussian_elimination($self,$mat_frac, $num_zero_rows);
   # print "Kernel:\n";
   # _print_matrix($kernel);
   $self->_do_kernel_check($kernel);
   ############################################################################

   return $kernel;
}
################################################################################


################################################################################
################################################################################
sub _do_kernel_check
{
   my $self   = shift;
   my $kernel = shift;

   my $whoami = _whoami();

   # print "INFO: $whoami: entered.\n";

   my $multi = $self->multiply($kernel);

   # print "Matrix x Kernel:\n";
   # $multi->print_matrix_fraction();

   my $mat = $multi->get_matrix_fraction();
   for( my $r = 0; $r < @$mat; $r++ )
   {
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         die "ERROR: $whoami: kernel check failed: element [$r/$c] is not equal to zero\n" if $mat->[$r][$c] != 0;
      }
   }

   # print "INFO: $whoami: kernel check was successful\n";
}
################################################################################


################################################################################
# see: http://en.wikipedia.org/wiki/Gaussian_elimination
################################################################################
sub _do_gaussian_elimination
{
   my $self = shift;
   my $mat  = shift;
   my $num_zero_rows = shift;
   my $kernel;

   my $whoami = _whoami();

   my $orig_num_rows = $self->get_num_rows() - $num_zero_rows;
   my $orig_num_cols = $self->get_num_cols();
   my $num_rows = @$mat;
   my $num_cols = @{$mat->[0]};

   #if( $orig_num_rows > $num_cols )
   #{
   #   die "ERROR: $whoami: number of rows ($orig_num_rows) is larger than number of columns ($num_cols)\n";
   #}

   if( $orig_num_cols != $num_cols )
   {
      die "ERROR: $whoami: number of columns ($num_rows) is not equal to number of columns ($orig_num_cols) of original matrix\n";
   }

   ############################################################################
   # do the hard work of gauss elimination
   ############################################################################
   my $k_max = $orig_num_rows;
   $k_max = $num_cols if $num_cols < $k_max;

   for( my $k = 0; $k < $orig_num_rows; $k++ )
   {
      # find maximum for pivoting
      my $index_max = $k;
      my $max = abs($mat->[$k][$k]);
      for( my $i = $k + 1; $i < $num_cols; $i++ )
      {
         if( abs($mat->[$k][$i]) > $max )
         {
            $max = abs($mat->[$k][$i]);
            $index_max = $i;
         }
      }

      next if $max == 0;

      # swap columns
      for( my $i = 0; $i < @$mat; $i++ )
      {
         ($mat->[$i][$k],$mat->[$i][$index_max]) = ($mat->[$i][$index_max],$mat->[$i][$k]);
      }
      # print "after swap columns:\n";
      # _print_matrix($mat);

      # set elements to zero by addition of multiplied values
      my $tmp1 = $mat->[$k][$k];
      for( my $j = 0; $j < $num_cols; $j++ )
      {
         next if $j == $k; # do not own colum
         my $tmp2 = $mat->[$k][$j];
         for( my $i = $k; $i < $num_rows; $i++ )
         {
            $mat->[$i][$j] = $mat->[$i][$j] - $mat->[$i][$k]*$tmp2/$tmp1;
         }
      }
      for( my $i = 0; $i < $num_rows; $i++ )
      {
         $mat->[$i][$k] /= $tmp1;
      }
   }
   # print "after gauss elimination:\n";
   # _print_matrix($mat);
   ############################################################################

   ############################################################################
   # extract kernel
   ############################################################################
   my $kernel_col = 0;
   for( my $i = $num_cols - 1; $i >= 0; $i-- )
   {
      my $all_zero = 1;
      for( my $j = 0; $j < $self->get_num_rows(); $j++ )
      {
         if( $mat->[$j][$i] != 0 )
         {
            $all_zero = 0;
            last;
         }
      }

      if( $all_zero == 1 )
      {
         for( my $j = $self->get_num_rows(); $j < $num_rows; $j++ )
         {
            my $kernel_row = $j - $self->get_num_rows();
            $kernel->[$kernel_row][$kernel_col] = Math::Fraction->new($mat->[$j][$i]);
         }
         $kernel_col++;
      }
      else
      {
         next;
      }
   }
   ############################################################################

   # print "kernel ($kernel_col):\n";
   # _print_matrix($kernel);

   return $kernel;
}
################################################################################


################################################################################
################################################################################
sub _double2fraction
{
   my $mat           = shift;
   my $consider_zero = shift;
   my $mat_frac;

   for( my $r = 0; $r < @$mat; $r++ )
   {
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         my ($numer, $denom) = _double2numer_denom($mat->[$r][$c], $consider_zero);
         my $frac = frac($numer, $denom);
         $mat_frac->[$r][$c] = $frac;
      }
   }

   return $mat_frac;
}
################################################################################


################################################################################
################################################################################
sub _fraction2double
{
   my $mat = shift;
   my $consider_zero = shift;
   my $mat_double;

   for( my $r = 0; $r < @$mat; $r++ )
   {
      for( my $c = 0; $c < @{$mat->[$r]}; $c++ )
      {
         $mat_double->[$r][$c] = $mat->[$r][$c]->decimal();

         $mat_double->[$r][$c] = 0 if abs($mat_double->[$r][$c]) < $consider_zero;
      }
   }

   return $mat_double;
}
################################################################################


################################################################################
################################################################################
sub _double2numer_denom
{
   my $double = shift;
   my $consider_zero = shift;
   my $numer;
   my $denom;
   my $denom_work = 1;

   my $whoami = _whoami();
   # print "DEBUG: $whoami: input: $double\n";

   return(0,1) if abs($double) < $consider_zero;

   while( int($double*$denom_work) != $double*$denom_work )
   {
      $denom_work *= 10;
   }

   $numer = $double*$denom_work;
   $denom = $denom_work;

   # print "DEBUG: $whoami: output: numer=$numer, denom=$denom\n";
   return $numer, $denom;
}
################################################################################


###############################################################################
###############################################################################
sub _whoami
{
   ( caller(1) )[3]
}
###############################################################################


1;
__END__


=head1 NAME

Math::MatrixFraction - Perl extension to mainly compute the kernel of a matrix. 

=head1 SYNOPSIS

   use strict;
   use warnings;
   use Math::Fraction;
   use Math::MatrixFraction;

   my $A = [[  1,  0, -3,  0,  2, -8],
            [  0,  1,  5,  0, -1,  4],
            [  0,  0,  0,  1,  7, -9],
            [  0,  0,  0,  0,  0,  0]];

   # create a Math::MatrixFraction
   my $matrixObjA = Math::MatrixFraction->new($A);

   # get the fractional representation of the matrix
   # -> 2d array of Math::Fraction elements
   my $fracA = $matrixObjA->get_matrix_fraction();

   # print fractional representation
   print "A (fraction):\n";
   $matrixObjA->print_matrix_fraction();

   # print matrix using 'regular numbers'
   print "A (double):\n";
   $matrixObjA->print_matrix_double();

   # compute kernel of matrix A
   # returns a 2d array of Math::Fraction elements
   my $kernel = $matrixObjA->compute_kernel();

   # create a new Math::MatrixFraction object
   my $kernelObj = Math::MatrixFraction->new_from_fraction($kernel);

   # print kernel (fraction)
   print "Kernel (fraction):\n";
   $kernelObj->print_matrix_fraction();

   # print kernel (fraction)
   print "Kernel (double):\n";
   $kernelObj->print_matrix_double();

   # do a test if we really got the kernel of matrix A
   # A * kernel = 0
   my $resMultiObj = $matrixObjA->multiply($kernel);

   print "A x kernel (fraction):\n";
   $resMultiObj->print_matrix_fraction();

=head1 DESCRIPTION

Math::MatrixFraction is a module that is mainly used to compute the kernel of a matrix.
Math::MatrixFraction uses Math::Fraction for the kernel computation to avoid problems
that could be caused by numerical inaccuracy.

=head2 EXPORT

None by default.

=head2 new

Constructor. Takes a 2-dimensional array of 'regular nummber' as input parameter.

   my $A = [[  1,  0, -3,  0,  2, -8],
         [  0,  1,  5,  0, -1,  4],
         [  0,  0,  0,  1,  7, -9],
         [  0,  0,  0,  0,  0,  0]];

   my $matrixObjA = Math::MatrixFraction->new($A);

=head2 new_from_fraction

Constructor. Takes a 2-dimensional array of 'Math::Fraction' as input parameter.

   # compute kernel of matrix A
   # returns a 2d array of Math::Fraction elements
   my $kernel = $matrixObjA->compute_kernel();

   # create a new Math::MatrixFraction object from kernel
   # which is a 2d array of Math::Fraction elements
   my $kernelObj = Math::MatrixFraction->new_from_fraction($kernel);

=head2 print_matrix_double

Print matrix using doubles for output.

   # print matrix using 'regular numbers'
   print "A (double):\n";
   $matrixObjA->print_matrix_double();

=head2 print_matrix_fraction

Print matrix using Math::Fraction for output.

   # print fractional representation
   print "A (fraction):\n";
   $matrixObjA->print_matrix_fraction();

=head2 multiply

Multiplies object with another matrix (2d array) and returns a new Math::MatrixFraction object.

   my $resMultiObj = $matrixObjA->multiply($kernel);

   print "A x kernel (fraction):\n";
   $resMultiObj->print_matrix_fraction();

=head2 get_num_rows

Get number of rows of matrix;

   my $num_rows = $matrixObjA->get_num_rows();

=head2 get_num_cols

Get number of columns of matrix;

   my $num_cols = $matrixObjA->get_num_cols();

=head2 get_matrix_fraction

Returns a reference to a 2-dimensional array containing Math::Fraction elements.

   my $frac_2d_ref = $matrixObjA->get_matrix_fraction();

=head2 get_matrix_double

Returns a reference to a 2-dimensional array containing 'regular numbers'.

   my $double_2d_ref = $matrixObjA->get_matrix_double();

=head2 compute_kernel

Computes the kernel of the matrix and returns the kernel as a 2-dimensional array of Math::Fraction elements.

   my $kernel = $matrixObjA->compute_kernel();

=head1 SEE ALSO

See the following article to get more information about the kernel of a matrix:
http://en.wikipedia.org/wiki/Kernel_%28linear_algebra%29

The kerrnel was computed by using a gaussian elemination approach.
The gaussian elimination algorithm was implemented based on the following Wikipedia article:
http://en.wikipedia.org/wiki/Gaussian_elimination

=head1 AUTHOR

Christian Jungreuthmayer, E<lt>jungreuc@gmx.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Christian Jungreuthmayer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
