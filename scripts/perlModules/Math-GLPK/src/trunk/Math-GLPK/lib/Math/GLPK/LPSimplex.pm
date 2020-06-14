package Math::GLPK::LPSimplex;

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
   if( ref($glpk_env) ne 'Math::GLPK::EnvSimplex' )
   {
      croak "$whoami: Passed parameter is not Math::GLPK::EnvSimplex: " . ref($glpk_env);
   }

   $self->{lp} = Math::GLPK::Base::_createLP($lp_name);

   # check if we could obtained a valid GLPK environment
   # and return 'undef' if we didn't
   return undef unless $self->{lp};

   $self->{glpk_env} = $glpk_env;
   $self->{lp_name}  = $lp_name;

   $self = bless $self, $class;
   return $self;
}
###############################################################################


###############################################################################
###############################################################################
sub get_status
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_status($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub get_prim_stat
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_prim_stat($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub get_dual_stat
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_dual_stat($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub get_obj_val
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_obj_val($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub get_row_stat
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_stat($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub get_row_prim
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_prim($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub get_row_dual
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_dual($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub get_col_stat
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column index not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_stat($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub get_col_prim
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column index not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_prim($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub get_col_dual
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column index not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_dual($self->{lp}, $idx);
}
##############################################################################


###############################################################################
###############################################################################
sub get_unbnd_ray
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_unbnd_ray($self->{lp});
}
##############################################################################


###############################################################################
# solve linear program
###############################################################################
sub simplex
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

   Math::GLPK::Base::_simplex( $self->{lp}, $env );
}
###############################################################################


###############################################################################
# solve linear program - exact
###############################################################################
sub exact
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

   Math::GLPK::Base::_exact( $self->{lp}, $env );
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

Math::GLPK::LPSimplex - Perl extension that handles linear programs
which are solved with GLPK's SIMPLEX algorithm.

=head1 SYNOPSIS

  use Math::GLPK::EnvSimplex;
  use Math::GLPK::Base;

  ################################################################################
  ################################################################################
  my $glpk_env = Math::GLPK::EnvSimplex->new();
  die "ERROR: openGLPK() failed!" unless $glpk_env;
  print "GLPK: version: ", $glpk_env->version(), "\n";
  ################################################################################

  ################################################################################
  # set GLPK's messaging level to ERR
  ################################################################################
  $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);
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
  # define columns of simplex problem
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
  # define rows of simplex problem
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
  # write linear problem to file
  ################################################################################
  my $filename = "/tmp/myGLPK.lp";
  print "INFO: going to write lp-file '$filename'\n";
  die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);
  ################################################################################

  ################################################################################
  # solve linear problem
  ################################################################################
  die "ERROR: simplex() failed\n" unless $lp->simplex();
  # die "ERROR: exact() failed\n" unless $lp->exact();
  ################################################################################

  ################################################################################
  # get status of solution
  ################################################################################
  print "INFO: get_status returned: ", $lp->get_status(), "\n";
  ################################################################################

  ################################################################################
  # write solution to file
  ################################################################################
  $filename = "/tmp/solution.txt";
  print "INFO: write solution to $filename\n";
  die "ERROR: write_sol() failed\n" unless $lp->write_sol($filename);
  ################################################################################
  ################################################################################

  ################################################################################
  # retrieve computed solution
  ################################################################################
  print "objective value: ", $lp->get_obj_val(), "\n";

  for( my $c = 1; $c <= $lp->get_num_cols; $c++ )
  {
     print "column '", $lp->get_col_name($c), "': ", $lp->get_col_prim($c), "\n";
  }
  ################################################################################

=head1 DESCRIPTION

Math::GLPK::LPSimplex is used to create, modify, solve, and free linear programs using
GLPK's C library to solve an optimization problem with the SIMPLEX solver.
Math::GLPK::LPSimplex is derived from Math::GLPK::LP which supports methods
that are shared by Math::GLPK::LPSimplex, Math::GLPK::LPIpt, and Math::GLPK::LPSMip.
Refer to the documentation of Math::GLPK::LP for methods that can be
accessed via Math::GLPK::LPSimplex objects.
Math::GLPK::LPSimplex uses Math::GLPK::Base to communicate with the
GLPK C library. GLPK is a free linear programming solver toolbox that is available
for most operating systems.
Naturally, GLPK must be installed on your system if you
want to use the module Math::GLPK.

=head2 EXPORT

None by default.

=head2 exact

Solve the optimization problem with a tentative implementation of the primal two phase
simplex method based on exact. The solver is similar to the GLPK simplex solver.
However, for all internal computations C<exact> uses arithmetic of rational numbers,
which is exact in mathematical sense, i.e. free of rounding errors.

  $lp->exact();

Returns C<undef> if execution was not successful.

=head2 free

Free GLPK resources of linear problem.

  $lp->free();

=head2 get_col_dual

Return dual value (i.e. reduced cost) of the structural variable associated with a column.

  # get dual value of third column
  $col_dual_3 = $lp->get_col_dual(3);

=head2 get_col_prim

Return primal value of the structural variable associated with a column.

  # get primal value of second column
  $col_prim_2 = $lp->get_col_prim(2);

=head2 get_col_stat

Return current status assigned to the structural variable associated with a column

  # get state of first column
  $col_state_1 = $lp->get_col_stat(1);

The method returns one of the following values: GLP_BS (basic variable),
GLP_NL (non-basic variable on its lower bound), GLP_NU (non-basic variable on its upper bound),
GLP_NF (non-basic free (unbounded) variable), GLP_NS (non-basic fixed variable).

=head2 get_dual_stat

Returns the status of the dual basic solution

  $dual_stat = $lp->get_dual_stat();

The method returns one of the following values: GLP_UNDEF (dual solution is undefined),
GLP_FEAS (dual solution is feasible), GLP_INFEAS (dual solution is infeasible),
GLP_NOFEAS (no dual feasible solution exists).

=head2 get_obj_val

Return computed value of objective function

  $obj_val = $lp->get_obj_val();

=head2 get_prim_stat

Get the status of the primal basic solution

  $prim_stat = $lp->get_prim_stat();

The method returns one of the following values:
GLP_UNDEF (primal solution is undefined), GLP_FEAS (primal solution is feasible),
GLP_INFEAS (primal solution is infeasible), GLP_NOFEAS (no primal feasible solution exists).

=head2 get_row_dual

Get dual value (i.e. reduced cost) of the auxiliary variable associated with a row.

  # get dual values of third row
  $dual_row_3 = $lp->get_row_dual(3);

=head2 get_row_prim

Get primal value of the auxiliary variable associated with a row.

  # get primal value of sixth row
  $prim_row_6 = $lp->get_row_prim(6);

=head2 get_row_stat

Get current status assigned to the auxiliary variable associated with a row

  # get status of second row
  $row_stat = $lp->get_row_stat(2);

=head2 get_status

Get the status of the current basic solution

  $status = $lp->get_status()

The method returns one of the following values:
GLP_OPT (solution is optimal), GLP_FEAS (solution is feasible),
GLP_INFEAS (solution is infeasible), GLP_NOFEAS (problem has no feasible solution),
GLP_UNBND (problem has unbounded solution), GLP_UNDEF (solution is undefined.

=head2 get_unbnd_ray

Return the number I<k> of a variable, which causes primal or dual unboundedness.

  my $k = $lp->get_unbnd_ray();

=head2 new

Constructor of Math::GLPK::LPSimplex. It is supposed that the
constructor C<new> is executed via the method C<createLP> 
of the perl class Math::GLPK::EnvSimplex.

  # create GLPK Simplex environment
  $glpk_env = Math::GLPK::EnvSimplex->new();

  # create Simplex linear problem via Math::GLPK::EnvSimplex's createLP
  $lp = $glpk_env->createLP();


=head2 simplex

Solve the linear problem using an LP solver based on the simplex method.

  $lp->simplex();

Returns C<undef> if execution was not successful.

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
