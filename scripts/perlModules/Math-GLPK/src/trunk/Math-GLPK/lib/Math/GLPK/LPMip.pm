package Math::GLPK::LPMip;

use 5.014002;
use strict;
use warnings;

use base qw(Exporter Math::GLPK::LP);

use Carp;
use Math::GLPK::Base;
# require Exporter;


our $AUTOLOAD;
our $VERSION = '0.01';

# our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = ( );

###############################################################################
# create a new Perl Math::GLPK::LP object and get Linear Program
###############################################################################
sub new
{
   my $whoami = _whoami();
   my $class     = shift;
   my $glpk_env = shift || croak "$whoami: no GLPK environment provided";
   my $lp_name   = shift || croak "$whoami: no LP name provided";
   my $self  = {};

   # check if new() was not called for an already existing GLPK environment
   croak "$whoami: It seems that new() was already called for this object" if ref($class);

   # check if glpk_env is really of type Math::GLPK::Env
   if( ref($glpk_env) ne 'Math::GLPK::EnvMip' )
   {
      croak "$whoami: Passed parameter is not of type Math::GLPK::EnvMip: " . ref($glpk_env);
   }

   $self->{lp} = Math::GLPK::Base::_createLP($lp_name);

   # check if we could obtained a valid GLPK environment
   # and return 'undef' if we didn't
   return undef unless $self->{lp};

   $self->{glpk_env} = $glpk_env;
   $self->{lp_name}   = $lp_name;

   $self = bless $self, $class;
   return $self;
}
###############################################################################


###############################################################################
# free Linear Program
###############################################################################
sub free
{
   my $self = shift;
   my $glpk_obj;
   my $env;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }

   my $ret = Math::GLPK::Base::_freeLP($self->{lp});

   if( $glpk_obj = $self->{glpk_env} )
   {
      # delete hash entry for Linear Program
      $glpk_obj->deleteLPEntry($self);
   }

   delete $self->{lp};

   return $ret;
}
###############################################################################



