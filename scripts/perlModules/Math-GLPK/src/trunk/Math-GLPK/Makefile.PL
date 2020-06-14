use 5.014002;
use ExtUtils::MakeMaker;
use ExtUtils::Constant;

################################################################################
# make sure we know where the GLPK files can be found
################################################################################
my $default_inc_dir = '/usr/include';
my $default_lib_dir = '/usr/lib';

print "\nMath::GLPK needs access to the GLPK header files and libraries, e.g.\n";
print "the GLPK include directory might be: $default_inc_dir\n";
print "the GLPK library directory might be: $default_lib_dir\n";

print "\nEnter GLPK include directory: ";
my $glpk_inc_dir = <STDIN>;
chomp $glpk_inc_dir;
warn "WARNING: '$glpk_inc_dir' is not a valid directory on your system\n" unless -d $glpk_inc_dir;

print "\nEnter directory where GLPK libraries (libglpk and libiloglpk) can be found: ";
my $glpk_lib_dir = <STDIN>;
chomp $glpk_lib_dir;
warn "WARNING: '$glpk_lib_dir' is not a valid directory on your system\n" unless -d $glpk_lib_dir;
print "\n";

# while developing
$glpk_inc_dir = $default_inc_dir;
$glpk_lib_dir = $default_lib_dir;
################################################################################


################################################################################
# write Makefile
################################################################################
WriteMakefile(
    NAME              => 'Math::GLPK::Base',
    VERSION_FROM      => 'lib/Math/GLPK/Base.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Math/GLPK/Base.pm', # retrieve abstract from module
       AUTHOR         => 'Christian Jungreuthmayer <christian.jungreuthmayer@boku.ac.at>') : ()),
    LIBS              => ["-L$glpk_lib_dir -lm -lglpk"], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => "-I. -I$glpk_inc_dir", # e.g., '-I. -I/usr/include/other'
    # Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
################################################################################

################################################################################
# write xs and c include files
################################################################################
ExtUtils::Constant::WriteConstants(
   NAME         => 'Math::GLPK::Base',
   NAMES        => &get_wanted_GLPK_iv_constants(),
   DEFAULT_TYPE => 'NV',
   C_FILE       => 'const-c-iv.inc',
   XS_FILE      => 'const-xs-iv.inc',
   XS_SUBNAME   => 'iv_constant',
);

ExtUtils::Constant::WriteConstants(
   NAME         => 'Math::GLPK::Base',
   NAMES        => &get_wanted_GLPK_nv_constants(),
   DEFAULT_TYPE => 'NV',
   C_FILE       => 'const-c-nv.inc',
   XS_FILE      => 'const-xs-nv.inc',
   XS_SUBNAME   => 'nv_constant',
);
################################################################################

################################################################################
################################################################################
sub get_wanted_GLPK_nv_constants
{
   my @consts = qw();

   return \@consts;
}
################################################################################

################################################################################
################################################################################
sub get_wanted_GLPK_iv_constants
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
   return \@consts;
}
################################################################################


