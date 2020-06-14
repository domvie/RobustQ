package Math::GLPK::Base;

use 5.014002;
use strict;
use warnings;

use Carp;
use AutoLoader;
# require Exporter;
require XSLoader;

our @ISA = qw(Exporter);
our $AUTOLOAD;
our $VERSION = '0.01';

# our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = ( );

################################################################################
################################################################################
sub get_all_GLPK_consts
{
   my @consts = get_iv_GLPK_consts();

   push @consts,  get_nv_GLPK_consts();

   return @consts;
}
################################################################################

XSLoader::load('Math::GLPK::Base', $VERSION);

sub AUTOLOAD {
    my $constname;
    our $AUTOLOAD;

    # strip the package name from requested function
    ($constname = $AUTOLOAD) =~ s/.*:://;

    my ($error_iv, $error_nv, $val);

    # first try GLPK integer constants
    ($error_iv, $val) = iv_constant($constname);
    if( $error_iv )
    {
       # it was not an integer constant -> try double constants
       ($error_nv, $val) = nv_constant($constname);

       # die if constant couldn't be found
       if( $error_nv ){ croak $error_iv . "\n" . $error_nv };
    }

    {
       # create new subroutine with the name of the requested constant name
       # and return the obtained value -> that's more efficient 
       no strict 'refs';
       *$AUTOLOAD = sub() { $val };
    }

    goto &$AUTOLOAD;
}


################################################################################
# currently, there are not GLPK constants of type 'numerical value'
################################################################################
sub get_nv_GLPK_consts
{
   my @consts = qw();

   return @consts;
}
################################################################################


################################################################################
################################################################################
sub get_iv_GLPK_consts
{
   my @consts = qw(
   GLP_MAJOR_VERSION
   GLP_MINOR_VERSION
   GLP_MIN
   GLP_MAX
   GLP_CV
   GLP_IV
   GLP_BV
   GLP_FR
   GLP_LO
   GLP_UP
   GLP_DB
   GLP_FX
   GLP_BS
   GLP_NL
   GLP_NU
   GLP_NF
   GLP_NS
   GLP_SF_GM
   GLP_SF_EQ
   GLP_SF_2N
   GLP_SF_SKIP
   GLP_SF_AUTO
   GLP_SOL
   GLP_IPT
   GLP_MIP
   GLP_UNDEF
   GLP_FEAS
   GLP_INFEAS
   GLP_NOFEAS
   GLP_OPT
   GLP_UNBND
   GLP_BF_FT
   GLP_BF_BG
   GLP_BF_GR
   GLP_MSG_OFF
   GLP_MSG_ERR
   GLP_MSG_ON
   GLP_MSG_ALL
   GLP_MSG_DBG
   GLP_PRIMAL
   GLP_DUALP
   GLP_DUAL
   GLP_PT_STD
   GLP_PT_PSE
   GLP_RT_STD
   GLP_RT_HAR
   GLP_ORD_NONE
   GLP_ORD_QMD
   GLP_ORD_AMD
   GLP_ORD_SYMAMD
   GLP_BR_FFV
   GLP_BR_LFV
   GLP_BR_MFV
   GLP_BR_DTH
   GLP_BR_PCH
   GLP_BT_DFS
   GLP_BT_BFS
   GLP_BT_BLB
   GLP_BT_BPH
   GLP_PP_NONE
   GLP_PP_ROOT
   GLP_PP_ALL
   GLP_RF_REG
   GLP_RF_LAZY
   GLP_RF_CUT
   GLP_RF_GMI
   GLP_RF_MIR
   GLP_RF_COV
   GLP_RF_CLQ
   GLP_ON
   GLP_OFF
   GLP_IROWGEN
   GLP_IBINGO
   GLP_IHEUR
   GLP_ICUTGEN
   GLP_IBRANCH
   GLP_ISELECT
   GLP_IPREPRO
   GLP_NO_BRNCH
   GLP_DN_BRNCH
   GLP_UP_BRNCH
   GLP_EBADB
   GLP_ESING
   GLP_ECOND
   GLP_EBOUND
   GLP_EFAIL
   GLP_EOBJLL
   GLP_EOBJUL
   GLP_EITLIM
   GLP_ETMLIM
   GLP_ENOPFS
   GLP_ENODFS
   GLP_EROOT
   GLP_ESTOP
   GLP_EMIPGAP
   GLP_ENOFEAS
   GLP_ENOCVG
   GLP_EINSTAB
   GLP_EDATA
   GLP_ERANGE
   GLP_KKT_PE
   GLP_KKT_PB
   GLP_KKT_DE
   GLP_KKT_DB
   GLP_KKT_CS
   GLP_MPS_DECK
   GLP_MPS_FILE
   GLP_ASN_MIN
   GLP_ASN_MAX
   GLP_ASN_MMP
   LPX_LP
   LPX_MIP
   LPX_FR
   LPX_LO
   LPX_UP
   LPX_DB
   LPX_FX
   LPX_MIN
   LPX_MAX
   LPX_P_UNDEF
   LPX_P_FEAS
   LPX_P_INFEAS
   LPX_P_NOFEAS
   LPX_D_UNDEF
   LPX_D_FEAS
   LPX_D_INFEAS
   LPX_D_NOFEAS
   LPX_BS
   LPX_NL
   LPX_NU
   LPX_NF
   LPX_NS
   LPX_T_UNDEF
   LPX_T_OPT
   LPX_CV
   LPX_IV
   LPX_I_UNDEF
   LPX_I_OPT
   LPX_I_FEAS
   LPX_I_NOFEAS
   LPX_OPT
   LPX_FEAS
   LPX_INFEAS
   LPX_NOFEAS
   LPX_UNBND
   LPX_UNDEF
   LPX_E_OK
   LPX_E_EMPTY
   LPX_E_BADB
   LPX_E_INFEAS
   LPX_E_FAULT
   LPX_E_OBJLL
   LPX_E_OBJUL
   LPX_E_ITLIM
   LPX_E_TMLIM
   LPX_E_NOFEAS
   LPX_E_INSTAB
   LPX_E_SING
   LPX_E_NOCONV
   LPX_E_NOPFS
   LPX_E_NODFS
   LPX_E_MIPGAP
   LPX_K_MSGLEV
   LPX_K_SCALE
   LPX_K_DUAL
   LPX_K_PRICE
   LPX_K_RELAX
   LPX_K_TOLBND
   LPX_K_TOLDJ
   LPX_K_TOLPIV
   LPX_K_ROUND
   LPX_K_OBJLL
   LPX_K_OBJUL
   LPX_K_ITLIM
   LPX_K_ITCNT
   LPX_K_TMLIM
   LPX_K_OUTFRQ
   LPX_K_OUTDLY
   LPX_K_BRANCH
   LPX_K_BTRACK
   LPX_K_TOLINT
   LPX_K_TOLOBJ
   LPX_K_MPSINFO
   LPX_K_MPSOBJ
   LPX_K_MPSORIG
   LPX_K_MPSWIDE
   LPX_K_MPSFREE
   LPX_K_MPSSKIP
   LPX_K_LPTORIG
   LPX_K_PRESOL
   LPX_K_BINARIZE
   LPX_K_USECUTS
   LPX_K_BFTYPE
   LPX_K_MIPGAP
   LPX_C_COVER
   LPX_C_CLIQUE
   LPX_C_GOMORY
   LPX_C_MIR
   LPX_C_ALL
   );
   return @consts;
}
################################################################################

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Math::GLPK::Base - Perl extension that allows access to many of the
functions and constants of GLPK's C library.