###############################################################################
###############################################################################
sub get_num_int
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_num_int($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub get_num_bin
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_num_bin($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub mip_status
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_mip_status($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub mip_obj_val
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_mip_obj_val($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub mip_row_val
{
   my ($self, $row_idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $row_idx;

   return Math::GLPK::Base::_mip_row_val($self->{lp}, $row_idx);
}
##############################################################################


###############################################################################
###############################################################################
sub mip_col_val
{
   my ($self, $col_idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column index not provided" unless defined $col_idx;

   return Math::GLPK::Base::_mip_col_val($self->{lp}, $col_idx);
}
##############################################################################


###############################################################################
# solve mixed integer problem
###############################################################################
sub intopt
{
   my $self = shift;
   my $glpk_obj;
   my $env;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }

   
   unless( $glpk_obj = $self->{glpk_env} )
   {
      carp "$whoami: Couldn't get Math::GLPK::Env object.";
      return undef;
   }
   
   unless( $env = $glpk_obj->_get_env() )
   {
      carp "$whoami: Couldn't get CPELX environment.";
      return undef;
   }

   Math::GLPK::Base::_intopt( $self->{lp}, $env );
}
###############################################################################


###############################################################################
###############################################################################
sub write_mip
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }

   Math::GLPK::Base::_write_mip($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub read_mip
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }

   Math::GLPK::Base::_read_mip($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub _whoami
{
   ( caller(1) )[3]
}
###############################################################################


###############################################################################
###############################################################################
sub DESTROY
{
   my $self = shift;

   # free Linear Program if it still exists
   $self->free() if $self->{lp};
}
###############################################################################


1;

__END__

=head1 NAME

Math::GLPK::LPMip - Perl extension that handles linear programs
which are solved with GLPK's MIP algorithm.

=head1 SYNOPSIS

  use Math::GLPK::EnvMip;
  use Math::GLPK::Base;

  ################################################################################
  ################################################################################
  my $glpk_env = Math::GLPK::EnvMip->new();
  die "ERROR: openGLPK() failed!" unless $glpk_env;
  ################################################################################

  ################################################################################
  # activate presolving
  ################################################################################
  $glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON);
  ################################################################################

  ################################################################################
  # set optimization direction to 'maximize'
  ################################################################################
  die "ERROR: maximize() failed\n" unless $lp->maximize();
  print "optimization direction flag: ", $lp->get_obj_dir(), "\n";
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
  my $cols = { num_cols  => 2,
               obj_coefs => [ 0.6,  0.5],
               types_bnd => [ $lo,  $lo],
               lower_bnd => [ 0.0,  0.0],
               upper_bnd => [ 0.0,  0.0],
               col_types => [ $iv,  $cv],
               col_names => ['c1', 'c2']};
  die "ERROR: newcols() failed\n" unless $lp->newcols($cols);
  ################################################################################



  ################################################################################
  # define rows
  ################################################################################
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
  # solve problem with MIP solver
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
  # free/close GLPK resources
  ################################################################################
  die "ERROR: free() failed\n" unless $lp->free();
  die "ERROR: close() failed\n" unless $glpk_env->close();
  ################################################################################


=head1 DESCRIPTION

Math::GLPK::LPMip is used to create, modify, solve, and free linear programs using
GLPK's C library to solve an optimization problem with the MIP solver.
Math::GLPK::LPMip is derived from Math::GLPK::LP which supports methods
that are shared by Math::GLPK::LPSimplex, Math::GLPK::LPIpt, and Math::GLPK::LPSMip.
Refer to the documentation of Math::GLPK::LP for methods that can be
accessed via Math::GLPK::LPMip objects.
Math::GLPK::LPMip uses Math::GLPK::Base to communicate with the
GLPK C library. GLPK is a free linear programming solvers that is available
for most operating systems.
Naturally, GLPK must be installed on your system if you
want to use the modules Math::GLPK.

=head2 EXPORT

None by default.

=head2 free

Free GLPK resources used by linear problem

  $lp->free();

=head2 get_num_bin

Get number of binary columns/variables of the linear problem

  $num_bin = $lp->get_num_bin();

=head2 get_num_int

Get number of integer columns/variables of the linear problem

  $num_int = $lp->get_num_int();

=head2 intopt

Solve mixed integer problem with GLPK's MIP solver

  $lp->intopt();

Returns C<undef> if execution was not successful.

=head2 mip_col_val

Get value of the structural variable associated with a column for MIP solution

  # get value of third column
  $col_val_3 = $lp->mip_col_val(3);

=head2 mip_obj_val

Return value of objective function computed by GLPK's MIP solver

  $obj_val = $lp->mip_obj_val();

=head2 mip_row_val

Get value of the structural variable associated with a row for MIP solution

  # get value of second row
  $row_val_2 = $lp->mip_row_val(2);

=head2 mip_status

Get status of solution computed by MIP solver

  $mip_status = $lp->mip_status();

The method returns one of the following values:
GLP_UNDEF (MIP solution is undefined), GLP_OPT (MIP solution is integer optimal),
GLP_FEAS (MIP solution is integer feasible, however, its optimality
(or non-optimality) has not been proven, perhaps due to premature termination of the search),
GLP_NOFEAS (problem has no integer feasible solution (proven by the solver)).

=head2 new

Constructor of Math::GLPK::LPMip. It is supposed that the
constructor C<new> is executed via the method C<createLP> 
of the perl class Math::GLPK::EnvMip.

  # create GLPK MIP environment
  $glpk_env = Math::GLPK::EnvMip->new();

  # create MIP linear problem via Math::GLPK::EnvMip's createLP
  $lp = $glpk_env->createLP();

=head2 read_mip

Read MIP solution from a text file.

  $lp->read_mip("mip_solution.txt");

Returns 0 if successful. The file to be read is typically written by C<write_mip>.

=head2 write_mip

Write the current MIP solution to a text file

  $lp->write_mip("mip_solution.txt");


=head1 SEE ALSO

Further information can be found in the GLPK documentation.

=head1 AUTHOR

Christian Jungreuthmayer, E<lt>christian.jungreuthmayer@boku.ac.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Christian Jungreuthmayer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
