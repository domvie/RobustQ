###############################################################################
###############################################################################
int
_simplex(glp_prob *lp, glp_smcp *param)
   PREINIT:
      int status;
   CODE:
      // param->presolve = GLP_ON;
      status = glp_simplex(lp, param);

      if( status )
      {
         fprintf(stderr, "glp_simplex() failed. Return code: %d\n",status);
         XSRETURN_UNDEF;
      }

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_exact(glp_prob *lp, glp_smcp *param)
   PREINIT:
      int status;
   CODE:
      // param->presolve = GLP_ON;
      status = glp_exact(lp, param);

      if( status )
      {
         fprintf(stderr, "glp_exact() failed. Return code: %d\n",status);
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
_get_status(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_status(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_UNDEF primal solution is undefined;
# GLP_FEAS primal solution is feasible;
# GLP_INFEAS primal solution is infeasible;
# GLP_NOFEAS no primal feasible solution exists.
###############################################################################
int
_get_prim_stat(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_prim_stat(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_UNDEF dual solution is undefined;
# GLP_FEAS dual solution is feasible;
# GLP_INFEAS dual solution is infeasible;
# GLP_NOFEAS no dual feasible solution exists.
###############################################################################
int
_get_dual_stat(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_dual_stat(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_obj_val(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_obj_val(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_row_stat(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_row_stat(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_row_prim(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_row_prim(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_row_dual(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_row_dual(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_col_stat(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_col_stat(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_col_prim(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_col_prim(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_col_dual(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_col_dual(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_unbnd_ray(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_unbnd_ray(lp);

   OUTPUT:
      RETVAL
###############################################################################
