################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Wed Nov 13 11:05:36 CET 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

################################################################################
# set message level
# return old level
################################################################################
int
_set_glp_iocp_msg_level( glp_iocp *env, int level )
  PREINIT:

  CODE:
     if( !(level == GLP_MSG_OFF || level == GLP_MSG_ERR || level == GLP_MSG_ON || level == GLP_MSG_ALL) )
     {
        fprintf(stderr, "WARNING: unkown message level: %d\n", level);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_MSG_OFF", GLP_MSG_OFF);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_MSG_ERR", GLP_MSG_ERR);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_MSG_ON" , GLP_MSG_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_MSG_ALL", GLP_MSG_ALL);
     }

     RETVAL = env->msg_lev;
     env->msg_lev = level;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set branching technique
# return old branching technique
################################################################################
int
_set_glp_iocp_br_tech( glp_iocp *env, int br_tech )
  PREINIT:

  CODE:
     if( !(br_tech == GLP_BR_FFV || br_tech == GLP_BR_LFV || br_tech == GLP_BR_MFV ||
           br_tech == GLP_BR_DTH || br_tech == GLP_BR_PCH) )
     {
        fprintf(stderr, "WARNING: unkown branching technique: %d\n", br_tech);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BR_FFV", GLP_BR_FFV);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BR_LFV", GLP_BR_LFV);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BR_MFV", GLP_BR_MFV);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BR_DTH", GLP_BR_DTH);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BR_PCH", GLP_BR_PCH);
     }

     RETVAL = env->br_tech;
     env->br_tech = br_tech;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set backtracking technique
# return old backtracking technique
################################################################################
int
_set_glp_iocp_bt_tech( glp_iocp *env, int bt_tech )
  PREINIT:

  CODE:
     if( !(bt_tech == GLP_BT_DFS || bt_tech == GLP_BT_BFS ||
           bt_tech == GLP_BT_BLB || bt_tech == GLP_BT_BPH) )
     {
        fprintf(stderr, "WARNING: unkown backtracking technique: %d\n", bt_tech);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BT_DFS", GLP_BT_DFS);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BT_BFS", GLP_BT_BFS);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BT_BLB", GLP_BT_BLB);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_BT_BPH", GLP_BT_BPH);
     }

     RETVAL = env->bt_tech;
     env->bt_tech = bt_tech;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set preprocessing technique
# return old preprocessing technique
################################################################################
int
_set_glp_iocp_pp_tech( glp_iocp *env, int pp_tech )
  PREINIT:

  CODE:
     if( !(pp_tech == GLP_PP_NONE || pp_tech == GLP_PP_ROOT || pp_tech == GLP_PP_ALL) )
     {
        fprintf(stderr, "WARNING: unkown preprocessing technique: %d\n", pp_tech);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_PP_NONE", GLP_PP_NONE);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_PP_ROOT", GLP_PP_ROOT);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_PP_ALL" , GLP_PP_ALL );
     }

     RETVAL = env->pp_tech;
     env->pp_tech = pp_tech;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set feasibility pump heuristics
