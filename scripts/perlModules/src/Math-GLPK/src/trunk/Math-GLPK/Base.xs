#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include "glpk.h"

#include "const-c-iv.inc"
#include "const-c-nv.inc"

MODULE = Math::GLPK::Base		PACKAGE = Math::GLPK::Base

INCLUDE: const-xs-iv.inc
INCLUDE: const-xs-nv.inc
INCLUDE: Base_glp_smcp_control.xs.inc
INCLUDE: Base_glp_iptcp_control.xs.inc
INCLUDE: Base_glp_iocp_control.xs.inc
INCLUDE: Base_simplex.xs.inc
INCLUDE: Base_mip.xs.inc
INCLUDE: Base_ipt.xs.inc
INCLUDE: Base_utilities.xs

###############################################################################
###############################################################################
glp_iocp*
_openGLPK_MIP ()
  PREINIT:
     int status;
     glp_iocp *glpk_env;
  CODE:
     status = glp_init_env();
     if( status )
     {
        fprintf(stderr, "ERROR: glp_init_env failed. Returned status: %d\n",status);
        XSRETURN_UNDEF;
     }

     New( 0, glpk_env, 1, glp_iocp);
     glp_init_iocp(glpk_env);
     RETVAL = glpk_env;

  OUTPUT:
     RETVAL
###############################################################################

###############################################################################
###############################################################################
glp_iptcp*
_openGLPK_IPT ()
  PREINIT:
     int status;
     glp_iptcp *glpk_env;
  CODE:
     status = glp_init_env();
     if( status )
     {
        fprintf(stderr, "ERROR: glp_init_env failed. Returned status: %d\n",status);
        XSRETURN_UNDEF;
     }

     New( 0, glpk_env, 1, glp_iptcp);
     glp_init_iptcp(glpk_env);
     RETVAL = glpk_env;

  OUTPUT:
     RETVAL
###############################################################################

###############################################################################
###############################################################################
glp_smcp*
_openGLPK_SIMPLEX ()
  PREINIT:
     int status;
     glp_smcp *glpk_env;
  CODE:
     status = glp_init_env();
     if( status )
     {
        fprintf(stderr, "ERROR: glp_init_env failed. Returned status: %d\n",status);
        XSRETURN_UNDEF;
     }

     New( 0, glpk_env, 1, glp_smcp);
     glp_init_smcp(glpk_env);
     RETVAL = glpk_env;

  OUTPUT:
     RETVAL
###############################################################################


###############################################################################
###############################################################################
glp_prob*
_createLP (char *prob_name);
   PREINIT:
      glp_prob *lp = NULL;
   CODE:
      lp = glp_create_prob();
      if( lp == NULL )
      {
        fprintf(stderr, "ERROR: glp_create_prob() failed.\n");
        XSRETURN_UNDEF;
      }

      glp_set_prob_name(lp, prob_name);
      RETVAL = lp;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_prob_name(glp_prob *lp, char *prob_name);
   PREINIT:

   CODE:
      glp_set_prob_name(lp, prob_name);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
