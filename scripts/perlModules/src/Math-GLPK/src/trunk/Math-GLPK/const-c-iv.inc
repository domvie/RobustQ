#define PERL_constant_NOTFOUND	1
#define PERL_constant_NOTDEF	2
#define PERL_constant_ISIV	3
#define PERL_constant_ISNO	4
#define PERL_constant_ISNV	5
#define PERL_constant_ISPV	6
#define PERL_constant_ISPVN	7
#define PERL_constant_ISSV	8
#define PERL_constant_ISUNDEF	9
#define PERL_constant_ISUV	10
#define PERL_constant_ISYES	11

#ifndef NVTYPE
typedef double NV; /* 5.6 and later define NVTYPE, and typedef NV to it.  */
#endif
#ifndef aTHX_
#define aTHX_ /* 5.6 or later define this for threading support.  */
#endif
#ifndef pTHX_
#define pTHX_ /* 5.6 or later define this for threading support.  */
#endif

static int
iv_constant_6 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_BS GLP_BV GLP_CV GLP_DB GLP_FR GLP_FX GLP_IV GLP_LO GLP_NF GLP_NL
     GLP_NS GLP_NU GLP_ON GLP_UP LPX_BS LPX_CV LPX_DB LPX_FR LPX_FX LPX_IV
     LPX_LO LPX_LP LPX_NF LPX_NL LPX_NS LPX_NU LPX_UP */
  /* Offset 5 gives the best switch position.  */
  switch (name[5]) {
  case 'B':
    if (memEQ(name, "GLP_D", 5)) {
    /*                    B     */
#ifdef GLP_DB
      *nv_return = GLP_DB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_D", 5)) {
    /*                    B     */
#ifdef LPX_DB
      *nv_return = LPX_DB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "GLP_N", 5)) {
    /*                    F     */
#ifdef GLP_NF
      *nv_return = GLP_NF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_N", 5)) {
    /*                    F     */
#ifdef LPX_NF
      *nv_return = LPX_NF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'L':
    if (memEQ(name, "GLP_N", 5)) {
    /*                    L     */
#ifdef GLP_NL
      *nv_return = GLP_NL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_N", 5)) {
    /*                    L     */
#ifdef LPX_NL
      *nv_return = LPX_NL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "GLP_O", 5)) {
    /*                    N     */
#ifdef GLP_ON
      *nv_return = GLP_ON;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'O':
    if (memEQ(name, "GLP_L", 5)) {
    /*                    O     */
#ifdef GLP_LO
      *nv_return = GLP_LO;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_L", 5)) {
    /*                    O     */
#ifdef LPX_LO
      *nv_return = LPX_LO;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "GLP_U", 5)) {
    /*                    P     */
#ifdef GLP_UP
      *nv_return = GLP_UP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_L", 5)) {
    /*                    P     */
#ifdef LPX_LP
      *nv_return = LPX_LP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_U", 5)) {
    /*                    P     */
#ifdef LPX_UP
      *nv_return = LPX_UP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'R':
    if (memEQ(name, "GLP_F", 5)) {
    /*                    R     */
#ifdef GLP_FR
      *nv_return = GLP_FR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_F", 5)) {
    /*                    R     */
#ifdef LPX_FR
      *nv_return = LPX_FR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "GLP_B", 5)) {
    /*                    S     */
#ifdef GLP_BS
      *nv_return = GLP_BS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_N", 5)) {
    /*                    S     */
#ifdef GLP_NS
      *nv_return = GLP_NS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_B", 5)) {
    /*                    S     */
#ifdef LPX_BS
      *nv_return = LPX_BS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_N", 5)) {
    /*                    S     */
#ifdef LPX_NS
      *nv_return = LPX_NS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'U':
    if (memEQ(name, "GLP_N", 5)) {
    /*                    U     */
#ifdef GLP_NU
      *nv_return = GLP_NU;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_N", 5)) {
    /*                    U     */
#ifdef LPX_NU
      *nv_return = LPX_NU;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'V':
    if (memEQ(name, "GLP_B", 5)) {
    /*                    V     */
#ifdef GLP_BV
      *nv_return = GLP_BV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_C", 5)) {
    /*                    V     */
#ifdef GLP_CV
      *nv_return = GLP_CV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_I", 5)) {
    /*                    V     */
#ifdef GLP_IV
      *nv_return = GLP_IV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_C", 5)) {
    /*                    V     */
#ifdef LPX_CV
      *nv_return = LPX_CV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_I", 5)) {
    /*                    V     */
#ifdef LPX_IV
      *nv_return = LPX_IV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'X':
    if (memEQ(name, "GLP_F", 5)) {
    /*                    X     */
#ifdef GLP_FX
      *nv_return = GLP_FX;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_F", 5)) {
    /*                    X     */
#ifdef LPX_FX
      *nv_return = LPX_FX;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_7 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_IPT GLP_MAX GLP_MIN GLP_MIP GLP_OFF GLP_OPT GLP_SOL LPX_MAX LPX_MIN
     LPX_MIP LPX_OPT */
  /* Offset 6 gives the best switch position.  */
  switch (name[6]) {
  case 'F':
    if (memEQ(name, "GLP_OF", 6)) {
    /*                     F     */
#ifdef GLP_OFF
      *nv_return = GLP_OFF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'L':
    if (memEQ(name, "GLP_SO", 6)) {
    /*                     L     */
#ifdef GLP_SOL
      *nv_return = GLP_SOL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "GLP_MI", 6)) {
    /*                     N     */
#ifdef GLP_MIN
      *nv_return = GLP_MIN;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_MI", 6)) {
    /*                     N     */
#ifdef LPX_MIN
      *nv_return = LPX_MIN;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "GLP_MI", 6)) {
    /*                     P     */
#ifdef GLP_MIP
      *nv_return = GLP_MIP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_MI", 6)) {
    /*                     P     */
#ifdef LPX_MIP
      *nv_return = LPX_MIP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'T':
    if (memEQ(name, "GLP_IP", 6)) {
    /*                     T     */
#ifdef GLP_IPT
      *nv_return = GLP_IPT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_OP", 6)) {
    /*                     T     */
#ifdef GLP_OPT
      *nv_return = GLP_OPT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_OP", 6)) {
    /*                     T     */
#ifdef LPX_OPT
      *nv_return = LPX_OPT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'X':
    if (memEQ(name, "GLP_MA", 6)) {
    /*                     X     */
#ifdef GLP_MAX
      *nv_return = GLP_MAX;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_MA", 6)) {
    /*                     X     */
#ifdef LPX_MAX
      *nv_return = LPX_MAX;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_8 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_DUAL GLP_FEAS LPX_E_OK LPX_FEAS */
  /* Offset 4 gives the best switch position.  */
  switch (name[4]) {
  case 'D':
    if (memEQ(name, "GLP_DUAL", 8)) {
    /*                   ^         */
#ifdef GLP_DUAL
      *nv_return = GLP_DUAL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'E':
    if (memEQ(name, "LPX_E_OK", 8)) {
    /*                   ^         */
#ifdef LPX_E_OK
      *nv_return = LPX_E_OK;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "GLP_FEAS", 8)) {
    /*                   ^         */
#ifdef GLP_FEAS
      *nv_return = GLP_FEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_FEAS", 8)) {
    /*                   ^         */
#ifdef LPX_FEAS
      *nv_return = LPX_FEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_9 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_BF_BG GLP_BF_FT GLP_BF_GR GLP_DUALP GLP_EBADB GLP_ECOND GLP_EDATA
     GLP_EFAIL GLP_EROOT GLP_ESING GLP_ESTOP GLP_IHEUR GLP_SF_2N GLP_SF_EQ
     GLP_SF_GM GLP_UNBND GLP_UNDEF LPX_C_ALL LPX_C_MIR LPX_I_OPT LPX_T_OPT
     LPX_UNBND LPX_UNDEF */
  /* Offset 7 gives the best switch position.  */
  switch (name[7]) {
  case '2':
    if (memEQ(name, "GLP_SF_2N", 9)) {
    /*                      ^       */
#ifdef GLP_SF_2N
      *nv_return = GLP_SF_2N;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'B':
    if (memEQ(name, "GLP_BF_BG", 9)) {
    /*                      ^       */
#ifdef GLP_BF_BG
      *nv_return = GLP_BF_BG;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'D':
    if (memEQ(name, "GLP_EBADB", 9)) {
    /*                      ^       */
#ifdef GLP_EBADB
      *nv_return = GLP_EBADB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'E':
    if (memEQ(name, "GLP_SF_EQ", 9)) {
    /*                      ^       */
#ifdef GLP_SF_EQ
      *nv_return = GLP_SF_EQ;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_UNDEF", 9)) {
    /*                      ^       */
#ifdef GLP_UNDEF
      *nv_return = GLP_UNDEF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_UNDEF", 9)) {
    /*                      ^       */
#ifdef LPX_UNDEF
      *nv_return = LPX_UNDEF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "GLP_BF_FT", 9)) {
    /*                      ^       */
#ifdef GLP_BF_FT
      *nv_return = GLP_BF_FT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'G':
    if (memEQ(name, "GLP_BF_GR", 9)) {
    /*                      ^       */
#ifdef GLP_BF_GR
      *nv_return = GLP_BF_GR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_SF_GM", 9)) {
    /*                      ^       */
#ifdef GLP_SF_GM
      *nv_return = GLP_SF_GM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'I':
    if (memEQ(name, "GLP_EFAIL", 9)) {
    /*                      ^       */
#ifdef GLP_EFAIL
      *nv_return = GLP_EFAIL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_C_MIR", 9)) {
    /*                      ^       */
#ifdef LPX_C_MIR
      *nv_return = LPX_C_MIR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'L':
    if (memEQ(name, "GLP_DUALP", 9)) {
    /*                      ^       */
#ifdef GLP_DUALP
      *nv_return = GLP_DUALP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_C_ALL", 9)) {
    /*                      ^       */
#ifdef LPX_C_ALL
      *nv_return = LPX_C_ALL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "GLP_ECOND", 9)) {
    /*                      ^       */
#ifdef GLP_ECOND
      *nv_return = GLP_ECOND;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ESING", 9)) {
    /*                      ^       */
#ifdef GLP_ESING
      *nv_return = GLP_ESING;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_UNBND", 9)) {
    /*                      ^       */
#ifdef GLP_UNBND
      *nv_return = GLP_UNBND;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_UNBND", 9)) {
    /*                      ^       */
#ifdef LPX_UNBND
      *nv_return = LPX_UNBND;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'O':
    if (memEQ(name, "GLP_EROOT", 9)) {
    /*                      ^       */
#ifdef GLP_EROOT
      *nv_return = GLP_EROOT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ESTOP", 9)) {
    /*                      ^       */
#ifdef GLP_ESTOP
      *nv_return = GLP_ESTOP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "LPX_I_OPT", 9)) {
    /*                      ^       */
#ifdef LPX_I_OPT
      *nv_return = LPX_I_OPT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_T_OPT", 9)) {
    /*                      ^       */
#ifdef LPX_T_OPT
      *nv_return = LPX_T_OPT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'T':
    if (memEQ(name, "GLP_EDATA", 9)) {
    /*                      ^       */
#ifdef GLP_EDATA
      *nv_return = GLP_EDATA;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'U':
    if (memEQ(name, "GLP_IHEUR", 9)) {
    /*                      ^       */
#ifdef GLP_IHEUR
      *nv_return = GLP_IHEUR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_10 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_BR_DTH GLP_BR_FFV GLP_BR_LFV GLP_BR_MFV GLP_BR_PCH GLP_BT_BFS
     GLP_BT_BLB GLP_BT_BPH GLP_BT_DFS GLP_EBOUND GLP_EITLIM GLP_ENOCVG
     GLP_ENODFS GLP_ENOPFS GLP_EOBJLL GLP_EOBJUL GLP_ERANGE GLP_ETMLIM
     GLP_IBINGO GLP_INFEAS GLP_KKT_CS GLP_KKT_DB GLP_KKT_DE GLP_KKT_PB
     GLP_KKT_PE GLP_MSG_ON GLP_NOFEAS GLP_PP_ALL GLP_PRIMAL GLP_PT_PSE
     GLP_PT_STD GLP_RF_CLQ GLP_RF_COV GLP_RF_CUT GLP_RF_GMI GLP_RF_MIR
     GLP_RF_REG GLP_RT_HAR GLP_RT_STD LPX_D_FEAS LPX_E_BADB LPX_E_SING
     LPX_INFEAS LPX_I_FEAS LPX_K_DUAL LPX_NOFEAS LPX_P_FEAS */
  /* Offset 7 gives the best switch position.  */
  switch (name[7]) {
  case 'A':
    if (memEQ(name, "GLP_PP_ALL", 10)) {
    /*                      ^         */
#ifdef GLP_PP_ALL
      *nv_return = GLP_PP_ALL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_BADB", 10)) {
    /*                      ^         */
#ifdef LPX_E_BADB
      *nv_return = LPX_E_BADB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'B':
    if (memEQ(name, "GLP_BT_BFS", 10)) {
    /*                      ^         */
#ifdef GLP_BT_BFS
      *nv_return = GLP_BT_BFS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_BT_BLB", 10)) {
    /*                      ^         */
#ifdef GLP_BT_BLB
      *nv_return = GLP_BT_BLB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_BT_BPH", 10)) {
    /*                      ^         */
#ifdef GLP_BT_BPH
      *nv_return = GLP_BT_BPH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'C':
    if (memEQ(name, "GLP_ENOCVG", 10)) {
    /*                      ^         */
#ifdef GLP_ENOCVG
      *nv_return = GLP_ENOCVG;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_RF_CLQ", 10)) {
    /*                      ^         */
#ifdef GLP_RF_CLQ
      *nv_return = GLP_RF_CLQ;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_RF_COV", 10)) {
    /*                      ^         */
#ifdef GLP_RF_COV
      *nv_return = GLP_RF_COV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_RF_CUT", 10)) {
    /*                      ^         */
#ifdef GLP_RF_CUT
      *nv_return = GLP_RF_CUT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'D':
    if (memEQ(name, "GLP_BR_DTH", 10)) {
    /*                      ^         */
#ifdef GLP_BR_DTH
      *nv_return = GLP_BR_DTH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_BT_DFS", 10)) {
    /*                      ^         */
#ifdef GLP_BT_DFS
      *nv_return = GLP_BT_DFS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ENODFS", 10)) {
    /*                      ^         */
#ifdef GLP_ENODFS
      *nv_return = GLP_ENODFS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'E':
    if (memEQ(name, "GLP_INFEAS", 10)) {
    /*                      ^         */
#ifdef GLP_INFEAS
      *nv_return = GLP_INFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_NOFEAS", 10)) {
    /*                      ^         */
#ifdef GLP_NOFEAS
      *nv_return = GLP_NOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_D_FEAS", 10)) {
    /*                      ^         */
#ifdef LPX_D_FEAS
      *nv_return = LPX_D_FEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_INFEAS", 10)) {
    /*                      ^         */
#ifdef LPX_INFEAS
      *nv_return = LPX_INFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_I_FEAS", 10)) {
    /*                      ^         */
#ifdef LPX_I_FEAS
      *nv_return = LPX_I_FEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_NOFEAS", 10)) {
    /*                      ^         */
#ifdef LPX_NOFEAS
      *nv_return = LPX_NOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_P_FEAS", 10)) {
    /*                      ^         */
#ifdef LPX_P_FEAS
      *nv_return = LPX_P_FEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "GLP_BR_FFV", 10)) {
    /*                      ^         */
#ifdef GLP_BR_FFV
      *nv_return = GLP_BR_FFV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'G':
    if (memEQ(name, "GLP_RF_GMI", 10)) {
    /*                      ^         */
#ifdef GLP_RF_GMI
      *nv_return = GLP_RF_GMI;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'H':
    if (memEQ(name, "GLP_RT_HAR", 10)) {
    /*                      ^         */
#ifdef GLP_RT_HAR
      *nv_return = GLP_RT_HAR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'I':
    if (memEQ(name, "LPX_E_SING", 10)) {
    /*                      ^         */
#ifdef LPX_E_SING
      *nv_return = LPX_E_SING;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'J':
    if (memEQ(name, "GLP_EOBJLL", 10)) {
    /*                      ^         */
#ifdef GLP_EOBJLL
      *nv_return = GLP_EOBJLL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_EOBJUL", 10)) {
    /*                      ^         */
#ifdef GLP_EOBJUL
      *nv_return = GLP_EOBJUL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'L':
    if (memEQ(name, "GLP_BR_LFV", 10)) {
    /*                      ^         */
#ifdef GLP_BR_LFV
      *nv_return = GLP_BR_LFV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_EITLIM", 10)) {
    /*                      ^         */
#ifdef GLP_EITLIM
      *nv_return = GLP_EITLIM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ETMLIM", 10)) {
    /*                      ^         */
#ifdef GLP_ETMLIM
      *nv_return = GLP_ETMLIM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'M':
    if (memEQ(name, "GLP_BR_MFV", 10)) {
    /*                      ^         */
#ifdef GLP_BR_MFV
      *nv_return = GLP_BR_MFV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_PRIMAL", 10)) {
    /*                      ^         */
#ifdef GLP_PRIMAL
      *nv_return = GLP_PRIMAL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_RF_MIR", 10)) {
    /*                      ^         */
#ifdef GLP_RF_MIR
      *nv_return = GLP_RF_MIR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "GLP_ERANGE", 10)) {
    /*                      ^         */
#ifdef GLP_ERANGE
      *nv_return = GLP_ERANGE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_IBINGO", 10)) {
    /*                      ^         */
#ifdef GLP_IBINGO
      *nv_return = GLP_IBINGO;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "GLP_BR_PCH", 10)) {
    /*                      ^         */
#ifdef GLP_BR_PCH
      *nv_return = GLP_BR_PCH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ENOPFS", 10)) {
    /*                      ^         */
#ifdef GLP_ENOPFS
      *nv_return = GLP_ENOPFS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_PT_PSE", 10)) {
    /*                      ^         */
#ifdef GLP_PT_PSE
      *nv_return = GLP_PT_PSE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'R':
    if (memEQ(name, "GLP_RF_REG", 10)) {
    /*                      ^         */
#ifdef GLP_RF_REG
      *nv_return = GLP_RF_REG;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "GLP_PT_STD", 10)) {
    /*                      ^         */
#ifdef GLP_PT_STD
      *nv_return = GLP_PT_STD;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_RT_STD", 10)) {
    /*                      ^         */
#ifdef GLP_RT_STD
      *nv_return = GLP_RT_STD;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'U':
    if (memEQ(name, "GLP_EBOUND", 10)) {
    /*                      ^         */
#ifdef GLP_EBOUND
      *nv_return = GLP_EBOUND;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_DUAL", 10)) {
    /*                      ^         */
#ifdef LPX_K_DUAL
      *nv_return = LPX_K_DUAL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case '_':
    if (memEQ(name, "GLP_KKT_CS", 10)) {
    /*                      ^         */
#ifdef GLP_KKT_CS
      *nv_return = GLP_KKT_CS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_KKT_DB", 10)) {
    /*                      ^         */
#ifdef GLP_KKT_DB
      *nv_return = GLP_KKT_DB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_KKT_DE", 10)) {
    /*                      ^         */
#ifdef GLP_KKT_DE
      *nv_return = GLP_KKT_DE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_KKT_PB", 10)) {
    /*                      ^         */
#ifdef GLP_KKT_PB
      *nv_return = GLP_KKT_PB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_KKT_PE", 10)) {
    /*                      ^         */
#ifdef GLP_KKT_PE
      *nv_return = GLP_KKT_PE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_MSG_ON", 10)) {
    /*                      ^         */
#ifdef GLP_MSG_ON
      *nv_return = GLP_MSG_ON;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_11 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_ASN_MAX GLP_ASN_MIN GLP_ASN_MMP GLP_EINSTAB GLP_EMIPGAP GLP_ENOFEAS
     GLP_IBRANCH GLP_ICUTGEN GLP_IPREPRO GLP_IROWGEN GLP_ISELECT GLP_MSG_ALL
     GLP_MSG_DBG GLP_MSG_ERR GLP_MSG_OFF GLP_ORD_AMD GLP_ORD_QMD GLP_PP_NONE
     GLP_PP_ROOT GLP_RF_LAZY GLP_SF_AUTO GLP_SF_SKIP LPX_C_COVER LPX_D_UNDEF
     LPX_E_EMPTY LPX_E_FAULT LPX_E_ITLIM LPX_E_NODFS LPX_E_NOPFS LPX_E_OBJLL
     LPX_E_OBJUL LPX_E_TMLIM LPX_I_UNDEF LPX_K_ITCNT LPX_K_ITLIM LPX_K_OBJLL
     LPX_K_OBJUL LPX_K_PRICE LPX_K_RELAX LPX_K_ROUND LPX_K_SCALE LPX_K_TMLIM
     LPX_K_TOLDJ LPX_P_UNDEF LPX_T_UNDEF */
  /* Offset 10 gives the best switch position.  */
  switch (name[10]) {
  case 'B':
    if (memEQ(name, "GLP_EINSTA", 10)) {
    /*                         B      */
#ifdef GLP_EINSTAB
      *nv_return = GLP_EINSTAB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'D':
    if (memEQ(name, "GLP_ORD_AM", 10)) {
    /*                         D      */
#ifdef GLP_ORD_AMD
      *nv_return = GLP_ORD_AMD;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ORD_QM", 10)) {
    /*                         D      */
#ifdef GLP_ORD_QMD
      *nv_return = GLP_ORD_QMD;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_ROUN", 10)) {
    /*                         D      */
#ifdef LPX_K_ROUND
      *nv_return = LPX_K_ROUND;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'E':
    if (memEQ(name, "GLP_PP_NON", 10)) {
    /*                         E      */
#ifdef GLP_PP_NONE
      *nv_return = GLP_PP_NONE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_PRIC", 10)) {
    /*                         E      */
#ifdef LPX_K_PRICE
      *nv_return = LPX_K_PRICE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_SCAL", 10)) {
    /*                         E      */
#ifdef LPX_K_SCALE
      *nv_return = LPX_K_SCALE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "GLP_MSG_OF", 10)) {
    /*                         F      */
#ifdef GLP_MSG_OFF
      *nv_return = GLP_MSG_OFF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_D_UNDE", 10)) {
    /*                         F      */
#ifdef LPX_D_UNDEF
      *nv_return = LPX_D_UNDEF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_I_UNDE", 10)) {
    /*                         F      */
#ifdef LPX_I_UNDEF
      *nv_return = LPX_I_UNDEF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_P_UNDE", 10)) {
    /*                         F      */
#ifdef LPX_P_UNDEF
      *nv_return = LPX_P_UNDEF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_T_UNDE", 10)) {
    /*                         F      */
#ifdef LPX_T_UNDEF
      *nv_return = LPX_T_UNDEF;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'G':
    if (memEQ(name, "GLP_MSG_DB", 10)) {
    /*                         G      */
#ifdef GLP_MSG_DBG
      *nv_return = GLP_MSG_DBG;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'H':
    if (memEQ(name, "GLP_IBRANC", 10)) {
    /*                         H      */
#ifdef GLP_IBRANCH
      *nv_return = GLP_IBRANCH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'J':
    if (memEQ(name, "LPX_K_TOLD", 10)) {
    /*                         J      */
#ifdef LPX_K_TOLDJ
      *nv_return = LPX_K_TOLDJ;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'L':
    if (memEQ(name, "GLP_MSG_AL", 10)) {
    /*                         L      */
#ifdef GLP_MSG_ALL
      *nv_return = GLP_MSG_ALL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_OBJL", 10)) {
    /*                         L      */
#ifdef LPX_E_OBJLL
      *nv_return = LPX_E_OBJLL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_OBJU", 10)) {
    /*                         L      */
#ifdef LPX_E_OBJUL
      *nv_return = LPX_E_OBJUL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_OBJL", 10)) {
    /*                         L      */
#ifdef LPX_K_OBJLL
      *nv_return = LPX_K_OBJLL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_OBJU", 10)) {
    /*                         L      */
#ifdef LPX_K_OBJUL
      *nv_return = LPX_K_OBJUL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'M':
    if (memEQ(name, "LPX_E_ITLI", 10)) {
    /*                         M      */
#ifdef LPX_E_ITLIM
      *nv_return = LPX_E_ITLIM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_TMLI", 10)) {
    /*                         M      */
#ifdef LPX_E_TMLIM
      *nv_return = LPX_E_TMLIM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_ITLI", 10)) {
    /*                         M      */
#ifdef LPX_K_ITLIM
      *nv_return = LPX_K_ITLIM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_TMLI", 10)) {
    /*                         M      */
#ifdef LPX_K_TMLIM
      *nv_return = LPX_K_TMLIM;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "GLP_ASN_MI", 10)) {
    /*                         N      */
#ifdef GLP_ASN_MIN
      *nv_return = GLP_ASN_MIN;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_ICUTGE", 10)) {
    /*                         N      */
#ifdef GLP_ICUTGEN
      *nv_return = GLP_ICUTGEN;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_IROWGE", 10)) {
    /*                         N      */
#ifdef GLP_IROWGEN
      *nv_return = GLP_IROWGEN;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'O':
    if (memEQ(name, "GLP_IPREPR", 10)) {
    /*                         O      */
#ifdef GLP_IPREPRO
      *nv_return = GLP_IPREPRO;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_SF_AUT", 10)) {
    /*                         O      */
#ifdef GLP_SF_AUTO
      *nv_return = GLP_SF_AUTO;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "GLP_ASN_MM", 10)) {
    /*                         P      */
#ifdef GLP_ASN_MMP
      *nv_return = GLP_ASN_MMP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_EMIPGA", 10)) {
    /*                         P      */
#ifdef GLP_EMIPGAP
      *nv_return = GLP_EMIPGAP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_SF_SKI", 10)) {
    /*                         P      */
#ifdef GLP_SF_SKIP
      *nv_return = GLP_SF_SKIP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'R':
    if (memEQ(name, "GLP_MSG_ER", 10)) {
    /*                         R      */
#ifdef GLP_MSG_ERR
      *nv_return = GLP_MSG_ERR;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_C_COVE", 10)) {
    /*                         R      */
#ifdef LPX_C_COVER
      *nv_return = LPX_C_COVER;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "GLP_ENOFEA", 10)) {
    /*                         S      */
#ifdef GLP_ENOFEAS
      *nv_return = GLP_ENOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_NODF", 10)) {
    /*                         S      */
#ifdef LPX_E_NODFS
      *nv_return = LPX_E_NODFS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_NOPF", 10)) {
    /*                         S      */
#ifdef LPX_E_NOPFS
      *nv_return = LPX_E_NOPFS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'T':
    if (memEQ(name, "GLP_ISELEC", 10)) {
    /*                         T      */
#ifdef GLP_ISELECT
      *nv_return = GLP_ISELECT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_PP_ROO", 10)) {
    /*                         T      */
#ifdef GLP_PP_ROOT
      *nv_return = GLP_PP_ROOT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_FAUL", 10)) {
    /*                         T      */
#ifdef LPX_E_FAULT
      *nv_return = LPX_E_FAULT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_ITCN", 10)) {
    /*                         T      */
#ifdef LPX_K_ITCNT
      *nv_return = LPX_K_ITCNT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'X':
    if (memEQ(name, "GLP_ASN_MA", 10)) {
    /*                         X      */
#ifdef GLP_ASN_MAX
      *nv_return = GLP_ASN_MAX;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_RELA", 10)) {
    /*                         X      */
#ifdef LPX_K_RELAX
      *nv_return = LPX_K_RELAX;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'Y':
    if (memEQ(name, "GLP_RF_LAZ", 10)) {
    /*                         Y      */
#ifdef GLP_RF_LAZY
      *nv_return = GLP_RF_LAZY;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_EMPT", 10)) {
    /*                         Y      */
#ifdef LPX_E_EMPTY
      *nv_return = LPX_E_EMPTY;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_12 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     GLP_DN_BRNCH GLP_MPS_DECK GLP_MPS_FILE GLP_NO_BRNCH GLP_ORD_NONE
     GLP_UP_BRNCH LPX_C_CLIQUE LPX_C_GOMORY LPX_D_INFEAS LPX_D_NOFEAS
     LPX_E_INFEAS LPX_E_INSTAB LPX_E_MIPGAP LPX_E_NOCONV LPX_E_NOFEAS
     LPX_I_NOFEAS LPX_K_BFTYPE LPX_K_BRANCH LPX_K_BTRACK LPX_K_MIPGAP
     LPX_K_MPSOBJ LPX_K_MSGLEV LPX_K_OUTDLY LPX_K_OUTFRQ LPX_K_PRESOL
     LPX_K_TOLBND LPX_K_TOLINT LPX_K_TOLOBJ LPX_K_TOLPIV LPX_P_INFEAS
     LPX_P_NOFEAS */
  /* Offset 9 gives the best switch position.  */
  switch (name[9]) {
  case 'A':
    if (memEQ(name, "LPX_K_BTRACK", 12)) {
    /*                        ^         */
#ifdef LPX_K_BTRACK
      *nv_return = LPX_K_BTRACK;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'B':
    if (memEQ(name, "LPX_K_TOLBND", 12)) {
    /*                        ^         */
#ifdef LPX_K_TOLBND
      *nv_return = LPX_K_TOLBND;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'D':
    if (memEQ(name, "LPX_K_OUTDLY", 12)) {
    /*                        ^         */
#ifdef LPX_K_OUTDLY
      *nv_return = LPX_K_OUTDLY;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'E':
    if (memEQ(name, "GLP_MPS_DECK", 12)) {
    /*                        ^         */
#ifdef GLP_MPS_DECK
      *nv_return = GLP_MPS_DECK;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_D_INFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_D_INFEAS
      *nv_return = LPX_D_INFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_D_NOFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_D_NOFEAS
      *nv_return = LPX_D_NOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_INFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_E_INFEAS
      *nv_return = LPX_E_INFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_NOFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_E_NOFEAS
      *nv_return = LPX_E_NOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_I_NOFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_I_NOFEAS
      *nv_return = LPX_I_NOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_P_INFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_P_INFEAS
      *nv_return = LPX_P_INFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_P_NOFEAS", 12)) {
    /*                        ^         */
#ifdef LPX_P_NOFEAS
      *nv_return = LPX_P_NOFEAS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "LPX_K_OUTFRQ", 12)) {
    /*                        ^         */
#ifdef LPX_K_OUTFRQ
      *nv_return = LPX_K_OUTFRQ;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'G':
    if (memEQ(name, "LPX_E_MIPGAP", 12)) {
    /*                        ^         */
#ifdef LPX_E_MIPGAP
      *nv_return = LPX_E_MIPGAP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_MIPGAP", 12)) {
    /*                        ^         */
#ifdef LPX_K_MIPGAP
      *nv_return = LPX_K_MIPGAP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'I':
    if (memEQ(name, "GLP_MPS_FILE", 12)) {
    /*                        ^         */
#ifdef GLP_MPS_FILE
      *nv_return = GLP_MPS_FILE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_TOLINT", 12)) {
    /*                        ^         */
#ifdef LPX_K_TOLINT
      *nv_return = LPX_K_TOLINT;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'L':
    if (memEQ(name, "LPX_K_MSGLEV", 12)) {
    /*                        ^         */
#ifdef LPX_K_MSGLEV
      *nv_return = LPX_K_MSGLEV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "GLP_DN_BRNCH", 12)) {
    /*                        ^         */
#ifdef GLP_DN_BRNCH
      *nv_return = GLP_DN_BRNCH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_NO_BRNCH", 12)) {
    /*                        ^         */
#ifdef GLP_NO_BRNCH
      *nv_return = GLP_NO_BRNCH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "GLP_UP_BRNCH", 12)) {
    /*                        ^         */
#ifdef GLP_UP_BRNCH
      *nv_return = GLP_UP_BRNCH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_BRANCH", 12)) {
    /*                        ^         */
#ifdef LPX_K_BRANCH
      *nv_return = LPX_K_BRANCH;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'O':
    if (memEQ(name, "GLP_ORD_NONE", 12)) {
    /*                        ^         */
#ifdef GLP_ORD_NONE
      *nv_return = GLP_ORD_NONE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_C_GOMORY", 12)) {
    /*                        ^         */
#ifdef LPX_C_GOMORY
      *nv_return = LPX_C_GOMORY;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_E_NOCONV", 12)) {
    /*                        ^         */
#ifdef LPX_E_NOCONV
      *nv_return = LPX_E_NOCONV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_MPSOBJ", 12)) {
    /*                        ^         */
#ifdef LPX_K_MPSOBJ
      *nv_return = LPX_K_MPSOBJ;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_TOLOBJ", 12)) {
    /*                        ^         */
#ifdef LPX_K_TOLOBJ
      *nv_return = LPX_K_TOLOBJ;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "LPX_K_TOLPIV", 12)) {
    /*                        ^         */
#ifdef LPX_K_TOLPIV
      *nv_return = LPX_K_TOLPIV;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'Q':
    if (memEQ(name, "LPX_C_CLIQUE", 12)) {
    /*                        ^         */
#ifdef LPX_C_CLIQUE
      *nv_return = LPX_C_CLIQUE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "LPX_K_PRESOL", 12)) {
    /*                        ^         */
#ifdef LPX_K_PRESOL
      *nv_return = LPX_K_PRESOL;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'T':
    if (memEQ(name, "LPX_E_INSTAB", 12)) {
    /*                        ^         */
#ifdef LPX_E_INSTAB
      *nv_return = LPX_E_INSTAB;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'Y':
    if (memEQ(name, "LPX_K_BFTYPE", 12)) {
    /*                        ^         */
#ifdef LPX_K_BFTYPE
      *nv_return = LPX_K_BFTYPE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant_13 (pTHX_ const char *name, NV *nv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     LPX_K_LPTORIG LPX_K_MPSFREE LPX_K_MPSINFO LPX_K_MPSORIG LPX_K_MPSSKIP
     LPX_K_MPSWIDE LPX_K_USECUTS */
  /* Offset 9 gives the best switch position.  */
  switch (name[9]) {
  case 'C':
    if (memEQ(name, "LPX_K_USECUTS", 13)) {
    /*                        ^          */
#ifdef LPX_K_USECUTS
      *nv_return = LPX_K_USECUTS;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "LPX_K_MPSFREE", 13)) {
    /*                        ^          */
#ifdef LPX_K_MPSFREE
      *nv_return = LPX_K_MPSFREE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'I':
    if (memEQ(name, "LPX_K_MPSINFO", 13)) {
    /*                        ^          */
#ifdef LPX_K_MPSINFO
      *nv_return = LPX_K_MPSINFO;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'O':
    if (memEQ(name, "LPX_K_LPTORIG", 13)) {
    /*                        ^          */
#ifdef LPX_K_LPTORIG
      *nv_return = LPX_K_LPTORIG;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "LPX_K_MPSORIG", 13)) {
    /*                        ^          */
#ifdef LPX_K_MPSORIG
      *nv_return = LPX_K_MPSORIG;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "LPX_K_MPSSKIP", 13)) {
    /*                        ^          */
#ifdef LPX_K_MPSSKIP
      *nv_return = LPX_K_MPSSKIP;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'W':
    if (memEQ(name, "LPX_K_MPSWIDE", 13)) {
    /*                        ^          */
#ifdef LPX_K_MPSWIDE
      *nv_return = LPX_K_MPSWIDE;
      return PERL_constant_ISNV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
iv_constant (pTHX_ const char *name, STRLEN len, NV *nv_return) {
  /* Initially switch on the length of the name.  */
  /* When generated this function returned values for the list of names given
     in this section of perl code.  Rather than manually editing these functions
     to add or remove constants, which would result in this comment and section
     of code becoming inaccurate, we recommend that you edit this section of
     code, and use it to regenerate a new set of constant functions which you
     then use to replace the originals.

     Regenerate these constant functions by feeding this entire source file to
     perl -x

#!/usr/bin/perl -w
use ExtUtils::Constant qw (constant_types C_constant XS_constant);

my $types = {map {($_, 1)} qw(NV)};
my @names = (qw(GLP_ASN_MAX GLP_ASN_MIN GLP_ASN_MMP GLP_BF_BG GLP_BF_FT
	       GLP_BF_GR GLP_BR_DTH GLP_BR_FFV GLP_BR_LFV GLP_BR_MFV GLP_BR_PCH
	       GLP_BS GLP_BT_BFS GLP_BT_BLB GLP_BT_BPH GLP_BT_DFS GLP_BV GLP_CV
	       GLP_DB GLP_DN_BRNCH GLP_DUAL GLP_DUALP GLP_EBADB GLP_EBOUND
	       GLP_ECOND GLP_EDATA GLP_EFAIL GLP_EINSTAB GLP_EITLIM GLP_EMIPGAP
	       GLP_ENOCVG GLP_ENODFS GLP_ENOFEAS GLP_ENOPFS GLP_EOBJLL
	       GLP_EOBJUL GLP_ERANGE GLP_EROOT GLP_ESING GLP_ESTOP GLP_ETMLIM
	       GLP_FEAS GLP_FR GLP_FX GLP_IBINGO GLP_IBRANCH GLP_ICUTGEN
	       GLP_IHEUR GLP_INFEAS GLP_IPREPRO GLP_IPT GLP_IROWGEN GLP_ISELECT
	       GLP_IV GLP_KKT_CS GLP_KKT_DB GLP_KKT_DE GLP_KKT_PB GLP_KKT_PE
	       GLP_LO GLP_MAJOR_VERSION GLP_MAX GLP_MIN GLP_MINOR_VERSION
	       GLP_MIP GLP_MPS_DECK GLP_MPS_FILE GLP_MSG_ALL GLP_MSG_DBG
	       GLP_MSG_ERR GLP_MSG_OFF GLP_MSG_ON GLP_NF GLP_NL GLP_NOFEAS
	       GLP_NO_BRNCH GLP_NS GLP_NU GLP_OFF GLP_ON GLP_OPT GLP_ORD_AMD
	       GLP_ORD_NONE GLP_ORD_QMD GLP_ORD_SYMAMD GLP_PP_ALL GLP_PP_NONE
	       GLP_PP_ROOT GLP_PRIMAL GLP_PT_PSE GLP_PT_STD GLP_RF_CLQ
	       GLP_RF_COV GLP_RF_CUT GLP_RF_GMI GLP_RF_LAZY GLP_RF_MIR
	       GLP_RF_REG GLP_RT_HAR GLP_RT_STD GLP_SF_2N GLP_SF_AUTO GLP_SF_EQ
	       GLP_SF_GM GLP_SF_SKIP GLP_SOL GLP_UNBND GLP_UNDEF GLP_UP
	       GLP_UP_BRNCH LPX_BS LPX_CV LPX_C_ALL LPX_C_CLIQUE LPX_C_COVER
	       LPX_C_GOMORY LPX_C_MIR LPX_DB LPX_D_FEAS LPX_D_INFEAS
	       LPX_D_NOFEAS LPX_D_UNDEF LPX_E_BADB LPX_E_EMPTY LPX_E_FAULT
	       LPX_E_INFEAS LPX_E_INSTAB LPX_E_ITLIM LPX_E_MIPGAP LPX_E_NOCONV
	       LPX_E_NODFS LPX_E_NOFEAS LPX_E_NOPFS LPX_E_OBJLL LPX_E_OBJUL
	       LPX_E_OK LPX_E_SING LPX_E_TMLIM LPX_FEAS LPX_FR LPX_FX
	       LPX_INFEAS LPX_IV LPX_I_FEAS LPX_I_NOFEAS LPX_I_OPT LPX_I_UNDEF
	       LPX_K_BFTYPE LPX_K_BINARIZE LPX_K_BRANCH LPX_K_BTRACK LPX_K_DUAL
	       LPX_K_ITCNT LPX_K_ITLIM LPX_K_LPTORIG LPX_K_MIPGAP LPX_K_MPSFREE
	       LPX_K_MPSINFO LPX_K_MPSOBJ LPX_K_MPSORIG LPX_K_MPSSKIP
	       LPX_K_MPSWIDE LPX_K_MSGLEV LPX_K_OBJLL LPX_K_OBJUL LPX_K_OUTDLY
	       LPX_K_OUTFRQ LPX_K_PRESOL LPX_K_PRICE LPX_K_RELAX LPX_K_ROUND
	       LPX_K_SCALE LPX_K_TMLIM LPX_K_TOLBND LPX_K_TOLDJ LPX_K_TOLINT
	       LPX_K_TOLOBJ LPX_K_TOLPIV LPX_K_USECUTS LPX_LO LPX_LP LPX_MAX
	       LPX_MIN LPX_MIP LPX_NF LPX_NL LPX_NOFEAS LPX_NS LPX_NU LPX_OPT
	       LPX_P_FEAS LPX_P_INFEAS LPX_P_NOFEAS LPX_P_UNDEF LPX_T_OPT
	       LPX_T_UNDEF LPX_UNBND LPX_UNDEF LPX_UP));

print constant_types(), "\n"; # macro defs
foreach (C_constant ("Math::GLPK::Base", 'iv_constant', 'NV', $types, undef, 3, @names) ) {
    print $_, "\n"; # C constant subs
}
print "\n#### XS Section:\n";
print XS_constant ("Math::GLPK::Base", $types);
__END__
   */

  switch (len) {
  case 6:
    return iv_constant_6 (aTHX_ name, nv_return);
    break;
  case 7:
    return iv_constant_7 (aTHX_ name, nv_return);
    break;
  case 8:
    return iv_constant_8 (aTHX_ name, nv_return);
    break;
  case 9:
    return iv_constant_9 (aTHX_ name, nv_return);
    break;
  case 10:
    return iv_constant_10 (aTHX_ name, nv_return);
    break;
  case 11:
    return iv_constant_11 (aTHX_ name, nv_return);
    break;
  case 12:
    return iv_constant_12 (aTHX_ name, nv_return);
    break;
  case 13:
    return iv_constant_13 (aTHX_ name, nv_return);
    break;
  case 14:
    /* Names all of length 14.  */
    /* GLP_ORD_SYMAMD LPX_K_BINARIZE */
    /* Offset 13 gives the best switch position.  */
    switch (name[13]) {
    case 'D':
      if (memEQ(name, "GLP_ORD_SYMAM", 13)) {
      /*                            D      */
#ifdef GLP_ORD_SYMAMD
        *nv_return = GLP_ORD_SYMAMD;
        return PERL_constant_ISNV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    case 'E':
      if (memEQ(name, "LPX_K_BINARIZ", 13)) {
      /*                            E      */
#ifdef LPX_K_BINARIZE
        *nv_return = LPX_K_BINARIZE;
        return PERL_constant_ISNV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    }
    break;
  case 17:
    /* Names all of length 17.  */
    /* GLP_MAJOR_VERSION GLP_MINOR_VERSION */
    /* Offset 6 gives the best switch position.  */
    switch (name[6]) {
    case 'J':
      if (memEQ(name, "GLP_MAJOR_VERSION", 17)) {
      /*                     ^                 */
#ifdef GLP_MAJOR_VERSION
        *nv_return = GLP_MAJOR_VERSION;
        return PERL_constant_ISNV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    case 'N':
      if (memEQ(name, "GLP_MINOR_VERSION", 17)) {
      /*                     ^                 */
#ifdef GLP_MINOR_VERSION
        *nv_return = GLP_MINOR_VERSION;
        return PERL_constant_ISNV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

