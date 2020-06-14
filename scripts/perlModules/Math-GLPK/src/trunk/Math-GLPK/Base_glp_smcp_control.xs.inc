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
_set_glp_smcp_msg_level( glp_smcp *env, int level )
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
# set simplex method
# return old simplex method
################################################################################
int
_set_glp_smcp_meth( glp_smcp *env, int meth )
  PREINIT:

  CODE:
     if( !(meth == GLP_PRIMAL || meth == GLP_DUAL || meth == GLP_DUALP) )
     {
        fprintf(stderr, "WARNING: unkown simplex method: %d\n", meth);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_PRIMAL", GLP_PRIMAL);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_DUAL"  , GLP_DUAL  );
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_DUALP" , GLP_DUALP );
     }

     RETVAL = env->meth;
     env->meth = meth;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set simplex pricing
# return old simplex pricing
################################################################################
int
_set_glp_smcp_pricing( glp_smcp *env, int pricing )
  PREINIT:

  CODE:
     if( !(pricing == GLP_PT_STD || pricing == GLP_PT_PSE) )
     {
        fprintf(stderr, "WARNING: unkown pricing: %d\n", pricing);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_PT_STD", GLP_PT_STD);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_PT_PSE", GLP_PT_PSE);
     }

     RETVAL = env->pricing;
     env->pricing = pricing;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set ratio test technique
# return old ratio test technique
################################################################################
int
_set_glp_smcp_r_test( glp_smcp *env, int r_test )
  PREINIT:

  CODE:
     if( !(r_test == GLP_RT_STD || r_test == GLP_RT_HAR) )
     {
        fprintf(stderr, "WARNING: unkown ratio test technique: %d\n", r_test);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_RT_HAR", GLP_RT_HAR);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_RT_STD", GLP_RT_STD);
     }

     RETVAL = env->r_test;
     env->r_test = r_test;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set tolerance primal feasible
# return old tolerance primal feasible
################################################################################
double
_set_glp_smcp_tol_bnd( glp_smcp *env, double tol_bnd )
  PREINIT:

  CODE:
     RETVAL = env->tol_bnd;
     env->tol_bnd = tol_bnd;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set tolerance dual feasible
# return old tolerance dual feasible
################################################################################
double
_set_glp_smcp_tol_dj( glp_smcp *env, double tol_dj )
  PREINIT:

  CODE:
     RETVAL = env->tol_dj;
     env->tol_dj = tol_dj;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set tolerance pivotal elements
# return old tolerance pivotal elements
################################################################################
double
_set_glp_smcp_tol_piv( glp_smcp *env, double tol_piv )
  PREINIT:

  CODE:
     RETVAL = env->tol_piv;
     env->tol_piv = tol_piv;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set lower limit of the objective function
# return old lower limit of the objective function
################################################################################
double
_set_glp_smcp_obj_ll( glp_smcp *env, double obj_ll )
  PREINIT:

  CODE:
     RETVAL = env->obj_ll;
     env->obj_ll = obj_ll;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set upper limit of the objective function
# return old upper limit of the objective function
################################################################################
double
_set_glp_smcp_obj_ul( glp_smcp *env, double obj_ul )
  PREINIT:

  CODE:
     RETVAL = env->obj_ul;
     env->obj_ul = obj_ul;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set iteration limit
# return old iteration limit
################################################################################
int
_set_glp_smcp_it_lim( glp_smcp *env, int it_lim )
  PREINIT:

  CODE:
     RETVAL = env->it_lim;
     env->it_lim = it_lim;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# set time limit [milliseconds]
# return old time limit
################################################################################
int
_set_glp_smcp_tm_lim( glp_smcp *env, int tm_lim )
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
_set_glp_smcp_out_frq( glp_smcp *env, int out_frq )
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
_set_glp_smcp_out_dly( glp_smcp *env, int out_dly )
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
_set_glp_smcp_presolve( glp_smcp *env, int presolve )
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
# get message level
################################################################################
int
_get_glp_smcp_msg_level( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->msg_lev;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get simplex method
################################################################################
int
_get_glp_smcp_meth( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->meth;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get simplex pricing
################################################################################
int
_get_glp_smcp_pricing( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->pricing;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get ratio test technique
################################################################################
int
_get_glp_smcp_r_test( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->r_test;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get tolerance primal feasible
################################################################################
double
_get_glp_smcp_tol_bnd ( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->tol_bnd;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get tolerance dual feasible
################################################################################
double
_get_glp_smcp_tol_dj ( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->tol_dj;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get tolerance pivotal elements
################################################################################
double
_get_glp_smcp_tol_piv ( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->tol_piv;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get lower limit of the objective function
################################################################################
double
_get_glp_smcp_obj_ll ( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->obj_ll;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get upper limit of the objective function
################################################################################
double
_get_glp_smcp_obj_ul ( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->obj_ul;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get iteration limit
################################################################################
int
_get_glp_smcp_it_lim( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->it_lim;

  OUTPUT:
     RETVAL
################################################################################

################################################################################
# get time limit
################################################################################
int
_get_glp_smcp_tm_lim( glp_smcp *env )
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
_get_glp_smcp_out_frq( glp_smcp *env )
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
_get_glp_smcp_out_dly( glp_smcp *env )
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
_get_glp_smcp_presolve( glp_smcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->presolve;

  OUTPUT:
     RETVAL
################################################################################
