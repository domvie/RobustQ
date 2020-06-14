package Math::GLPK::EnvSimplex;

use 5.014002;
use strict;
use warnings;

use Carp;
use Math::GLPK::Base;
use Math::GLPK::LPSimplex;
# require Exporter;

our @ISA = qw(Exporter);
our $AUTOLOAD;
our $VERSION = '0.01';

# our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = ( );

###############################################################################
# create a new Perl Math::GLPK::EnvSimplex object and get GLPK environment
###############################################################################
sub new
{
   my $class = shift;
   my $self  = {};
   my $whoami = _whoami();

   # check if new() was not called for an already existing GLPK environment
   croak "$whoami: It seems that new() was already called for this object" if ref($class);

   $self->{glpk_env} = Math::GLPK::Base::_openGLPK_SIMPLEX();

   # check if we could obtained a valid GLPK environment
   # and return 'undef' if we didn't
   return undef unless $self->{glpk_env};

   $self = bless $self, $class;
   return $self;
}
###############################################################################

###############################################################################
# close open GLPK environment
###############################################################################
sub close
{
   my $self = shift;
   my $whoami = _whoami();

   croak "$whoami: invalid object" unless ref($self) && $self->isa(__PACKAGE__);

   # free all attached Linear Programs
   foreach my $lp (@{$self->{lps}})
   {
      $lp->free() if defined $lp;
   }

   if( $self->{glpk_env} )
   {
      unless( Math::GLPK::Base::_closeGLPK_SIMPLEX($self->{glpk_env}) )
      {
         carp "Closing GLPK environment falied.\n";
      }
      delete $self->{glpk_env};
      return 1;
   }
   else
   {
      carp "There exists no valid GLPK environment to be closed.";
      return undef;
   }
}
###############################################################################


###############################################################################
###############################################################################
sub createLP
{
   my $self = shift;
   my $name = shift || 'perlLP';
   my $lp;
   my $whoami = _whoami();

   # check if createLP was called via an ENV package
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   unless( $lp = Math::GLPK::LPSimplex->new($self, $name) )
   {
      carp "$whoami: creating optimization problem failed";
      return undef;
   }

   push @{$self->{lps}}, $lp;

   return $lp;
}
###############################################################################


###############################################################################
###############################################################################
sub version
{
   my ($self) = @_;
   my $ret;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   return &Math::GLPK::Base::GLP_MAJOR_VERSION . '.' . &Math::GLPK::Base::GLP_MINOR_VERSION;
}
###############################################################################


###############################################################################
###############################################################################
sub _get_env
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return $self->{glpk_env};
}
###############################################################################


###############################################################################
###############################################################################
sub set_msg_level
{
   my ($self, $level) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new level not provided" unless defined $level;

   return Math::GLPK::Base::_set_glp_smcp_msg_level($self->{glpk_env}, $level);
}
###############################################################################


###############################################################################
###############################################################################
sub get_msg_level
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_msg_level($self->{glpk_env});
}
###############################################################################


###############################################################################
###############################################################################
sub set_meth
{
   my ($self, $meth) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new meth not provided" unless defined $meth;

   return Math::GLPK::Base::_set_glp_smcp_meth($self->{glpk_env}, $meth);
}
###############################################################################


