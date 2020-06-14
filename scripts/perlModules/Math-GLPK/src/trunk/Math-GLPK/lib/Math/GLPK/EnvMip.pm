package Math::GLPK::EnvMip;

use 5.014002;
use strict;
use warnings;

use Carp;
use Math::GLPK::Base;
use Math::GLPK::LPMip;
# require Exporter;

our @ISA = qw(Exporter);
our $AUTOLOAD;
our $VERSION = '0.01';

# our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = ( );

###############################################################################
# create a new Perl Math::GLPK::EnvMip object and get GLPK environment
###############################################################################
sub new
{
   my $class = shift;
   my $self  = {};
   my $whoami = _whoami();

   # check if new() was not called for an already existing GLPK environment
   croak "$whoami: It seems that new() was already called for this object" if ref($class);

   $self->{glpk_env} = Math::GLPK::Base::_openGLPK_MIP();

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
      unless( Math::GLPK::Base::_closeGLPK_MIP($self->{glpk_env}) )
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

   unless( $lp = Math::GLPK::LPMip->new($self, $name) )
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

   return Math::GLPK::Base::_set_glp_iocp_msg_level($self->{glpk_env}, $level);
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

   return Math::GLPK::Base::_get_glp_iocp_msg_level($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_br_tech
{
   my ($self, $br_tech) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new branching technique not provided" unless defined $br_tech;

   return Math::GLPK::Base::_set_glp_iocp_br_tech($self->{glpk_env}, $br_tech);
}
###############################################################################


###############################################################################
###############################################################################
sub get_br_tech
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_br_tech($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_bt_tech
{
   my ($self, $bt_tech) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new backtracking technique not provided" unless defined $bt_tech;

   return Math::GLPK::Base::_set_glp_iocp_bt_tech($self->{glpk_env}, $bt_tech);
}
###############################################################################


###############################################################################
###############################################################################
sub get_bt_tech
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_bt_tech($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_pp_tech
{
   my ($self, $pp_tech) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $pp_tech;

   return Math::GLPK::Base::_set_glp_iocp_pp_tech($self->{glpk_env}, $pp_tech);
}
###############################################################################


###############################################################################
###############################################################################
sub get_pp_tech
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_pp_tech($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_fp_heur
{
   my ($self, $fp_heur) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $fp_heur;

   return Math::GLPK::Base::_set_glp_iocp_fp_heur($self->{glpk_env}, $fp_heur);
}
###############################################################################


###############################################################################
###############################################################################
sub get_fp_heur
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_fp_heur($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_gmi_cuts
{
   my ($self, $gmi_cuts) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $gmi_cuts;

   return Math::GLPK::Base::_set_glp_iocp_gmi_cuts($self->{glpk_env}, $gmi_cuts);
}
###############################################################################


###############################################################################
###############################################################################
sub get_gmi_cuts
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_gmi_cuts($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_mir_cuts
{
   my ($self, $mir_cuts) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $mir_cuts;

   return Math::GLPK::Base::_set_glp_iocp_mir_cuts($self->{glpk_env}, $mir_cuts);
}
###############################################################################


###############################################################################
###############################################################################
sub get_mir_cuts
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_mir_cuts($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_cov_cuts
{
   my ($self, $cov_cuts) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $cov_cuts;

   return Math::GLPK::Base::_set_glp_iocp_cov_cuts($self->{glpk_env}, $cov_cuts);
}
###############################################################################


###############################################################################
###############################################################################
sub get_cov_cuts
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_cov_cuts($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_clq_cuts
{
   my ($self, $clq_cuts) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $clq_cuts;

   return Math::GLPK::Base::_set_glp_iocp_clq_cuts($self->{glpk_env}, $clq_cuts);
}
###############################################################################


###############################################################################
###############################################################################
sub get_clq_cuts
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_clq_cuts($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_tol_int
{
   my ($self, $tol_int) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $tol_int;

   return Math::GLPK::Base::_set_glp_iocp_tol_int($self->{glpk_env}, $tol_int);
}
###############################################################################


###############################################################################
###############################################################################
sub get_tol_int
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_tol_int($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_tol_obj
{
   my ($self, $tol_obj) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $tol_obj;

   return Math::GLPK::Base::_set_glp_iocp_tol_obj($self->{glpk_env}, $tol_obj);
}
###############################################################################


###############################################################################
###############################################################################
sub get_tol_obj
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_tol_obj($self->{glpk_env});
}
##############################################################################

###############################################################################
###############################################################################
sub set_mip_gap
{
   my ($self, $mip_gap) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $mip_gap;

   return Math::GLPK::Base::_set_glp_iocp_mip_gap($self->{glpk_env}, $mip_gap);
}
###############################################################################


###############################################################################
###############################################################################
sub get_mip_gap
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_mip_gap($self->{glpk_env});
}
##############################################################################


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

   return Math::GLPK::Base::_set_glp_iocp_tm_lim($self->{glpk_env}, $tm_lim);
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

   return Math::GLPK::Base::_get_glp_iocp_tm_lim($self->{glpk_env});
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

   return Math::GLPK::Base::_set_glp_iocp_out_frq($self->{glpk_env}, $out_frq);
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

   return Math::GLPK::Base::_get_glp_iocp_out_frq($self->{glpk_env});
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

   return Math::GLPK::Base::_set_glp_iocp_out_dly($self->{glpk_env}, $out_dly);
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

   return Math::GLPK::Base::_get_glp_iocp_out_dly($self->{glpk_env});
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

   return Math::GLPK::Base::_set_glp_iocp_presolve($self->{glpk_env}, $presolve);
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

   return Math::GLPK::Base::_get_glp_iocp_presolve($self->{glpk_env});
}
###############################################################################

###############################################################################
###############################################################################
sub set_binarize
{
   my ($self, $binarize) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new pricing not provided" unless defined $binarize;

   return Math::GLPK::Base::_set_glp_iocp_binarize($self->{glpk_env}, $binarize);
}
###############################################################################

###############################################################################
###############################################################################
sub get_binarize
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iocp_binarize($self->{glpk_env});
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

Math::GLPK::EnvMip - - Perl extension to create, modify, use, and
close GLPK environment objects for linear programs which use the 
GLPK's MIP solver.


=head1 SYNOPSIS

  ################################################################################
  ################################################################################
  my $glpk_env = Math::GLPK::EnvMip->new();
  die "ERROR: openGLPK() failed!" unless $glpk_env;
  print "GLPK: version: ", $glpk_env->version(), "\n";
  ################################################################################

  ################################################################################
  # activete presolving
  ################################################################################
  $glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON)
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
  # see Math::GLPK::LPMip for details
  ################################################################################

  ################################################################################
  # free/close GLPK resources
  ################################################################################
  die "ERROR: free() failed\n" unless $lp->free();
  die "ERROR: close() failed\n" unless $glpk_env->close();
  ################################################################################


=head1 DESCRIPTION

Math::GLPK::EnvMip uses Math::GLPK::Base to communicate with the GLPK C library.

=head2 EXPORT

None by default.

=head2 close
Close GLPK environment and free used GLPK resources

   $glpk_env->close();

=head2 createLP

Create a new linear problem that uses GLPK's MIP solver for optimization.

  $lp = $glpk_env->createLP();

Returns a Math::GLPK::LPMip object.

=head2 get_binarize

Get binarization option.

  $binarize = $glpk_env->get_binarize();

Returns one of the following values:
GLP_ON (replace general integer variables by binary ones),
GLP_OFF (do not use binarization).

=head2 get_br_tech

Get branching technique.

  $br_tech = $glpk_env->get_br_tech();

Returns one of the following values:
GLP_BR_FFV (first fractional variable),
GLP_BR_LFV (last fractional variable),
GLP_BR_MFV (most fractional variable),
GLP_BR_DTH (heuristic by Driebeck and Tomlin),
GLP_BR_PCH (hybrid pseudocost heuristic).

=head2 get_bt_tech

Get backtracking technique.

  $bt_tech = $glpk_env->get_bt_tech();

Returns one of the following values:
GLP_BT_DFS (depth first search),
GLP_BT_BFS (breadth first search),
GLP_BT_BLB (best local bound).
GLP_BT_BPH (best projection heuristic).

=head2 get_clq_cuts

Get clique cut option.

  $clq_cuts = $glpk_env->get_cov_cuts();

Returns one of the following values:
GLP_ON (enable generating clique cuts),
GLP_OFF (disable generating clique cuts).

=head2 get_cov_cuts

Get mixed cover cut option.

  $cov_cuts = $glpk_env->get_cov_cuts();

Returns one of the following values:
GLP_ON  (enable generating mixed cover cuts),
GLP_OFF (disable generating mixed cover cuts).

=head2 get_fp_heur

Get feasibility pump heuristic option.

  $fp_heur = $glpk_env->get_fp_heur();

Returns one of the following values:
GLP_ON  (enable applying the feasibility pump heuristic),
GLP_OFF (disable applying the feasibility pump heuristic)

=head2 get_gmi_cuts

Get Gomory's mixed integer cut option.

  $gmi_cuts = $glpk_env->get_gmi_cuts();

Returns one of the following values:
GLP_ON  (enable generating Gomory's cuts),
GLP_OFF (disable generating Gomory's cuts).

=head2 get_mip_gap

Get relative mip gap tolerance. If the relative mip gap for currently
known best integer feasible solution falls below this tolerance, the solver
terminates the search. This allows obtainig suboptimal integer feasible
solutions if solving the problem to optimality takes too long time.

  $mip_gap = $glpk_env->get_mip_gap();

=head2 get_mir_cuts

Get Mixed integer rounding (MIR) cut option.

  $mir_cuts = $glpk_env->get_mir_cuts();

Returns one of the following values:
GLP_ON  (enable generating MIR cuts),
GLP_OFF (disable generating MIR cuts).

=head2 get_msg_level

Get GLPK's message level.

  my $mesg_level = $glpk_env->get_msg_level()

The method returns one of the following values:
GLP_MSG_OFF (no output), GLP_MSG_ERR (error and warning messages only),
GLP_MSG_ON (normal output), GLP_MSG_ALL (full output (including informational messages)).

=head2 get_out_dly

Get output delay (in milliseconds). This parameter specifies how long the
solver should delay sending information about the solution process to
the terminal.

  $out_delay_ms = $glpk_env->get_out_dly();

=head2 get_out_frq

Get output frequency, in iterations. This parameter specifies how frequently
the solver sends information about the solution process to the terminal.

  $out_frequency = $glpk_env->get_out_frq();

=head2 get_pp_tech

Get preprocessing technique option.

  $pp_tech = $glpk_env->get_pp_tech();

The method returns one of the following values:
GLP_PP_NONE (disable preprocessing),
GLP_PP_ROOT (perform preprocessing only on the root level),
GLP_PP_ALL  (perform preprocessing on all levels).

=head2 get_presolve

Get activation state of LP presolver.

  $presolver_state = $glpk_env->get_presolve();

Returns one of following values:
GLP_ON (enable using the LP presolver), GLP_OFF (disable using the LP presolver).

=head2 get_tm_lim

Get searching time limit (in milliseconds).

  $tm_lim = $glpk_env->get_tm_lim();

=head2 get_tol_int

Get absolute tolerance used to check if optimal solution to the current LP
relaxation is integer feasible.

  $tol_int = $glpk_env->get_tol_int();

=head2 get_tol_obj

Get relative tolerance used to check if the objective value in optimal solution
to the current LP relaxation is not better than in the best known integer
feasible solution.

  $tol_obj = $glpk_env->set_tol_obj(1e-8);

=head2 new

Constructor of Math::GLPK::EnvMip.

  $glpk_env = Math::GLPK::EnvMip->new();

=head2 set_binarize

Set binarization option (used only if the presolver is enabled).

  $old_binarize = $glpk_env->set_binarize(&Math::GLPK::Base::GLP_ON);

Returns the old value of the binarization option. Valid input paramaters
are: GLP_ON (replace general integer variables by binary ones),
GLP_OFF (do not use binarization).

=head2 set_br_tech

Set branching technique.

  $old_br_tech = $glpk_env->set_br_tech(&Math::GLPK::Base::GLP_BR_FFV);

Returns old branching technique. The following input parameters are valid:
GLP_BR_FFV (first fractional variable),
GLP_BR_LFV (last fractional variable),
GLP_BR_MFV (most fractional variable),
GLP_BR_DTH (heuristic by Driebeck and Tomlin),
GLP_BR_PCH (hybrid pseudocost heuristic).

=head2 set_bt_tech

Set backtracking technique.

  $old_bt_tech = $glpk_env->set_bt_tech(&Math::GLPK::Base::GLP_BT_DFS);

Returns the old backtracking technique. The following input parameters are valid:
GLP_BT_DFS (depth first search),
GLP_BT_BFS (breadth first search),
GLP_BT_BLB (best local bound).
GLP_BT_BPH (best projection heuristic).

=head2 set_clq_cuts

Set clique cut option.

  $old_clq_cuts = $glpk_env->set_clq_cuts(&Math::GLPK::Base::GLP_ON);

Returns the old clique cut option. The following input values are valid:
GLP_ON (enable generating clique cuts),
GLP_OFF (disable generating clique cuts).

=head2 set_cov_cuts

Set mixed cover cut option.

  $old_cov_cuts = $glpk_env->set_cov_cuts(&Math::GLPK::Base::GLP_OFF);

Returns the old cover cut option. The following input parameters are valid:
GLP_ON  (enable generating mixed cover cuts),
GLP_OFF (disable generating mixed cover cuts).

=head2 set_fp_heur

Set feasibility pump heuristic option.

  $old_fp_heur = $glpk_env->set_fp_heur(&Math::GLPK::Base::GLP_ON);

Returns the old feasibility pump heuristic option. The following input parameters are allowed:
GLP_ON  (enable applying the feasibility pump heuristic),
GLP_OFF (disable applying the feasibility pump heuristic)

=head2 set_gmi_cuts

Set Gomory's mixed integer cut option.

  $old_gmi_cuts = $glpk_env->set_gmi_cuts(&Math::GLPK::Base::GLP_ON);

Returns the old Gomory's mixed integer cut option. The following input parameters are allowed:
GLP_ON  (enable generating Gomory's cuts),
GLP_OFF (disable generating Gomory's cuts).

=head2 set_mip_gap

Set relative mip gap tolerance. If the relative mip gap for currently
known best integer feasible solution falls below this tolerance, the solver
terminates the search. This allows obtainig suboptimal integer feasible
solutions if solving the problem to optimality takes too long time.

  $old_mip_gap = $glpk_env->set_mip_gap(1e-8);

Returns the old mip gap.

=head2 set_mir_cuts

Set Mixed integer rounding (MIR) cut option.

  $old_mir_cuts = $glpk_env->set_mir_cuts(&Math::GLPK::Base::GLP_ON);

Returns the old Mixed integer rounding (MIR) cut option.
The following input parameters are valid:
GLP_ON  (enable generating MIR cuts),
GLP_OFF (disable generating MIR cuts).

=head2 set_msg_level

Set GLPK's message level

  $old_level = $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);

Returns old message level. The following input values are allowed:
GLP_MSG_OFF (no output), GLP_MSG_ERR (error and warning messages only),
GLP_MSG_ON (normal output), GLP_MSG_ALL (full output (including informational messages)).

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

=head2 set_pp_tech

Set preprocessing technique option.

  $old_pp_tech = $glpk_env->set_pp_tech(&Math::GLPK::Base::GLP_PP_NONE);

The method returns the old preprocessing technique option.
The following input parameters are valid:
GLP_PP_NONE (disable preprocessing),
GLP_PP_ROOT (perform preprocessing only on the root level),
GLP_PP_ALL  (perform preprocessing on all levels).

=head2 set_presolve

Set activation state of LP presolver.

  $old_presolver_state = $glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON);

Returns old activation state of presolver. The following parameters are valid:
GLP_ON (enable using the LP presolver), GLP_OFF (disable using the LP presolver).

=head2 set_tm_lim

Set searching time limit (in milliseconds).

  $old_tm_lim = $glpk_env->set_tm_lim(1000000);

Returns old time limit.

=head2 set_tol_int

Set absolute tolerance used to check if optimal solution to the current LP
relaxation is integer feasible.

  $old_tol_int = $glpk_env->set_tol_int(1e-7);

Returns old absolute tolerance.

=head2 set_tol_obj

Set relative tolerance used to check if the objective value in optimal solution
to the current LP relaxation is not better than in the best known integer
feasible solution.

  $old_tol_obj = $glpk_env->set_tol_obj(1e-8);

Returns old relative tolerance.

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
