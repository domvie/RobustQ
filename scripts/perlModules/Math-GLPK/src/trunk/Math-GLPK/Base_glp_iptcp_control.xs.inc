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
_set_glp_iptcp_msg_level( glp_iptcp *env, int level )
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
_set_glp_iptcp_ord_alg( glp_iptcp *env, int ord_alg )
  PREINIT:

  CODE:
     if( !(ord_alg == GLP_ORD_NONE || ord_alg == GLP_ORD_QMD   ||
           ord_alg == GLP_ORD_AMD  || ord_alg == GLP_ORD_SYMAMD) )
     {
        fprintf(stderr, "WARNING: unkown ordering algorithm: %d\n", ord_alg);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ORD_NONE",   GLP_ORD_NONE);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ORD_QMD",    GLP_ORD_QMD);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ORD_AMD",    GLP_ORD_AMD);
        fprintf(stderr, "         known: '%s' = %d\n", "GLP_ORD_SYMAMD", GLP_ORD_SYMAMD);
     }

     RETVAL = env->ord_alg;
     env->ord_alg = ord_alg;

  OUTPUT:
     RETVAL
################################################################################



################################################################################
# get message level
################################################################################
int
_get_glp_iptcp_msg_level( glp_iptcp *env )
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
_get_glp_iptcp_ord_alg( glp_iptcp *env )
  PREINIT:
     
  CODE:
     RETVAL = env->ord_alg;

  OUTPUT:
     RETVAL
################################################################################