=head1 SYNOPSIS

  use Math::GLPK::Base;

  # get all GLPK constants supported by Math::GLPK::Base
  @glpk_constants = &Math::GLPK::Base::get_all_GLPK_consts();
  print "all supported GLPK constants @glpk_constants\n";

  # get value for the GLPK constant GLP_OPT
  my $glp_opt_status = &Math::GLPK::Base::GLP_OPT

=head1 DESCRIPTION

This module provides access to many of the functions and constants
of GLPK's C library. It is assumed that the methods of Math::GLPK::Base
are called via the object oriented Perl modules Math::GLPK::EnvSimplex,
Math::GLPK::EnvIpt, Math::GLPK::EnvMip, Math::GLPK::LP, Math::GLPK::LPSimplex,
Math::GLPK::LPIpt, and Math::GLPK::LPMip.

This module was developed and tested with GLPK version 4.45.

=head2 EXPORT

None by default.

=head2 get_all_GLPK_consts

Get a list of all GLPK constants that can be accessed via this module

  @all_consts = Math::GLPK::Base::get_all_GLPK_consts();

=head2 get_iv_GLPK_consts

Get a list of all GLPK integer constants that can be accessed via this module

  @all_int_consts = Math::GLPK::Base::get_iv_GLPK_consts();

=head2 get_nv_GLPK_consts

Get a list of all GLPK numerical constants that can be accessed via this module

  @all_num_consts = Math::GLPK::Base::get_nv_GLPK_consts();

=head2 GLPK constants

GLPK heavily relies on constants for setting parameters and evaluating
the optimization status. Math::GLPK allows to access these constants via
methods that are provided by an C<AUTOLOAD> function of the module Math::GLPK::Base.
Hence, GLPK constants can be accessed as follows:

  my $opt_status = &Math::GLPK::Base::GLP_OPT;
  my $on_switch  = &Math::GLPK::Base::GLP_ON;