char *
_get_prob_name(glp_prob *lp);
   PREINIT:
      const char *name;
      int length;
   CODE:
      name = glp_get_prob_name(lp);

      if( name == NULL )
      {
         XSRETURN_UNDEF;
      }

      length = strlen(name);
      New( 0, RETVAL, length + 1, char);
      strcpy( RETVAL, name );

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_maximize(glp_prob *lp)
   PREINIT:

   CODE:
      glp_set_obj_dir(lp, GLP_MAX);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_minimize(glp_prob *lp)
   PREINIT:

   CODE:
      glp_set_obj_dir(lp, GLP_MIN);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_obj_dir(glp_prob *lp)
   PREINIT:

   CODE:
      RETVAL = glp_get_obj_dir(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_obj_name(glp_prob *lp, char *name)
   PREINIT:

   CODE:
      // fprintf(stderr, "DEBUG: going to set name of object function to '%s', length=%ld\n", name, strlen(name));

      if( strlen(name) > 255 )
      {
         fprintf(stderr, "WARNING: objective name must not exceed 255 characters\n");
      }

      glp_set_obj_name(lp, name);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
char *
_get_obj_name(glp_prob *lp)
   PREINIT:
      const char *name;
      int length;
   CODE:
      name = glp_get_obj_name(lp);

      if( name == NULL )
      {
         XSRETURN_UNDEF;
      }

      // printf("DEBUG: name: %s, length=%ld\n", name, strlen(name));

      length = strlen(name);
      New( 0, RETVAL, length + 1, char);
      strcpy( RETVAL, name );

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
char *
_get_col_name(glp_prob *lp, int idx)
   PREINIT:
      const char *name;
      int length;
   CODE:
      name = glp_get_col_name(lp, idx);

      if( name == NULL )
      {
         XSRETURN_UNDEF;
      }

      // printf("DEBUG: name: %s, length=%ld\n", name, strlen(name));

      length = strlen(name);
      New( 0, RETVAL, length + 1, char);
      strcpy( RETVAL, name );

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_num_cols(glp_prob *lp)
   PREINIT:
      
   CODE:
      RETVAL = glp_get_num_cols(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_num_nz(glp_prob *lp)
   PREINIT:
      
   CODE:
      RETVAL = glp_get_num_nz(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
char *
_get_row_name(glp_prob *lp, int idx)
   PREINIT:
      const char *name;
      int length;
   CODE:
      name = glp_get_row_name(lp, idx);

      if( name == NULL )
      {
         XSRETURN_UNDEF;
      }

      // printf("DEBUG: name: %s, length=%ld\n", name, strlen(name));

      length = strlen(name);
      New( 0, RETVAL, length + 1, char);
      strcpy( RETVAL, name );

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_FR free (unbounded) variable;
# GLP_LO variable with lower bound;
# GLP_UP variable with upper bound;
# GLP_DB double-bounded variable;
# GLP_FX fixed variable.
###############################################################################
int
_get_row_type(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_row_type(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_row_lb(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_row_lb(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_row_ub(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_row_ub(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_FR free (unbounded) variable;
# GLP_LO variable with lower bound;
# GLP_UP variable with upper bound;
# GLP_DB double-bounded variable;
# GLP_FX fixed variable.
###############################################################################
int
_get_col_type(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_col_type(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_col_lb(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_col_lb(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_col_ub(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_col_ub(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_num_rows(glp_prob *lp)
   PREINIT:
      
   CODE:
      RETVAL = glp_get_num_rows(lp);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_add_cols(glp_prob *lp, int num_cols)
   PREINIT:
      int ret;
   CODE:
      // printf("_add_cols(): num_cols=%d\n",num_cols);
      ret = glp_add_cols(lp, num_cols);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_add_rows(glp_prob *lp, int num_rows)
   PREINIT:
      int ret;
   CODE:
      // printf("_add_rows(): num_rows=%d\n",num_rows);
      ret = glp_add_rows(lp, num_rows);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_obj_coef(glp_prob *lp, int col, double coef)
   PREINIT:
   CODE:
      glp_set_obj_coef(lp, col, coef);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_obj_coef(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_obj_coef(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_get_col_kind(glp_prob *lp, int col)
   PREINIT:
   CODE:
      RETVAL = glp_get_col_kind(lp, col);

   OUTPUT:
      RETVAL
###############################################################################



###############################################################################
###############################################################################
int
_set_col_kind(glp_prob *lp, int col, int type)
   PREINIT:
   CODE:
      glp_set_col_kind(lp, col, type);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_col_bnds(glp_prob *lp, int col, int type, double lb, double ub)
   PREINIT:
   CODE:
      glp_set_col_bnds(lp, col, type, lb, ub);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_row_bnds(glp_prob *lp, int row, int type, double lb, double ub)
   PREINIT:
   CODE:
      glp_set_row_bnds(lp, row, type, lb, ub);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_col_name(glp_prob *lp, int col, char *name)
   PREINIT:
   CODE:
      glp_set_col_name(lp, col, name);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_row_name(glp_prob *lp, int row, char *name)
   PREINIT:
   CODE:
      glp_set_row_name(lp, row, name);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
void
_get_mat_row(glp_prob *lp, int row_idx, int num_rows)
   PREINIT:
      int i;
      int *idx;
      double *val;
      int num_nz;
   PPCODE:
      New( 0, idx, num_rows + 1, int);
      New( 0, val, num_rows + 1, double);

      num_nz = glp_get_mat_row(lp, row_idx, idx, val);

      EXTEND(SP, 2*num_nz);

      for( i = 1; i <= num_nz; i++ )
      {
         PUSHs( sv_2mortal( newSViv( idx[i] ) ) );
         PUSHs( sv_2mortal( newSVnv( val[i] ) ) );
      }

      SAVEFREEPV(val);
      SAVEFREEPV(idx);
###############################################################################


###############################################################################
###############################################################################
void
_get_mat_col(glp_prob *lp, int col_idx, int num_cols)
   PREINIT:
      int i;
      int *idx;
      double *val;
      int num_nz;
   PPCODE:
      New( 0, idx, num_cols + 1, int);
      New( 0, val, num_cols + 1, double);

      num_nz = glp_get_mat_col(lp, col_idx, idx, val);

      EXTEND(SP, 2*num_nz);

      for( i = 1; i <= num_nz; i++ )
      {
         PUSHs( sv_2mortal( newSViv( idx[i] ) ) );
         PUSHs( sv_2mortal( newSVnv( val[i] ) ) );
      }

      SAVEFREEPV(val);
      SAVEFREEPV(idx);
###############################################################################


###############################################################################
###############################################################################
int
_sort_matrix(glp_prob *lp)
   PREINIT:
   CODE:
      glp_sort_matrix(lp);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_create_index(glp_prob *lp)
   PREINIT:
   CODE:
      glp_create_index(lp);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_find_row(glp_prob *lp, char *row_name)
   PREINIT:
      int status;
   CODE:
      status = glp_find_row(lp, row_name);

      fprintf(stderr, "_find_col(): row_name='%s' status=%d\n", row_name, status);

      if( status == 0 )
      {
         fprintf(stderr, "no row with name '%s' found\n", row_name);
         XSRETURN_UNDEF;
      }

      RETVAL = status;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_find_col(glp_prob *lp, char *col_name)
   PREINIT:
      int status;
   CODE:
      status = glp_find_col(lp, col_name);

      fprintf(stderr, "_find_col(): col_name='%s' status=%d\n", col_name, status);

      if( status == 0 )
      {
         fprintf(stderr, "no column with name '%s' found\n", col_name);
         XSRETURN_UNDEF;
      }

      RETVAL = status;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_delete_index(glp_prob *lp)
   PREINIT:
   CODE:
      glp_delete_index(lp);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_mat_row(glp_prob *lp, int row_idx, AV * avref_row)
   PREINIT:
      int i;
      int num_nz = 0;
      int cnt_nz = 0;
      int num_elems;
      int *idx;
      double *val;
      SV ** elem;

   CODE:
      num_elems = av_len(avref_row) + 1;

      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_row, i, 0 );
         if( elem != NULL && SvOK(*elem) )
         {
            double v = SvNV(*elem);
            if( v != 0.0 )
            {
               num_nz++;
            }
         }
      }

      New( 0, idx, num_nz+1, int );
      New( 0, val, num_nz+1, double );

      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_row, i, 0 );
         if( elem != NULL && SvOK(*elem) )
         {
            double v = SvNV(*elem);
            if( v != 0.0 )
            {
               cnt_nz++;
               idx[cnt_nz] = i+1;
               val[cnt_nz] = v;
            }
         }
      }

      glp_set_mat_row( lp, row_idx, num_nz, idx, val );

      SAVEFREEPV( idx );
      SAVEFREEPV( val );

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_mat_col(glp_prob *lp, int col_idx, AV * avref_col)
   PREINIT:
      int i;
      int num_nz = 0;
      int cnt_nz = 0;
      int num_elems;
      int *idx;
      double *val;
      SV ** elem;

   CODE:
      num_elems = av_len(avref_col) + 1;

      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_col, i, 0 );
         if( elem != NULL && SvOK(*elem) )
         {
            double v = SvNV(*elem);
            if( v != 0.0 )
            {
               num_nz++;
            }
         }
      }

      New( 0, idx, num_nz+1, int );
      New( 0, val, num_nz+1, double );

      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_col, i, 0 );
         if( elem != NULL && SvOK(*elem) )
         {
            double v = SvNV(*elem);
            if( v != 0.0 )
            {
               cnt_nz++;
               idx[cnt_nz] = i + 1;
               val[cnt_nz] = v;
            }
         }
      }

      glp_set_mat_col( lp, col_idx, num_nz, idx, val );

      SAVEFREEPV( idx );
      SAVEFREEPV( val );

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_load_matrix(glp_prob *lp, AV * avref_newRows )
   PREINIT:
      int i,j;
      int row_cnt = 0;
      int col_cnt = 0;
      int num_rows = -1;
      int num_cols = -1;
      int num_nz = 0;
      int cnt_nz = 0;
      int *pnt_ia;
      int *pnt_ja;
      double *pnt_val;
      AV * row;
      SV ** elem;
   CODE:
      num_rows = av_len(avref_newRows) + 1;
      // printf("_load_matrix(): num_rows=%d\n",num_rows);

      //////////////////////////////////////////
      // count number of non-Zero elements
      //////////////////////////////////////////
      for( i = 0; i < num_rows; i++ )
      {
         elem = av_fetch( avref_newRows, i, 0 );

         if( elem != NULL )
         {
            row  = (AV*) SvRV(*elem);
            if( num_cols < av_len(row) + 1) num_cols = av_len(row) + 1;

            for( j = 0; j < av_len(row) + 1; j++ )
            {
               elem = av_fetch( row, j, 0 );
               if( elem != NULL && SvOK(*elem) )
               {
                  double val = SvNV(*elem);
                  if( val != 0.0 )
                  {
                     num_nz++;
                  }
               }
            }
         }
      }
      //////////////////////////////////////////
      // printf("_load_matrix(): num_nz=%d\n",num_nz);

      //////////////////////////////////////////
      // allocate memory for GLPK call
      //////////////////////////////////////////
      New( 0, pnt_ia,  num_nz+1, int);
      New( 0, pnt_ja,  num_nz+1, int);
      New( 0, pnt_val, num_nz+1, double);
      //////////////////////////////////////////

      //////////////////////////////////////////
      // load matrix
      //////////////////////////////////////////
      for( i = 0; i < num_rows; i++ )
      {
         elem = av_fetch( avref_newRows, i, 0 );
         // printf("_load_matrix(): i=%d\n",i);

         if( elem != NULL )
         {
            row  = (AV*) SvRV(*elem);
            for( j = 0; j < av_len(row) + 1; j++ )
            {
               // printf("_load_matrix(): i=%d j=%d\n",i,j);
               elem = av_fetch( row, j, 0 );
               if( elem != NULL && SvOK(*elem) )
               {
                  double val = SvNV(*elem);
                  if( val != 0.0 )
                  {
                     cnt_nz++;
                     // printf("_load_matrix(): i=%d j=%d cnt_nz=%d val=%g\n",i,j,cnt_nz,val);
                     pnt_ia[cnt_nz]  = i + 1;
                     pnt_ja[cnt_nz]  = j + 1 ;
                     pnt_val[cnt_nz] = val ;
                  }
               }
            }
         }
      }
      //////////////////////////////////////////

      glp_load_matrix(lp, num_nz, pnt_ia, pnt_ja, pnt_val);

      SAVEFREEPV(pnt_ia);
      SAVEFREEPV(pnt_ja);
      SAVEFREEPV(pnt_val);

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_del_rows(glp_prob *lp, AV * avref_del_idxs )
   PREINIT:
      int i;
      int num_elems = -1;
      int num_idx = 0;
      int cnt_idx = 0;
      int *pnt_idx;
      SV ** elem;
   CODE:
      num_elems = av_len(avref_del_idxs) + 1;
      //////////////////////////////////////////

      //////////////////////////////////////////
      // count number of valid index values
      //////////////////////////////////////////
      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_del_idxs, i, 0 );

         if( elem != NULL && SvOK(*elem) )
         {
            num_idx++;
            // int idx = SvIV(*elem);
         }
      }

      New( 0, pnt_idx, num_idx+1, int );


      //////////////////////////////////////////
      // count number of valid index values
      //////////////////////////////////////////
      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_del_idxs, i, 0 );

         if( elem != NULL && SvOK(*elem) )
         {
            cnt_idx++; // increment first, as GLPK start to access at position 1!
            int idx = SvIV(*elem);
            pnt_idx[cnt_idx] = idx;
         }
      }

      glp_del_rows( lp, num_idx, pnt_idx);

      SAVEFREEPV( pnt_idx );

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_del_cols(glp_prob *lp, AV * avref_del_idxs )
   PREINIT:
      int i;
      int num_elems = -1;
      int num_idx = 0;
      int cnt_idx = 0;
      int *pnt_idx;
      SV ** elem;
   CODE:
      num_elems = av_len(avref_del_idxs) + 1;
      //////////////////////////////////////////

      //////////////////////////////////////////
      // count number of valid index values
      //////////////////////////////////////////
      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_del_idxs, i, 0 );

         if( elem != NULL && SvOK(*elem) )
         {
            num_idx++;
            // int idx = SvIV(*elem);
         }
      }

      New( 0, pnt_idx, num_idx+1, int );


      //////////////////////////////////////////
      // count number of valid index values
      //////////////////////////////////////////
      for( i = 0; i < num_elems; i++ )
      {
         elem = av_fetch( avref_del_idxs, i, 0 );

         if( elem != NULL && SvOK(*elem) )
         {
            cnt_idx++; // increment first, as GLPK start to access at position 1!
            int idx = SvIV(*elem);
            pnt_idx[cnt_idx] = idx;
         }
      }

      glp_del_cols( lp, num_idx, pnt_idx);

      SAVEFREEPV( pnt_idx );

      RETVAL = 1;
   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_rii(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_rii(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_rii(glp_prob *lp, int idx, double scale_fac)
   PREINIT:

   CODE:
      glp_set_rii(lp, idx, scale_fac);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
double
_get_sjj(glp_prob *lp, int idx)
   PREINIT:

   CODE:
      RETVAL = glp_get_sjj(lp, idx);

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_set_sjj(glp_prob *lp, int idx, double scale_fac)
   PREINIT:

   CODE:
      glp_set_sjj(lp, idx, scale_fac);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_unscale_prob(glp_prob *lp)
   PREINIT:

   CODE:
      glp_unscale_prob(lp);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_SF_GM perform geometric mean scaling;
# GLP_SF_EQ perform equilibration scaling;
# GLP_SF_2N round scale factors to nearest power of two;
# GLP_SF_SKIP skip scaling, if the problem is well scaled.
# the abouve options can be combined by a bitwise OR operation
# GLP_SF_AUTO routine chooses the scaling options automatically
###############################################################################
int
_scale_prob(glp_prob *lp, int scale_routines)
   PREINIT:

   CODE:
      glp_scale_prob(lp, scale_routines);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_BS make the row basic (make the constraint inactive);
# GLP_NL make the row non-basic (make the constraint active);
# GLP_NU make the row non-basic and set it to the upper bound; if the
# row is not double-bounded, this status is equivalent to
# GLP_NL (only in the case of this routine);
# GLP_NF the same as GLP_NL (only in the case of this routine);
# GLP_NS the same as GLP_NL (only in the case of this routine).
###############################################################################
int
_set_row_stat(glp_prob *lp, int idx, int stat)
   PREINIT:

   CODE:
      glp_set_row_stat(lp, idx, stat);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
# GLP_BS make the column basic;
# GLP_NL make the column non-basic;
# GLP_NU make the column non-basic and set it to the upper bound; if
# the column is not double-bounded, this status is equivalent to
# GLP_NL (only in the case of this routine);
# GLP_NF the same as GLP_NL (only in the case of this routine);
# GLP_NS the same as GLP_NL (only in the case of this routine).
###############################################################################
int
_set_col_stat(glp_prob *lp, int idx, int stat)
   PREINIT:

   CODE:
      glp_set_col_stat(lp, idx, stat);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_std_basis(glp_prob *lp)
   PREINIT:

   CODE:
      glp_std_basis(lp);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_adv_basis(glp_prob *lp)
   PREINIT:
      int future_use = 0;
   CODE:
      glp_adv_basis(lp, future_use);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_cpx_basis(glp_prob *lp)
   PREINIT:

   CODE:
      glp_cpx_basis(lp);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_freeLP(glp_prob *lp);
   PREINIT:

   CODE:

      glp_delete_prob(lp);

      RETVAL = 1;

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_closeGLPK_MIP(glp_iocp  *glpk_env);
   PREINIT:
      int status;
   CODE:
      status = glp_free_env();

      if( status )
      {
         fprintf(stderr, "ERROR: glp_free_env() failed. Returned status: %d\n",status);
         XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }

      if( glpk_env )
      {
         SAVEFREEPV(glpk_env);
         RETVAL = 1;
      }
      else
      {
         fprintf(stderr, "ERROR: _closeGLPK_MIP() failed. Environment did not exist!\n");
         XSRETURN_UNDEF;
      }

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_closeGLPK_IPTCP(glp_iptcp *glpk_env);
   PREINIT:
      int status;
   CODE:
      status = glp_free_env();

      if( status )
      {
         fprintf(stderr, "ERROR: glp_free_env() failed. Returned status: %d\n",status);
         XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }

      if( glpk_env )
      {
         SAVEFREEPV(glpk_env);
         RETVAL = 1;
      }
      else
      {
         fprintf(stderr, "ERROR: _closeGLPK_SIMPLEX() failed. Environment did not exist!\n");
         XSRETURN_UNDEF;
      }

   OUTPUT:
      RETVAL
###############################################################################


###############################################################################
###############################################################################
int
_closeGLPK_SIMPLEX(glp_smcp *glpk_env);
   PREINIT:
      int status;
   CODE:
      status = glp_free_env();

      if( status )
      {
         fprintf(stderr, "ERROR: glp_free_env() failed. Returned status: %d\n",status);
         XSRETURN_UNDEF;
      }
      else
      {
         RETVAL = 1;
      }

      if( glpk_env )
      {
         SAVEFREEPV(glpk_env);
         RETVAL = 1;
      }
      else
      {
         fprintf(stderr, "ERROR: _closeGLPK_SIMPLEX() failed. Environment did not exist!\n");
         XSRETURN_UNDEF;
      }

   OUTPUT:
      RETVAL
###############################################################################

