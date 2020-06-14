###############################################################################
###############################################################################
int
_interior(glp_prob *lp, glp_iptcp *param)
   PREINIT:
      int status;
   CODE:
      // param->presolve = GLP_ON;
      status = glp_interior(lp, param);

      if( status )
      {
         fprintf(stderr, "glp_interior() failed. Return code: %d\n",status);
         XSRETURN_UNDEF;
      }

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_OPT solution is optimal;
# GLP_FEAS solution is feasible;
# GLP_INFEAS solution is infeasible;
# GLP_NOFEAS problem has no feasible solution;
# GLP_UNBND problem has unbounded solution;
# GLP_UNDEF solution is undefined.
###############################################################################
int
_ipt_status(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_ipt_status(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_ipt_obj_val(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_ipt_obj_val(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_ipt_row_prim(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_ipt_row_prim(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_ipt_row_dual(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_ipt_row_dual(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_ipt_col_prim(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_ipt_col_prim(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_ipt_col_dual(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_ipt_col_dual(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################