Access to the following GLPK constants are supported by Math::GLPK::Base:

   GLP_MAJOR_VERSION GLP_MINOR_VERSION GLP_MIN GLP_MAX GLP_CV GLP_IV GLP_BV GLP_FR
   GLP_LO GLP_UP GLP_DB GLP_FX GLP_BS GLP_NL GLP_NU GLP_NF GLP_NS GLP_SF_GM GLP_SF_EQ
   GLP_SF_2N GLP_SF_SKIP GLP_SF_AUTO GLP_SOL GLP_IPT GLP_MIP GLP_UNDEF GLP_FEAS
   GLP_INFEAS GLP_NOFEAS GLP_OPT GLP_UNBND GLP_BF_FT GLP_BF_BG GLP_BF_GR GLP_MSG_OFF
   GLP_MSG_ERR GLP_MSG_ON GLP_MSG_ALL GLP_MSG_DBG GLP_PRIMAL GLP_DUALP GLP_DUAL GLP_PT_STD
   GLP_PT_PSE GLP_RT_STD GLP_RT_HAR GLP_ORD_NONE GLP_ORD_QMD GLP_ORD_AMD GLP_ORD_SYMAMD
   GLP_BR_FFV GLP_BR_LFV GLP_BR_MFV GLP_BR_DTH GLP_BR_PCH GLP_BT_DFS GLP_BT_BFS
   GLP_BT_BLB GLP_BT_BPH GLP_PP_NONE GLP_PP_ROOT GLP_PP_ALL GLP_RF_REG GLP_RF_LAZY
   GLP_RF_CUT GLP_RF_GMI GLP_RF_MIR GLP_RF_COV GLP_RF_CLQ GLP_ON GLP_OFF GLP_IROWGEN
   GLP_IBINGO GLP_IHEUR GLP_ICUTGEN GLP_IBRANCH GLP_ISELECT GLP_IPREPRO GLP_NO_BRNCH
   GLP_DN_BRNCH GLP_UP_BRNCH GLP_EBADB GLP_ESING GLP_ECOND GLP_EBOUND GLP_EFAIL
   GLP_EOBJLL GLP_EOBJUL GLP_EITLIM GLP_ETMLIM GLP_ENOPFS GLP_ENODFS GLP_EROOT GLP_ESTOP
   GLP_EMIPGAP GLP_ENOFEAS GLP_ENOCVG GLP_EINSTAB GLP_EDATA GLP_ERANGE GLP_KKT_PE
   GLP_KKT_PB GLP_KKT_DE GLP_KKT_DB GLP_KKT_CS GLP_MPS_DECK GLP_MPS_FILE GLP_ASN_MIN
   GLP_ASN_MAX GLP_ASN_MMP LPX_LP LPX_MIP LPX_FR LPX_LO LPX_UP LPX_DB LPX_FX LPX_MIN
   LPX_MAX LPX_P_UNDEF LPX_P_FEAS LPX_P_INFEAS LPX_P_NOFEAS LPX_D_UNDEF LPX_D_FEAS
   LPX_D_INFEAS LPX_D_NOFEAS LPX_BS LPX_NL LPX_NU LPX_NF LPX_NS LPX_T_UNDEF LPX_T_OPT
   LPX_CV LPX_IV LPX_I_UNDEF LPX_I_OPT LPX_I_FEAS LPX_I_NOFEAS LPX_OPT LPX_FEAS
   LPX_INFEAS LPX_NOFEAS LPX_UNBND LPX_UNDEF LPX_E_OK LPX_E_EMPTY LPX_E_BADB LPX_E_INFEAS
   LPX_E_FAULT LPX_E_OBJLL LPX_E_OBJUL LPX_E_ITLIM LPX_E_TMLIM LPX_E_NOFEAS LPX_E_INSTAB
   LPX_E_SING LPX_E_NOCONV LPX_E_NOPFS LPX_E_NODFS LPX_E_MIPGAP LPX_K_MSGLEV LPX_K_SCALE
   LPX_K_DUAL LPX_K_PRICE LPX_K_RELAX LPX_K_TOLBND LPX_K_TOLDJ LPX_K_TOLPIV LPX_K_ROUND
   LPX_K_OBJLL LPX_K_OBJUL LPX_K_ITLIM LPX_K_ITCNT LPX_K_TMLIM LPX_K_OUTFRQ LPX_K_OUTDLY
   LPX_K_BRANCH LPX_K_BTRACK LPX_K_TOLINT LPX_K_TOLOBJ LPX_K_MPSINFO LPX_K_MPSOBJ
   LPX_K_MPSORIG LPX_K_MPSWIDE LPX_K_MPSFREE LPX_K_MPSSKIP LPX_K_LPTORIG LPX_K_PRESOL
   LPX_K_BINARIZE LPX_K_USECUTS LPX_K_BFTYPE LPX_K_MIPGAP LPX_C_COVER LPX_C_CLIQUE
   LPX_C_GOMORY LPX_C_MIR LPX_C_ALL

=head1 SEE ALSO

For further details about calling GLPK functions refer to the GLPK documention.

=head1 AUTHOR

Christian Jungreuthmayer, E<lt>christian.jungreuthmayer@boku.ac.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Christian Jungreuthmayer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
