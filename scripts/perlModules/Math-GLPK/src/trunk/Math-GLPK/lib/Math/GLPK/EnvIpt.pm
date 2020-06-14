package Math::GLPK::EnvIpt;

use 5.014002;
use strict;
use warnings;

use Carp;
use Math::GLPK::Base;
use Math::GLPK::LPIpt;
# require Exporter;

our @ISA = qw(Exporter);
our $AUTOLOAD;
our $VERSION = '0.01';

# our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = ( );

###############################################################################
# create a new Perl Math::GLPK::EnvIpt object and get GLPK environment
###############################################################################
sub new
{
   my $class = shift;
   my $self  = {};
   my $whoami = _whoami();

   # check if new() was not called for an already existing GLPK environment
   croak "$whoami: It seems that new() was already called for this object" if ref($class);

   $self->{glpk_env} = Math::GLPK::Base::_openGLPK_IPT();

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
      unless( Math::GLPK::Base::_closeGLPK_IPTCP($self->{glpk_env}) )
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

   unless( $lp = Math::GLPK::LPIpt->new($self, $name) )
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

   return Math::GLPK::Base::_set_glp_iptcp_msg_level($self->{glpk_env}, $level);
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

   return Math::GLPK::Base::_get_glp_iptcp_msg_level($self->{glpk_env});
}
###############################################################################


###############################################################################
###############################################################################
sub set_ord_alg
{
   my ($self, $ord_alg) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new meth not provided" unless defined $ord_alg;

   return Math::GLPK::Base::_set_glp_iptcp_ord_alg($self->{glpk_env}, $ord_alg);
}
###############################################################################


###############################################################################
###############################################################################
sub get_ord_alg
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_glp_iptcp_ord_alg($self->{glpk_env});
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

Math::GLPK::EnvIpt - Perl extension to create, modify, use, and
close GLPK environment objects for linear programs which use the
GLPK's IPT solver.

=head1 SYNOPSIS

  use Math::GLPK::EnvIpt;
  use Math::GLPK::Base;

  ################################################################################
  ################################################################################
  my $glpk_env = Math::GLPK::EnvIpt->new();
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
  # see Math::GLPK::LPIpt for details
  ################################################################################

  ################################################################################
  # free/close GLPK resources
  ################################################################################
  die "ERROR: free() failed\n" unless $lp->free();
  die "ERROR: close() failed\n" unless $glpk_env->close();
  ################################################################################

=head1 DESCRIPTION

Math::GLPK::EnvIpt uses Math::GLPK::Base to communicate with the GLPK C library.

=head2 EXPORT

None by default.

=head2 close

Close GLPK environment

  $glpk_env->close();

=head2 createLP

Create a linear problem (Math::GLPK::LPIpt) that uses GLPK's interior point algorithm (IPT)
for the optimization procedure.

  my $lp = $glpk_env->createLP();

=head2 get_msg_level

Get GLPK's message level.

  my $mesg_level = $glpk_env->get_msg_level()

The method returns one of the following values:
GLP_MSG_OFF (no output), GLP_MSG_ERR (error and warning messages only),
GLP_MSG_ON (normal output), GLP_MSG_ALL (full output (including informational messages)).

=head2 get_ord_alg

Get ordering algorithm used by GLPL prior to Cholesky factorization

  my $ord_alg = $glpk_env->get_ord_alg();

The method returns one of the following values:
GLP_ORD_NONE  (use natural (original) ordering), GLP_ORD_QMD  (quotient minimum degree (QMD)),
GLP_ORD_AMD  (approximate minimum degree (AMD)), GLP_ORD_SYMAMD (approximate minimum degree (SYMAMD)).

=head2 new

Constructor of Math::GLPK::EnvIpt

  my $glpk_env = Math::GLPK::EnvIpt->new();

=head2 set_msg_level

Set GLPK's message level

  $old_level = $glpk_env->set_msg_level(&Math::GLPK::Base::GLP_MSG_ERR);

Returns old message level. The following input values are allowed:
GLP_MSG_OFF (no output), GLP_MSG_ERR (error and warning messages only),
GLP_MSG_ON (normal output), GLP_MSG_ALL (full output (including informational messages)).

=head2 set_ord_alg

Set ordering algorithm used by GLPL prior to Cholesky factorization

  $old_ord_alg = $glpk_env->set_ord_alg(&Math::GLPK::Base::GLP_ORD_QMD);

The method returns the old ordering algorithm used. The following input values are allowed:
GLP_ORD_NONE  (use natural (original) ordering), GLP_ORD_QMD  (quotient minimum degree (QMD)),
GLP_ORD_AMD  (approximate minimum degree (AMD)), GLP_ORD_SYMAMD (approximate minimum degree (SYMAMD)).

=head2 version

Returns the version of the used GLPK installation.

  $version = $glpk_env->version();


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
