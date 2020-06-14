###############################################################################
###############################################################################
int
_intopt(glp_prob *lp, glp_iocp *param)
   PREINIT:
      int status;
   CODE:
      // param->presolve = GLP_ON;
      status = glp_intopt(lp, param);

      if( status )
      {
         fprintf(stderr, "glp_intopt() failed. Return code: %d\n",status);
         XSRETURN_UNDEF;
      }

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_UNDEF MIP solution is undened.
# GLP_OPT MIP solution is integer optimal.
# GLP_FEAS MIP solution is integer feasible, however, its optimality
#          (or non-optimality) has not been proven, perhaps due
#          to premature termination of the search.
# GLP_NOFEAS problem has no integer feasible solution (proven by the
#            solver).
###############################################################################
int
_mip_status(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_mip_status(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_num_int(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_num_int(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_num_bin(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_num_bin(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_mip_obj_val(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_mip_obj_val(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_mip_row_val(glp_prob *lp, int row_idx)
   PREINIT:

   CODE:
      RETVAL = glp_mip_row_val(lp, row_idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_mip_col_val(glp_prob *lp, int col_idx)
   PREINIT:

   CODE:
      RETVAL = glp_mip_col_val(lp, col_idx);

   OUTPUT:
      RETVAL
###############################################################################
