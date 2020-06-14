package Math::GLPK::LPIpt;

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
   if( ref($glpk_env) ne 'Math::GLPK::EnvIpt' )
   {
      croak "$whoami: Passed parameter is not Math::GLPK::EnvIpt: " . ref($glpk_env);
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
sub ipt_status
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_ipt_status($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub ipt_obj_val
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_ipt_obj_val($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub ipt_row_prim
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $idx;

   return Math::GLPK::Base::_ipt_row_prim($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub ipt_row_dual
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $idx;

   return Math::GLPK::Base::_ipt_row_dual($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub ipt_col_prim
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column index not provided" unless defined $idx;

   return Math::GLPK::Base::_ipt_col_prim($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub ipt_col_dual
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column index not provided" unless defined $idx;

   return Math::GLPK::Base::_ipt_col_dual($self->{lp}, $idx);
}
##############################################################################


###############################################################################
# solve linear program
###############################################################################
sub interior
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

   Math::GLPK::Base::_interior( $self->{lp}, $env );
}
###############################################################################


###############################################################################
###############################################################################
sub read_ipt
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

   Math::GLPK::Base::_read_ipt($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub write_ipt
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

   Math::GLPK::Base::_write_ipt($self->{lp}, $filename);
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
which are solved with GLPK's IPT algorithm.

=head1 SYNOPSIS

  use Math::GLPK::EnvIpt;
  use Math::GLPK::Base;

  ################################################################################
  # create new GLPK environment for an IPT problem
  ################################################################################
  my $glpk_env = Math::GLPK::EnvIpt->new();
  die "ERROR: openGLPK() failed!" unless $glpk_env;
  ################################################################################

  ################################################################################
  # create new linear program
  ################################################################################
  my $lp = $glpk_env->createLP();
  die "ERROR: couldn't create Linear Program\n" unless $lp;
  ################################################################################

  ################################################################################
  # set optimization direction to 'maximize'
  ################################################################################
  die "ERROR: maximize() failed\n" unless $lp->maximize();
  ################################################################################


  ################################################################################
  # define columns of linear problem
  ################################################################################
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
  die "ERROR: newcols() failed\n" unless $lp->newcols($cols);
  ################################################################################


  ################################################################################
  # define rows of linear problem
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
  # solve linear problem with IPT solver
  ################################################################################
  die "ERROR: interior() failed\n" unless $lp->interior();
  ################################################################################

  ################################################################################
  # get status of solution
  ################################################################################
  print "INFO: get_status returned: ", $lp->ipt_status(), "\n";
  ################################################################################

  ################################################################################
  # retrieve computed solution
  ################################################################################
  print "objective value: ", $lp->ipt_obj_val(), "\n";

  for( my $c = 1; $c <= $lp->get_num_cols; $c++ )
  {
     print "column '", $lp->get_col_name($c), "': ", $lp->ipt_col_prim($c), "\n";
  }
  ################################################################################

  ################################################################################
  # free/close GLPK resources
  ################################################################################
  die "ERROR: free() failed\n" unless $lp->free();
  die "ERROR: close() failed\n" unless $glpk_env->close();
  ################################################################################  

=head1 DESCRIPTION

Math::GLPK::LPIpt is used to create, modify, solve, and free linear programs using
GLPK's C library to solve an optimization problem with the IPT solver.
Math::GLPK::LPIpt is derived from Math::GLPK::LP which supports methods
that are shared by Math::GLPK::LPSimplex, Math::GLPK::LPIpt, and Math::GLPK::LPSMip.
Refer to the documentation of Math::GLPK::LP for further methods that can be
accessed via Math::GLPK::LPIpt objects.
Math::GLPK::LPIpt uses Math::GLPK::Base to communicate with the
GLPK C library. GLPK is a free linear programming solvers that is available
for most operating systems.
Naturally, GLPK must be installed on your system if you want to use the modules Math::GLPK.

=head2 EXPORT

None by default.

=head2 free

Free GLPK resources of the linear problem

  $lp->free();

=head2 interior

Execute LP solver based on the primaldual interior-point method.

  $lp->interior();

=head2 ipt_col_dual

Return dual value (i.e. reduced cost) of the structural variable associated
with a column

  # get dual value of third variable/column
  $dual_col_3 = $lp->ipt_col_dual(3);

=head2 ipt_col_prim

Return primal value of the structural variable associated with a column

  # get primal value of second variable/column
  $prim_col_2 = $lp->ipt_col_prim(2);

=head2 ipt_obj_val

Return computed objective value

  $obj_val = $lp->ipt_obj_val();

=head2 ipt_row_dual

Return dual value (i.e. reduced cost) of a auxiliary variable associated with a row

  # get dual value of third row
  $dual_row_3 = $lp->ipt_row_dual(3);

=head2 ipt_row_prim

Return primal value of the auxiliary variable associated with a row

  # get primal value of first row
  $prim_row_1 = $lp->ipt_row_prim();

=head2 ipt_status

Return status of a solution found by the interior-point solver as follows:
GLP_UNDEF (interior-point solution is undefined), GLP_OPT (interior-point solution is optimal),
GLP_INFEAS (interior-point solution is infeasible), GLP_NOFEAS (no feasible primal-dual solution exists).

  $ipt_status = $lp->ipt_status();

=head2 new

Constructor of the class Math::GLPK::LPIpt.
It is assumed that the constructor is called via the class Math::GLPK::EnvIpt.

  # create GLPK interior point environment
  $glpk_env = Math::GLPK::EnvIpt->new();
  
  # constructur C<new> is called via Math::GLPK::EnvIpt's method createLP
  $lp = $glpk_env->createLP();

=head2 read_ipt

Read interior-point solution from a text file

  $lp->read_ipt("ipt_solution.txt");

The method returns 0 if sucessful. The file to be read is typically written by C<write_ipt>.

=head2 write_ipt

   Write solution of an interior-point solution to file

   $lp->write_ipt("ipt_solution.txt");


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