# return old feasibility pump heuristics
################################################################################
int
_set_glp_iocp_fp_heur( glp_iocp *env, int fp_heur )
  PREINIT:

  CODE:
     if( !(fp_heur == GLP_ON || fp_heur == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown value for feasibility pump heuristics: %d\n", fp_heur);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF );
     }

     RETVAL = env->fp_heur;
     env->fp_heur = fp_heur;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set Gomory's mixed integer cut option
# return old Gomory's mixed integer cut option
################################################################################
int
_set_glp_iocp_gmi_cuts( glp_iocp *env, int gmi_cuts )
  PREINIT:

  CODE:
     if( !(gmi_cuts == GLP_ON || gmi_cuts == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown value for Gomory's mixed integer cut option: %d\n", gmi_cuts);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF );
     }

     RETVAL = env->gmi_cuts;
     env->gmi_cuts = gmi_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set Mixed integer rounding (MIR) cut option
# return old Mixed integer rounding (MIR) cut option
################################################################################
int
_set_glp_iocp_mir_cuts( glp_iocp *env, int mir_cuts )
  PREINIT:

  CODE:
     if( !(mir_cuts == GLP_ON || mir_cuts == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown value for Mixed integer rounding (MIR) cut option: %d\n", mir_cuts);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF );
     }

     RETVAL = env->mir_cuts;
     env->mir_cuts = mir_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set Mixed cover cut option
# return old Mixed cover cut option
################################################################################
int
_set_glp_iocp_cov_cuts( glp_iocp *env, int cov_cuts )
  PREINIT:

  CODE:
     if( !(cov_cuts == GLP_ON || cov_cuts == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown value for Mixed cover cut option: %d\n", cov_cuts);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF );
     }

     RETVAL = env->cov_cuts;
     env->cov_cuts = cov_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set Clique cut option
# return old Clique cut option
################################################################################
int
_set_glp_iocp_clq_cuts( glp_iocp *env, int clq_cuts )
  PREINIT:

  CODE:
     if( !(clq_cuts == GLP_ON || clq_cuts == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown value for Clique cut option: %d\n", clq_cuts);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF );
     }

     RETVAL = env->clq_cuts;
     env->clq_cuts = clq_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set Absolute tolerance
# return old Absolute tolerance
################################################################################
double
_set_glp_iocp_tol_int( glp_iocp *env, double tol_int )
  PREINIT:

  CODE:
     RETVAL = env->tol_int;
     env->tol_int = tol_int;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set Relative tolerance
# return old Relative tolerance
################################################################################
double
_set_glp_iocp_tol_obj( glp_iocp *env, double tol_obj )
  PREINIT:

  CODE:
     RETVAL = env->tol_obj;
     env->tol_obj = tol_obj;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set MIP Gap
# return old MIP Gap
################################################################################
double
_set_glp_iocp_mip_gap( glp_iocp *env, double mip_gap )
  PREINIT:

  CODE:
     RETVAL = env->mip_gap;
     env->mip_gap = mip_gap;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set time limit [milliseconds]
# return old time limit
################################################################################
int
_set_glp_iocp_tm_lim( glp_iocp *env, int tm_lim )
  PREINIT:

  CODE:
     RETVAL = env->tm_lim;
     env->tm_lim = tm_lim;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set output frequency
# return old output frequency
################################################################################
int
_set_glp_iocp_out_frq( glp_iocp *env, int out_frq )
  PREINIT:

  CODE:
     RETVAL = env->out_frq;
     env->out_frq = out_frq;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set output delay
# return old output delay
################################################################################
int
_set_glp_iocp_out_dly( glp_iocp *env, int out_dly )
  PREINIT:

  CODE:
     RETVAL = env->out_dly;
     env->out_dly = out_dly;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set presolve
# return old presolve
################################################################################
int
_set_glp_iocp_presolve( glp_iocp *env, int presolve )
  PREINIT:

  CODE:
     if( !(presolve == GLP_ON || presolve == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown setting for presolve: %d\n", presolve);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF);
     }

     RETVAL = env->presolve;
     env->presolve = presolve;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set binarize
# return old binarize
################################################################################
int
_set_glp_iocp_binarize( glp_iocp *env, int binarize )
  PREINIT:

  CODE:
     if( !(binarize == GLP_ON || binarize == GLP_OFF) )
     {
        fprintf(stderr, "WARNING: unkown setting for binarize: %d\n", binarize);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ON" , GLP_ON );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_OFF", GLP_OFF);
     }

     RETVAL = env->binarize;
     env->binarize = binarize;

  OUTPUT:
     RETVAL
################################################################################





################################################################################
# get message level
################################################################################
int
_get_glp_iocp_msg_level( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->msg_lev;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get branching technique
################################################################################
int
_get_glp_iocp_br_tech( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->br_tech;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get backtracking technique
################################################################################
int
_get_glp_iocp_bt_tech( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->bt_tech;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get preprocessing technique
################################################################################
int
_get_glp_iocp_pp_tech( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->pp_tech;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get feasibility pump heuristics
################################################################################
int
_get_glp_iocp_fp_heur( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->fp_heur;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get Gomory's mixed integer cut option
################################################################################
int
_get_glp_iocp_gmi_cuts( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->gmi_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get Mixed integer rounding (MIR) cut option
################################################################################
int
_get_glp_iocp_mir_cuts( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->mir_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get Mixed cover cut option
################################################################################
int
_get_glp_iocp_cov_cuts( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->cov_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get Clique cut option
################################################################################
int
_get_glp_iocp_clq_cuts( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->clq_cuts;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get Absolute tolerance
################################################################################
double
_get_glp_iocp_tol_int( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->tol_int;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get Relative tolerance
################################################################################
double
_get_glp_iocp_tol_obj( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->tol_obj;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get MIP Gap
################################################################################
double
_get_glp_iocp_mip_gap( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->mip_gap;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get time limit
################################################################################
int
_get_glp_iocp_tm_lim( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->tm_lim;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get output frequency
################################################################################
int
_get_glp_iocp_out_frq( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->out_frq;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get output delay
################################################################################
int
_get_glp_iocp_out_dly( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->out_dly;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get presolve
################################################################################
int
_get_glp_iocp_presolve( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->presolve;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get binarize
################################################################################
int
_get_glp_iocp_binarize( glp_iocp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->binarize;

  OUTPUT:
     RETVAL
################################################################################