###############################################################################
###############################################################################
sub get_meth
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_meth($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_pricing
{
   my ($self, $pricing) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $pricing;

   return Math::GLPK::Base::_set_glp_smcp_pricing($self->{glpk_env}, $pricing);
}
###############################################################################

###############################################################################
###############################################################################
sub get_pricing
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_pricing($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_r_test
{
   my ($self, $r_test) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $r_test;

   return Math::GLPK::Base::_set_glp_smcp_r_test($self->{glpk_env}, $r_test);
}
###############################################################################

###############################################################################
###############################################################################
sub get_r_test
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_r_test($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_tol_bnd
{
   my ($self, $tol_bnd) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $tol_bnd;

   return Math::GLPK::Base::_set_glp_smcp_tol_bnd($self->{glpk_env}, $tol_bnd);
}
###############################################################################

###############################################################################
###############################################################################
sub get_tol_bnd
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_tol_bnd($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_tol_dj
{
   my ($self, $tol_dj) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $tol_dj;

   return Math::GLPK::Base::_set_glp_smcp_tol_dj($self->{glpk_env}, $tol_dj);
}
###############################################################################

###############################################################################
###############################################################################
sub get_tol_dj
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_tol_dj($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_tol_piv
{
   my ($self, $tol_piv) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $tol_piv;

   return Math::GLPK::Base::_set_glp_smcp_tol_piv($self->{glpk_env}, $tol_piv);
}
###############################################################################

###############################################################################
###############################################################################
sub get_tol_piv
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_tol_piv($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_obj_ll
{
   my ($self, $obj_ll) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $obj_ll;

   return Math::GLPK::Base::_set_glp_smcp_obj_ll($self->{glpk_env}, $obj_ll);
}
###############################################################################

###############################################################################
###############################################################################
sub get_obj_ll
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_obj_ll($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_obj_ul
{
   my ($self, $obj_ul) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $obj_ul;

   return Math::GLPK::Base::_set_glp_smcp_obj_ul($self->{glpk_env}, $obj_ul);
}
###############################################################################

###############################################################################
###############################################################################
sub get_obj_ul
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_obj_ul($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_it_lim
{
   my ($self, $it_lim) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $it_lim;

   return Math::GLPK::Base::_set_glp_smcp_it_lim($self->{glpk_env}, $it_lim);
}
###############################################################################

###############################################################################
###############################################################################
sub get_it_lim
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_it_lim($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_tm_lim
{
   my ($self, $tm_lim) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $tm_lim;

   return Math::GLPK::Base::_set_glp_smcp_tm_lim($self->{glpk_env}, $tm_lim);
}
###############################################################################

###############################################################################
###############################################################################
sub get_tm_lim
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_tm_lim($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_out_frq
{
   my ($self, $out_frq) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $out_frq;

   return Math::GLPK::Base::_set_glp_smcp_out_frq($self->{glpk_env}, $out_frq);
}
###############################################################################

###############################################################################
###############################################################################
sub get_out_frq
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_out_frq($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_out_dly
{
   my ($self, $out_dly) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $out_dly;

   return Math::GLPK::Base::_set_glp_smcp_out_dly($self->{glpk_env}, $out_dly);
}
###############################################################################

###############################################################################
###############################################################################
sub get_out_dly
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_out_dly($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_presolve
{
   my ($self, $presolve) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $presolve;

   return Math::GLPK::Base::_set_glp_smcp_presolve($self->{glpk_env}, $presolve);
}
###############################################################################

###############################################################################
###############################################################################
sub get_presolve
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_smcp_presolve($self->{glpk_env});
}
###############################################################################


###############################################################################
###############################################################################
sub deleteLPEntry
{
   my $self = shift;
   my $lp   = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   my $i = 0;

   while( $i < @{$self->{lps}} )
   {
      if( not defined $self->{lps}[$i] )
      {
         splice @{$self->{lps}}, $i, 1;
      }
      elsif( $lp == $self->{lps}[$i] )
      {
         splice @{$self->{lps}}, $i, 1;
      }
      else
      {
         $i++;
      }
   }
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

   $self->close() if defined $self->{glpk_env};
}
###############################################################################

1;

__END__

=head1 NAME

Math::GLPK::EnvSimplex - Perl extension to create, modify, use, and
close GLPK environment objects for linear programs which use the 
GLPK's SIMPLEX solver.

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
  # set GLPK messaging level to ERR
  ################################################################################
  $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);
  ################################################################################

  ################################################################################
  # create linear problem
  ################################################################################
  my $lp = $glpk_env->createLP();
  die "ERROR: couldn't create Linear Program\n" unless $lp;
  ################################################################################

  ################################################################################
  ################################################################################
  # here is the place where:
  #   - the linear program is defined
  #   - the linear program is solved
  #   - the results of the optimization are retrieved
  #
  # see Math::GLPK::LPSimplex for details
  ################################################################################

  ################################################################################
  # free/close GLPK resources
  ################################################################################
  die "ERROR: free() failed\n" unless $lp->free();
  die "ERROR: close() failed\n" unless $glpk_env->close();
  ################################################################################

=head1 DESCRIPTION

Math::GLPK::EnvSimplex uses Math::GLPK::Base to communicate with the GLPK C library.

=head2 EXPORT

None by default.

=head2 close

Close GLPK environment and free used GLPK resources

   $glpk_env->close();

=head2 createLP

Create a new linear problem that uses GLPK's simplex solver for optimization.

  $lp = $glpk_env->createLP();

Returns a Math::GLPK::LPSimplex object.

=head2 get_it_lim

Get iteration limit 

  my $it_lim = $glpk_env->get_it_lim();

=head2 get_meth

Get simplex method used by GLPK.

  $meth = $glpk_env->get_meth();

Returns one of the following values:
GLP_PRIMAL (use two-phase primal simplex), GLP_DUAL  (use two-phase dual simplex),
GLP_DUALP  (use two-phase dual simplex, and if it fails, switch to the primal simplex).

=head2 get_msg_level

Get GLPK's message level.

  my $mesg_level = $glpk_env->get_msg_level()

The method returns one of the following values:
GLP_MSG_OFF (no output), GLP_MSG_ERR (error and warning messages only),
GLP_MSG_ON (normal output), GLP_MSG_ALL (full output (including informational messages)).

=head2 get_obj_ll

Get the lower limit of the objective function. If the objective function reaches
this limit and continues decreasing, the solver terminates the search.

  $obj_ll = $glpk_env->get_obj_ll();

=head2 get_obj_ul

Get the upper limit of the objective function. If the objective function reaches
this limit and continues increasing, the solver terminates the search.

  $obj_ll = $glpk_env->get_obj_ul();

=head2 get_out_dly

Get output delay (in milliseconds). This parameter specifies how long the
solver should delay sending information about the solution process to
the terminal.

  $out_delay_ms = $glpk_env->get_out_dly();

=head2 get_out_frq

Get output frequency, in iterations. This parameter specifies how frequently
the solver sends information about the solution process to the terminal.

  $out_frequency = $glpk_env->get_out_frq();

=head2 get_presolve

Get activation state of LP presolver.

  $presolver_state = $glpk_env->get_presolve();

Returns one of following values:
GLP_ON (enable using the LP presolver), GLP_OFF (disable using the LP presolver).

=head2 get_pricing

Get used pricing technique.

  $pricing = $glpk_env->get_pricing();

The method returns one of the following values:
GLP_PT_STD (standard (textbook)), GLP_PT_PSE (projected steepest edge).

=head2 get_r_test

Get used ratio test technique.

  $ratio_test = $glpk_env->get_r_test();

The method returns one of the following values:
GLP_RT_STD (standard (textbook)), GLP_RT_HAR (Harris' two-pass ratio test).

=head2 get_tm_lim

Get searching time limit (in milliseconds).

  $tm_lim = $glpk_env->get_tm_lim();

=head2 get_tol_bnd

Get tolerance used to check if the basic solution is primal feasible.

  $tol_bnd = $glpk_env->get_tol_bnd();

=head2 get_tol_dj

Get tolerance used to check if the basic solution is dual feasible.

  $tol_bnd = $glpk_env->get_tol_dj();

=head2 get_tol_piv

Get tolerance used to choose eligble pivotal elements of the simplex table.

  $tol_piv = $glpk_env->get_tol_piv();

=head2 new

Constructor of Math::GLPK::EnvSimplex.

  $glpk_env = Math::GLPK::EnvSimplex->new();

=head2 set_it_lim

Set iteration limit

  $old_it_lim = $glpk_env->set_it_lim(1000);

Returns previous iteration limit.

=head2 set_meth

Set simplex method to be used by GLPK.

  $old_meth = $glpk_env->set_meth(&Math::GLPK::Base::GLP_DUAL);

Returns the old simplex method. The following parameters are allowed:
GLP_PRIMAL (use two-phase primal simplex), GLP_DUAL  (use two-phase dual simplex),
GLP_DUALP  (use two-phase dual simplex, and if it fails, switch to the primal simplex).

=head2 set_msg_level

Set GLPK's message level

  $old_level = $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);

Returns old message level. The following input values are allowed:
GLP_MSG_OFF (no output), GLP_MSG_ERR (error and warning messages only),
GLP_MSG_ON (normal output), GLP_MSG_ALL (full output (including informational messages)).

=head2 set_obj_ll

Set the lower limit of the objective function. If the objective function reaches
this limit and continues decreasing, the solver terminates the search.

  $old_obj_ll = $glpk_env->set_obj_ll(2.5);

=head2 set_obj_ul

Set the upper limit of the objective function. If the objective function reaches
this limit and continues increasing, the solver terminates the search.

  $old_obj_ul = $glpk_env->set_obj_ul(10.0);

Returns old upper limit of the objective function.

=head2 set_out_dly

Set output delay (in milliseconds). This parameter specifies how long the
solver should delay sending information about the solution process to
the terminal.

  $old_out_delay_ms = $glpk_env->set_out_dly(50);

Returns old output delay.

=head2 set_out_frq

Set output frequency, in iterations. This parameter specifies how frequently
the solver sends information about the solution process to the terminal.

  $old_out_frequency = $glpk_env->set_out_frq(1000);

Returns old output frequency.

=head2 set_presolve

Set activation state of LP presolver.

  $old_presolver_state = $glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON);

Returns old activation state of presolver. The following parameters are valid:
GLP_ON (enable using the LP presolver), GLP_OFF (disable using the LP presolver).

=head2 set_pricing

Set pricing technique to be used.

  $old_pricing = $glpk_env->set_pricing(&Math::GLPK::Base::GLP_PT_STD);

The method returns the old pricing technique. The following parameters are valid:
GLP_PT_STD (standard (textbook)), GLP_PT_PSE (projected steepest edge).

=head2 set_r_test

Set ratio test technique to be used.

  $old_r_test = $glpk_env->set_r_test();

Returns the old ratio test technique. The following input parameters are valid:
GLP_RT_STD (standard (textbook)), GLP_RT_HAR (Harris' two-pass ratio test).

=head2 set_tm_lim

Set searching time limit (in milliseconds).

  $old_tm_lim = $glpk_env->set_tm_lim(1000000);

Returns old time limit.

=head2 set_tol_bnd

Set tolerance used to check if the basic solution is primal feasible.

  $old_tol_bnd = $glpk_env->set_tol_bnd(1e-8);

Returns old tolerance.

=head2 set_tol_dj

Set tolerance used to check if the basic solution is dual feasible.

  $old_tol_dj = $glpk_env->set_tol_dj(1e-8);

Returns old tolerance.

=head2 set_tol_piv

Set tolerance used to choose eligble pivotal elements of the simplex table.

  $old_tol_piv = $glpk_env->set_tol_piv(1e-11);

Returns old tolerance.

=head2 version

Returns version of used GLPK installation

  my $version = glpk_env->version();

=head1 SEE ALSO

Valuable information about the supported GLPK functions can be found in
the GLPK documentation.

=head1 AUTHOR

Christian Jungreuthmayer, E<lt>christian.jungreuthmayer@boku.ac.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Christian Jungreuthmayer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
