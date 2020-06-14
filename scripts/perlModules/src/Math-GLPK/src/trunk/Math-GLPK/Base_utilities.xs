###############################################################################
###############################################################################
int
_read_sol(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_read_sol(lp, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_read_sol() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_write_sol(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_write_sol(lp, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_write_sol() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_read_mip(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_read_mip(lp , filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_read_mip() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_write_mip(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_write_mip(lp , filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_write_mip() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_read_ipt(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_read_ipt(lp , filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_read_ipt() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_write_ipt(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_write_ipt(lp , filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_write_ipt() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
     }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_read_mps(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_read_mps(lp , GLP_MPS_FILE, NULL, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_read_mps() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_write_mps(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_write_mps(lp , GLP_MPS_FILE, NULL, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_write_mps() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_read_lp(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_read_lp(lp , NULL, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_read_lp() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_write_lp(glp_prob *lp, char *filename)
   PREINIT:
      int status;
   CODE:
      status = glp_write_lp(lp, NULL, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_write_lp() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_read_prob(glp_prob *lp, char *filename)
   PREINIT:
      int status;
      int future_use = 0;
   CODE:
      status = glp_read_prob(lp, future_use, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_read_prob() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_write_prob(glp_prob *lp, char *filename)
   PREINIT:
      int status;
      int future_use = 0;
   CODE:
      status = glp_write_prob(lp, future_use, filename);
      if( status )
      {
        fprintf(stderr, "ERROR: glp_write_prob() to file '%s' failed. Returned status: %d\n", filename, status);
        XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }
   OUTPUT:
      RETVAL
###############################################################################
