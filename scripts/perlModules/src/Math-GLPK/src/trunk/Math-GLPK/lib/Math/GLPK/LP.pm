package Math::GLPK::LP;

use 5.014002;
use strict;
use warnings;

use Carp;
use Math::GLPK::Base;
# require Exporter;

our @ISA = qw(Exporter);
our $AUTOLOAD;
our $VERSION = '0.01';

# our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = ( );


###############################################################################
###############################################################################
sub minimize
{
   my $self = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }

   my $ret = Math::GLPK::Base::_minimize( $self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub maximize
{
   my $self = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }

   Math::GLPK::Base::_maximize($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub get_obj_dir
{
   my $self = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }

   Math::GLPK::Base::_get_obj_dir($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub set_prob_name
{
   my ($self, $prob_name) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new name not provided" unless defined $prob_name;

   return Math::GLPK::Base::_set_prob_name($self->{lp}, $prob_name);
}
###############################################################################


###############################################################################
###############################################################################
sub get_prob_name
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_prob_name($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub set_row_name
{
   my ($self, $idx, $row_name) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row to be renamed not provided" unless defined $idx;
   croak "$whoami: name not provided" unless defined $row_name;

   return Math::GLPK::Base::_set_row_name($self->{lp}, $idx, $row_name);
}
###############################################################################


###############################################################################
###############################################################################
sub set_mat_row
{
   my ($self, $idx, $row_coefs) = @_;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row to be renamed not provided" unless defined $idx;
   croak "$whoami: coefficients of row not provided" unless defined $row_coefs;
   croak "$whoami: coefficients of row not provided in form of ARRAY reference" unless ref $row_coefs eq 'ARRAY';

   return Math::GLPK::Base::_set_mat_row($self->{lp}, $idx, $row_coefs);
}
###############################################################################


###############################################################################
###############################################################################
sub set_mat_col
{
   my ($self, $idx, $col_coefs) = @_;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of col to be renamed not provided" unless defined $idx;
   croak "$whoami: coefficients of col not provided" unless defined $col_coefs;
   croak "$whoami: coefficients of col not provided in form of ARRAY reference" unless ref $col_coefs eq 'ARRAY';

   return Math::GLPK::Base::_set_mat_col($self->{lp}, $idx, $col_coefs);
}
###############################################################################


###############################################################################
###############################################################################
sub set_row_bnds
{
   my ($self, $idx, $sense, $lb, $ub) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row to be renamed not provided" unless defined $idx;
   croak "$whoami: sense not provided" unless defined $sense;
   croak "$whoami: lower bound not provided" unless defined $lb;
   croak "$whoami: upper bound not provided" unless defined $ub;

   return Math::GLPK::Base::_set_row_bnds($self->{lp}, $idx, $sense, $lb, $ub);
}
###############################################################################


###############################################################################
###############################################################################
sub add_rows
{
   my ($self, $num_rows) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: number of rows not provided" unless defined $num_rows;

   return Math::GLPK::Base::_add_rows($self->{lp}, $num_rows);
}
###############################################################################


###############################################################################
###############################################################################
sub load_matrix
{
   my ($self, $row_coefs) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row coefficients not provided" unless defined $row_coefs;
   croak "$whoami: row coefficients not provided as array reference" unless ref $row_coefs eq 'ARRAY';

   return Math::GLPK::Base::_load_matrix($self->{lp}, $row_coefs);
}
###############################################################################


###############################################################################
###############################################################################
sub del_rows
{
   my ($self, $del_idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row indices not provided" unless defined $del_idx;
   croak "$whoami: row indices not provided as array reference" unless ref $del_idx eq 'ARRAY';

   return Math::GLPK::Base::_del_rows($self->{lp}, $del_idx);
}
###############################################################################


###############################################################################
###############################################################################
sub del_cols
{
   my ($self, $del_idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column indices not provided" unless defined $del_idx;
   croak "$whoami: column indices not provided as array reference" unless ref $del_idx eq 'ARRAY';

   return Math::GLPK::Base::_del_cols($self->{lp}, $del_idx);
}
###############################################################################


###############################################################################
###############################################################################
sub sort_matrix
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_sort_matrix($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub create_index
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_create_index($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub find_row
{
   my ($self, $row_name) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row name not provided" unless defined $row_name;

   return Math::GLPK::Base::_find_row($self->{lp}, $row_name);
}
###############################################################################


###############################################################################
###############################################################################
sub find_col
{
   my ($self, $col_name) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: column name not provided" unless defined $col_name;

   return Math::GLPK::Base::_find_col($self->{lp}, $col_name);
}
###############################################################################


###############################################################################
###############################################################################
sub delete_index
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_delete_index($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub get_row_type
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_type($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_row_lb
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_lb($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_row_ub
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_ub($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_col_type
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_type($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_col_lb
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_lb($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_col_ub
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_ub($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_row_name
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;

   return Math::GLPK::Base::_get_row_name($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_num_rows
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_num_rows($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub set_obj_coef
{
   my ($self, $idx, $obj_coef) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of objective coefficient to set not provided" unless defined $idx;
   croak "$whoami: new objective coefficient not provided" unless defined $obj_coef;

   return Math::GLPK::Base::_set_obj_coef($self->{lp}, $idx, $obj_coef);
}
###############################################################################


###############################################################################
###############################################################################
sub get_obj_coef
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of objective coefficient to set not provided" unless defined $idx;

   return Math::GLPK::Base::_get_obj_coef($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_mat_row
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: row index not provided" unless defined $idx;

   my $num_rows = $self->get_num_rows();

   return Math::GLPK::Base::_get_mat_row($self->{lp}, $idx, $num_rows);
}
###############################################################################


###############################################################################
###############################################################################
sub get_mat_col
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: col index not provided" unless defined $idx;

   my $num_cols = $self->get_num_cols();

   return Math::GLPK::Base::_get_mat_col($self->{lp}, $idx, $num_cols);
}
###############################################################################


###############################################################################
###############################################################################
sub set_col_name
{
   my ($self, $idx, $col_name) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column to be renamed not provided" unless defined $idx;
   croak "$whoami: new name not provided" unless defined $col_name;

   return Math::GLPK::Base::_set_col_name($self->{lp}, $idx, $col_name);
}
###############################################################################


###############################################################################
###############################################################################
sub add_cols
{
   my ($self, $num_cols) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: number of cols not provided" unless defined $num_cols;

   return Math::GLPK::Base::_add_cols($self->{lp}, $num_cols);
}
###############################################################################


###############################################################################
###############################################################################
sub get_col_name
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_name($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub get_col_kind
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;

   return Math::GLPK::Base::_get_col_kind($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub set_col_kind
{
   my ($self, $idx, $kind) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;
   croak "$whoami: kind of column not provided" unless defined $kind;

   return Math::GLPK::Base::_set_col_kind($self->{lp}, $idx, $kind);
}
###############################################################################


###############################################################################
###############################################################################
sub set_col_bnds
{
   my ($self, $idx, $type, $lb, $ub) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;
   croak "$whoami: type of column not provided" unless defined $type;
   croak "$whoami: lower bound of column not provided" unless defined $lb;
   croak "$whoami: upper bound of column not provided" unless defined $ub;

   return Math::GLPK::Base::_set_col_bnds($self->{lp}, $idx, $type, $lb, $ub);
}
###############################################################################


###############################################################################
###############################################################################
sub get_num_cols
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_num_cols($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub get_num_nz
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_num_nz($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub set_obj_name
{
   my ($self, $obj_name) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: new preprocessing technique not provided" unless defined $obj_name;

   return Math::GLPK::Base::_set_obj_name($self->{lp}, $obj_name);
}
###############################################################################


###############################################################################
###############################################################################
sub get_obj_name
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_get_obj_name($self->{lp});
}
##############################################################################


###############################################################################
###############################################################################
sub newcols
{
   my $self      = shift;
   my $cols      = shift;
   my ($glpk_obj, $env);
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: data specifying columns not provided" unless $cols;
   croak "$whoami: column data is not stored in a HASH reference" unless ref($cols) eq 'HASH';

   my $num_cols  = $cols->{num_cols};
   my $obj_coefs = $cols->{obj_coefs};
   my $types_bnd = $cols->{types_bnd};
   my $lower_bnd = $cols->{lower_bnd};
   my $upper_bnd = $cols->{upper_bnd};
   my $col_types = $cols->{col_types};
   my $col_names = $cols->{col_names};

   croak "$whoami: number of new columns was not provided" unless defined $num_cols;
   

   if( ! defined $obj_coefs || ref($obj_coefs) ne 'ARRAY' )
   {
      croak "$whoami: reference to array containing coefficients for objective function not (correctly) provided";
   }

   if( ! defined $types_bnd )
   {
      $types_bnd = [];
   }
   elsif( ref $types_bnd ne 'ARRAY' )
   {
      croak "$whoami: types bounds must be defined via an array reference";
   }

   if( ! defined $lower_bnd )
   {
      $lower_bnd = [];
   }
   elsif( ref $lower_bnd ne 'ARRAY' )
   {
      croak "$whoami: lower bounds must be defined via an array reference";
   }

   if( ! defined $upper_bnd )
   {
      $upper_bnd = [];
   }
   elsif( ref $upper_bnd ne 'ARRAY' )
   {
      croak "$whoami: upper bounds must be defined via an array reference";
   }

   if( ! defined $col_types )
   {
      $col_types = [];
   }
   elsif( ref $col_types ne 'ARRAY' )
   {
      croak "$whoami: column types must be defined via an array reference";
   }

   if( ! defined $col_names )
   {
      $col_names = [];
   }
   elsif( ref $col_names ne 'ARRAY' )
   {
      croak "$whoami: column names must be defined via an array reference";
   }

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }



   unless( $glpk_obj = $self->{glpk_env} )
   {
      carp "$whoami: Couldn't get Math::GLPK::Env object.";
      return undef;
   }

   unless( $env = $glpk_obj->_get_env() )
   {
      carp "$whoami: Couldn't get GLPK environment.";
      return undef;
   }

   # set number of columns of linear program
   unless( Math::GLPK::Base::_add_cols($self->{lp}, $num_cols) )
   {
      carp "$whoami: Couldn't set number of columns";
      return undef;
   }

   # add objective function
   for( my $i = 0; $i < $num_cols; $i++ )
   {
      my $coef = 0.0;
      $coef = $obj_coefs->[$i] if defined $obj_coefs->[$i];
      unless( Math::GLPK::Base::_set_obj_coef($self->{lp}, $i+1, $coef) )
      {
         carp "$whoami: Couldn't set objective coefficient of column ", $i+1," to ", $coef;
         return undef;
      }
   }

   # set columns names if defined
   if( $col_names )
   {
      for( my $i = 0; $i < $num_cols; $i++ )
      {
         my $name = "dummy$i";
         $name = $col_names->[$i] if defined $col_names->[$i];
         unless( Math::GLPK::Base::_set_col_name($self->{lp}, $i+1, $name ) )
         {
            carp "$whoami: Couldn't set name of column ", $i+1," to ", $name;
            return undef;
         }
      }
   }

   # set column types if defined
   if( $col_types )
   {
      for( my $i = 0; $i < $num_cols; $i++ )
      {
         my $type = &Math::GLPK::Base::GLP_CV;
         $type = $col_types->[$i] if defined $col_types->[$i];
         unless( Math::GLPK::Base::_set_col_kind($self->{lp}, $i+1, $type ) )
         {
            carp "$whoami: Couldn't set kind of column ", $i+1," to ", $type;
            return undef;
         }
      }
   }

   # set bounds
   if( $types_bnd )
   {
      for( my $i = 0; $i < $num_cols; $i++ )
      {
         my $type = &Math::GLPK::Base::GLP_FX;
         $type = $types_bnd->[$i] if defined $types_bnd->[$i];

         my $lb = 0.0;
         $lb = $lower_bnd->[$i] if defined $lower_bnd->[$i];

         my $ub = 0.0;
         $ub = $upper_bnd->[$i] if defined $upper_bnd->[$i];

         unless( Math::GLPK::Base::_set_col_bnds($self->{lp}, $i+1, $type, $lb, $ub ) )
         {
            carp "$whoami: Couldn't set of bounds of column ", $i+1," to  type ", $type, " lower bound ", $lb, " upper bound ", $ub;
            return undef;
         }
      }
   }

   # it seems that we could call all GLPK subroutines with out dying -> return a true value
   return 1;
}
###############################################################################


###############################################################################
###############################################################################
sub addrows
{
   my $self     = shift;
   my $rows     = shift;
   my $glpk_obj;
   my $env;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: data specifying rows not provided" unless $rows;
   croak "$whoami: row data is not stored in a HASH reference" unless ref($rows) eq 'HASH';

   my $num_rows  = $rows->{num_rows};
   my $lower_bnd = $rows->{lower_bnd};
   my $upper_bnd = $rows->{upper_bnd};
   my $sense     = $rows->{sense};
   my $row_names = $rows->{row_names};
   my $row_coefs = $rows->{row_coefs};

   croak "$whoami: number of new rows was not provided" unless defined $num_rows;

   if( ! defined $lower_bnd )
   {
      $lower_bnd = [];
   }
   elsif( ref $lower_bnd ne 'ARRAY' )
   {
      croak "$whoami: lower bound of rows must be defined via an array reference";
   }

   if( ! defined $upper_bnd )
   {
      $upper_bnd = [];
   }
   elsif( ref $upper_bnd ne 'ARRAY' )
   {
      croak "$whoami: upper bound of rows must be defined via an array reference";
   }

   if( ! defined $sense )
   {
      $sense = [];
   }
   elsif( ref $sense ne 'ARRAY' )
   {
      croak "$whoami: row sense must be defined via an array reference";
   }

   if( ! defined $row_names )
   {
      $row_names = [];
   }
   elsif( ref $row_names ne 'ARRAY' )
   {
      croak "$whoami: row names must be defined via an array reference";
   }

   if( ! defined $row_coefs )
   {
      $row_coefs = [];
   }
   elsif( ref $row_coefs ne 'ARRAY' )
   {
      croak "$whoami: row coefficents must be defined via an array reference";
   }

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be closed.";
      return undef;
   }

   unless( $glpk_obj = $self->{glpk_env} )
   {
      carp "$whoami: Couldn't get Math::GLPK::Env object.";
      return undef;
   }

   unless( $env = $glpk_obj->_get_env() )
   {
      carp "$whoami: Couldn't get GLPK environment.";
      return undef;
   }

   my $num_existing_rows = $self->get_num_rows();

   # set number of rows to be added
   unless( Math::GLPK::Base::_add_rows($self->{lp}, $num_rows ) )
   {
      carp "$whoami: Couldn't set numbers of rows to be added.";
      return undef;
   }



   # set name of rows
   if( $row_names )
   {
      for( my $i = 0; $i < $num_rows; $i++ )
      {
         my $name = "dummy$i";
         $name = $row_names->[$i] if defined $row_names->[$i];
         unless( Math::GLPK::Base::_set_row_name($self->{lp}, $num_existing_rows + $i+1, $name ) )
         {
            carp "$whoami: Couldn't set name of row ", $i+1," to ", $name;
            return undef;
         }
      }
   }

   # set bounds
   my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
   my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
   my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
   my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
   my $fx = &Math::GLPK::Base::GLP_FX;

   if( $sense )
   {
      for( my $i = 0; $i < $num_rows; $i++ )
      {
         my $type = $fx;
         $type = $sense->[$i] if defined $sense->[$i];

         my $lb = 0.0;
         $lb = $lower_bnd->[$i] if defined $lower_bnd->[$i];

         my $ub = 0.0;
         $ub = $upper_bnd->[$i] if defined $upper_bnd->[$i];

         unless( Math::GLPK::Base::_set_row_bnds($self->{lp}, $num_existing_rows + $i + 1, $type, $lb, $ub ) )
         {
            carp "$whoami: Couldn't set of bounds of row ", $i+1," to  type ", $type, " lower bound ", $lb, " upper bound ", $ub;
            return undef;
         }
      }
   }

   if( $num_existing_rows == 0 )
   {
      unless ( Math::GLPK::Base::_load_matrix($self->{lp}, $row_coefs) )
      {
         carp "$whoami: loading GLPK matrix failed";
         return undef;
      }
   }
   else
   {
      for( my $i = 0; $i < $num_rows; $i++ )
      {
         unless( Math::GLPK::Base::_set_mat_row($self->{lp}, $num_existing_rows + $i + 1, $row_coefs->[$i] ) )
         {
            carp "$whoami: Couldn't set of coefficient for row ", $i + 1, "\n";
            return undef;
         }
      }
   }

   return 1;
}
###############################################################################


###############################################################################
###############################################################################
sub read_sol
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_read_sol($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub write_sol
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_write_sol($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub read_mip
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_read_mip($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub read_mps
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_read_mps($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub write_mps
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_write_mps($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub read_lp
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_read_lp($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub write_lp
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_write_lp($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub read_prob
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_read_prob($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub write_prob
{
   my $self = shift;
   my $filename = shift;
   my $whoami = _whoami();

   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: filename was not provided" unless $filename;

   unless( $self->{lp} )
   {
      carp "$whoami: There is no valid Linear Program to be written.";
      return undef;
   }
   
   Math::GLPK::Base::_write_prob($self->{lp}, $filename);
}
###############################################################################


###############################################################################
###############################################################################
sub get_rii
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;

   return Math::GLPK::Base::_get_rii($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub set_rii
{
   my ($self, $idx, $scale_fac) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;
   croak "$whoami: scaling factor of row not provided" unless defined $scale_fac;

   return Math::GLPK::Base::_set_rii($self->{lp}, $idx, $scale_fac);
}
###############################################################################


###############################################################################
###############################################################################
sub get_sjj
{
   my ($self, $idx) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of column not provided" unless defined $idx;

   return Math::GLPK::Base::_get_sjj($self->{lp}, $idx);
}
###############################################################################


###############################################################################
###############################################################################
sub set_sjj
{
   my ($self, $idx, $scale_fac) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;
   croak "$whoami: scaling factor of column not provided" unless defined $scale_fac;

   return Math::GLPK::Base::_set_sjj($self->{lp}, $idx, $scale_fac);
}
###############################################################################


###############################################################################
###############################################################################
sub set_row_stat
{
   my ($self, $idx, $stat) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;
   croak "$whoami: row status not provided" unless defined $stat;

   return Math::GLPK::Base::_set_row_stat($self->{lp}, $idx, $stat);
}
###############################################################################


###############################################################################
###############################################################################
sub set_col_stat
{
   my ($self, $idx, $stat) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: index of row not provided" unless defined $idx;
   croak "$whoami: column status not provided" unless defined $stat;

   return Math::GLPK::Base::_set_col_stat($self->{lp}, $idx, $stat);
}
###############################################################################


###############################################################################
###############################################################################
sub unscale_prob
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_unscale_prob($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub scale_prob
{
   my ($self, $scale_routine) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};
   croak "$whoami: scale routine not provided" unless defined $scale_routine;

   return Math::GLPK::Base::_scale_prob($self->{lp}, $scale_routine);
}
###############################################################################


###############################################################################
###############################################################################
sub std_basis
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_std_basis($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub adv_basis
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_adv_basis($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub cpx_basis
{
   my ($self) = @_;
   my $whoami = _whoami();

   # do some checks
   croak "$whoami: was not called for a " . __PACKAGE__ . " object" unless ref($self) && $self->isa(__PACKAGE__);
   croak "$whoami: there is no valid GLPK environment" unless defined $self->{glpk_env};

   return Math::GLPK::Base::_cpx_basis($self->{lp});
}
###############################################################################


###############################################################################
###############################################################################
sub _whoami
{
   ( caller(1) )[3]
}
###############################################################################


###############################################################################
###############################################################################
# sub DESTROY
# {
#    my $self = shift;
#    print "DESTROY LP.pm";
# 
#    # free Linear Program if it still exists
#    $self->free() if $self->{lp};
# }
###############################################################################


1;

__END__

=head1 NAME

Math::GLPK::LP - Perl extension that allows to access many of GLPK's linear
programming functions.

=head1 SYNOPSIS

  # create GLPK Simplex Environment
  my $glpk_env = Math::GLPK::EnvSimplex->new();

  # create GLPK linear program
  my $lp = $glpk_env->createLP();

  # define type of optimization
  $lp->maximize();

  # define columns
  my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
  my $cv = &Math::GLPK::Base::GLP_CV; # continuous variable
  my $cols = { num_cols  => 2,
               obj_coefs => [ 0.6,  0.5],
               types_bnd => [ $lo,  $lo],
               lower_bnd => [ 0.0,  0.0],
               upper_bnd => [ 0.0,  0.0],
               col_types => [ $cv,  $cv],
               col_names => ['c1', 'c2']};
  die "ERROR: newcols() failed\n" unless $lp->newcols($cols);

  # define rows
  # constraint matrix:
  #  1.0   2.0
  #  3.0   1.0
  my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
  my $newRows;
  $newRows->[0][0] = 1.0;
  $newRows->[0][1] = 2.0;
  $newRows->[1][0] = 3.0;
  $newRows->[1][1] = 1.0;
  my $rows = {num_rows  => 2,
              upper_bnd => [1.0, 2.0],
              lower_bnd => [0.0, 0.0],
              sense     => [ $up, $up],
              row_names => ["row1", "row2"],
              row_coefs => $newRows};

  # solve linear program
  $lp->simplex();

  # get results
  my $status = $lp->get_status();
  my $obj_val = $lp->get_obj_val();

  for( my $c = 1; $c <= $lp->get_num_cols; $c++ )
  {
     print "column '", $lp->get_col_name($c), "': ", $lp->get_col_prim($c), "\n";
  }
  

  # free GLPL resources
  $lp->free();
  $glpk_env->close();
   

=head1 DESCRIPTION

Math::GLPK::LP is a parent class for Math::GLPK::LPSimplex, Math::GLPK::LPIpt,
and Math::GLPK::LPMip. This set of classes is used to create, modify, solve,
and free linear programs using GLPK's C library. Math::GLPK::LP and its
children uses Math::GLPK::Base to communicate with the GLPK C library.
GLPK is a free linear programming solvers that is available
for most operating systems.
Naturally, GLPK must be installed on your system if you
want to use the module of Math::GLPK.
The module was developed and tested with GLPK version 4.45.

=head2 EXPORT

None by default.

=head2 add_cols

Tell GLPK how many columns are going to be added to existing linear program.

  $lp->add_cols($num_cols);

=head2 add_rows

Tell GLPK how many rows are going to be added to existing linear program.

  $lp->add_rows($num_rows);

=head2 addrows

This method is a wrapper for a set of GLPK functions which need to be
called when rows are added to the linear program.

  my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
  my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
  my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
  my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
  my $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable
  my $newRows;
  $newRows->[0][0] = 1.0;
  $newRows->[0][1] = 2.0;
  $newRows->[1][0] = 3.0;
  $newRows->[1][1] = 1.0;
  my $rows = {num_rows  => 2,
              upper_bnd => [1.0, 2.0],
              lower_bnd => [0.0, 0.0],
              sense     => [ $up, $up],
              row_names => ["row1", "row2"],
              row_coefs => $newRows};

  die "ERROR: addrows() failed\n" unless $lp->addrows($rows);

Instead of using C<addrows> it is possible to execute the following
methods to add new rows to the linear program: C<add_rows>, C<set_row_name>,
C<set_row_bnds>, and C<set_mat_row> or C<load_matrix>. Consequently,
the above lines of code could be realized as follows:

  $num_rows  = 2,
  $ub        = [1.0, 2.0],
  $lb        = [0.0, 0.0],
  $sense     = [ $up, $up],
  $row_names = ["row1", "row2"],
  $newRows;
  $newRows->[0][0] = 1.0;
  $newRows->[0][1] = 2.0;
  $newRows->[1][0] = 3.0;
  $newRows->[1][1] = 1.0;

  $lp->add_rows($num_rows);
  for( my $r = 1; $r <= $num_rows; $r++ )
  {
     $lp->set_row_name($r, $row_names->[$r-1]);
     $lp->set_row_bnds($r, $sense->[$r-1], $lb->[$r-1], $ub->[$r-1]);
  }
  $lp->load_matrix($newRows);


=head2 adv_basis

This method constructs an advanced initial LP basis.

  $lp->adv_basis();

=head2 cpx_basis

This method constructs an initial basis with the algorithm proposed by R. Bixby.

  $lp->cpx_basis();

=head2 create_index

This routine creates the name index.  The name index is an auxiliary data structure, which is
intended to quickly (i.e. for logarithmic time) and rows and columns by their names.
This routine can be called at any time. If the name index already exists, the routine does nothing.

  $lp->create_index();

This routine is supposed to be used together with C<find_row> and C<find_col>. e.g.

  $lp->create_index();
  print "row 'row1' found at index ",  $lp->find_row("row1"), "\n";
  print "row 'row2' found at index ",  $lp->find_row("row2"), "\n";
  print "column 'c1' found at index ", $lp->find_col("c1"), "\n";
  print "column 'c2' found at index ", $lp->find_col("c2"), "\n";
  $lp->delete_index();

=head2 del_cols

This routine deletes columns from the systems.

  # delete second and fourth column
  $lp->del_cols([2,4]);

  # delete third column
  $lp->del_cols([3]);

=head2 del_rows

This routine deletes rows from the systems.

  # delete first and third row
  $lp->delete_rows([1,3]);

  # delete second row
  $lp->delete_rows([2]);

=head2 delete_index

Delete name index.

  $lp->delete_index();

=head2 find_col

Find column by name. This method returns the name of the column which was set
by C<set_col_name>. If no column with the specified name was found, 0 is returned,

  $col_idx = $lp->find_col("c1");

=head2 find_row

Find row by name. This method returns the name of the row which was set
by C<set_row_name>. If no row with the specified name was found, 0 is returned,

  $row_idx = $lp->find_row("row1");

=head2 get_col_kind

This method returns the kind of a column.

  # return kind of second column
  $kind = $lp->get_col_kind(2)

The returned kind is either GLP_CV (continuous variable), GLP_IV (integer variable), or GLP_BV (binary variable).

=head2 get_col_lb

This method returns lower bound of a column.

  # get lower bound of first column
  $lb = $lp->get_col_lb(1);

=head2 get_col_name

This method returns name of a column.

  # get name of third column
  $name = $lp->get_col_name(3);

=head2 get_col_type

This method returns the type of a column.

  my $type = $lp->get_col_type(3);

The return type is either GLP_FR (free -unbounded- variable), GLP_LO (variable with lower bound),
GLP_UP (variable with upper bound), GLP_DB (double-bounded variable), GLP_FX (fixed variable).

=head2 get_col_ub

This method returns upper bound of a column.

  # get upper bound of first column
  $ub = $lp->get_col_ub(1);

=head2 get_mat_col

This method retunrs (non-zero) elements of a column of
the constraint matrix. The result is stored in a has
where the key of a hash element is the row index.

  # get non-zero constraint values of the second column
  %nz_col_vals = $lp->get_mat_col(2);

=head2 get_mat_row

This method retunrs (non-zero) elements of a row of
the constraint matrix. The result is stored in a has
where the key of a hash element is the column index.

  # get non-zero constraint values of the third row
  %nz_row_vals = $lp->get_mat_row(3);

=head2 get_num_cols

Get number of columns of the linear program

   $num_col = $lp->get_num_cols();

=head2 get_num_nz

Get number of non-zero elements in constraint matrix of the linear program

  $num_nz = $lp->get_num_nz();

=head2 get_num_rows

Get number of rows of the linear program

   $num_rows = $lp->get_num_ros();

=head2 get_obj_coef

Get objective coefficient of a variable (column):

  # get objective coefficient of second variable/column
  $obj_col2 = $lp->get_obj_coef(2);

=head2 get_obj_dir

Get direction (minimize/maximize) of optimization

  $dir = $lp->get_obj_dir();

=head2 get_obj_name

Get name of objective function

  $obj_name = $lp->get_obj_name();

=head2 get_prob_name

Get name of linear problem

  $prob_name = $lp->get_prob_name();

=head2 get_rii

Get row scaling factor for a row

  # get scaling factor of third row
  my $scaling = $lp->get_rii(3);

=head2 get_row_lb

Get lower bound of a row

  # get lower bound of second row
  $lb = $lp->get_row_lb(2);

=head2 get_row_name

Get name of a row

  # get name of first row
  $name = $lp->get_row_name();

=head2 get_row_type

Get type of a row

  # get type of first row
  $type = $lp->get_row_type();


The return type is either GLP_FR (free -unbounded- variable), GLP_LO (variable with lower bound),
GLP_UP (variable with upper bound), GLP_DB (double-bounded variable), GLP_FX (fixed variable).

=head2 get_row_ub

Get upper bound of a row

  # get upper bound of third row
  $lb = $lp->get_row_ub(3);

=head2 get_sjj

Get scaling factor of a column

  # get scaling factor of second column
  $scaling = $lp->get_sjj(2);

=head2 load_matrix

Load constraint matrix of a linear program

=head2 maximize

Tell GLPK to maximize the objective function

   $lp->maximize();

=head2 minimize

Tell GLPK to minimize the objective function

   $lp->minimize();

=head2 newcols

Define new columns of a linear problem

  $cv = &Math::GLPK::Base::GLP_CV; # continuous variable;
  $iv = &Math::GLPK::Base::GLP_IV; # integer variable;
  $bv = &Math::GLPK::Base::GLP_BV; # binary variable.

  $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
  $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
  $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
  $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
  $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable
  $cols = { num_cols  => 2,
            obj_coefs => [ 0.6,  0.5],
            types_bnd => [ $lo,  $lo],
            lower_bnd => [ 0.0,  0.0],
            upper_bnd => [ 0.0,  3.0],
            col_types => [ $iv,  $cv],
            col_names => ['c1', 'c2']};
  $lp->newcols($cols);

The method C<newcols> is a wrapper fo Math::GLPK::LP::set_obj_coef,
Math::GLPK::LP::et_col_name, Math::GLPK::LP::set_col_kind, and
Math::GLPK::LP::set_col_bnds. Consequently, the above lines of code could be realized by:

  $cv = &Math::GLPK::Base::GLP_CV; # continuous variable;
  $iv = &Math::GLPK::Base::GLP_IV; # integer variable;
  $bv = &Math::GLPK::Base::GLP_BV; # binary variable.

  $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
  $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
  $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
  $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
  $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable

  $num_cols = 2;
  $obj_coefs = [ 0.6,  0.5];
  $types_bnd = [ $lo,  $lo],
  $lower_bnd = [ 0.0,  0.0],
  $upper_bnd = [ 0.0,  3.0],
  $col_types = [ $iv,  $cv],
  $col_names = ['c1', 'c2'];

  $lp->add_cols($num_cols);
  for(my $c = 1; $c <= $num_cols; $c++ )
  {
    $lp->set_obj_coef($c, $obj_coefs->[$c-1]);
    $lp->set_col_name($c, $col_names->[$c-1]);
    $lp->set_col_kind($c, $col_types->[$c-1]);
    $lp->set_col_bnds($c, $types_bnd->[$c-1], $lower_bnd->[$c-1], $upper_bnd->[$c-1]);
  }

=head2 read_lp

Read problem data in CPLEX LP format from a text file.

  $lp->read_lp("linprob.lp");

=head2 read_mps

Read problem data in MPS format from a text file.

  $lp->read_mps("linprob.mps");

=head2 read_prob

Read problem data in the GLPK LP/MIP format from a text file.

  $lp->read_prob("linprob.glpk");

Returns 0 if the operation was successful. Typically, the file to be read
is written by C<write_prob>.

=head2 read_sol

Read basic solution from a text file

  $lp->read_sol("solution.txt");

Returns 0 if the operation was successful. Typically, the file to be read is written by C<write_sol>.

=head2 scale_prob

Perform automatic scaling of problem data.
The following scaling options are available
GLP_SF_GM (perform geometric mean scaling), GLP_SF_EQ (perform equilibration scaling),
GLP_SF_2N (round scale factors to nearest power of two), and
GLP_SF_SKIP (skip scaling, if the problem is well scaled).
The above parameters can be combined by a boolean OR operation.

  $lp->scale_prob(&Math::GLPK::Base::GLP_SF_GM | &Math::GLPK::Base::GLP_SF_2N);


=head2 set_col_bnds

Set bounds of a variable/column

  # set bounds of third variable/column
  $lb = 0.5;
  $up = 9.0;
  $type = &Math::GLPK::Base::GLP_DB;
  $lp->set_col_bnds(3 $type, $lb, $ub);

=head2 set_col_kind

Set kind of a variable/column

  # set kind of first column to 'binary'
  $kind = &Math::GLPK::Base::GLP_BV;
  $lp->set_col_kind(1, $kind);

=head2 set_col_name

Set name of a variable/column

  # set name of fourth column
  $lp->set_col_name(4, "variable_4");

=head2 set_col_stat

Set the current status of a column. The following options are allowed:
GLP_BS (make the column basic), GLP_NL (make the column non-basic),
GLP_NU (make the column non-basic and set it to the upper bound -
if the column is not double-bounded, this status is equivalent to GLP_NL (only in the case of this routine)),
GLP_NF (the same as GLP_NL (only in the case of this routine)),
GLP_NS (the same as GLP_NL (only in the case of this routine)).

  # set status of second column to 'basic - make the constraint inactive'
  $lp->set_col_stat(2, &Math::GLPK::Base::GLP_BS);

=head2 set_mat_col

Set elements of constraint matrix of a column

  # set matrix elements of third column
  $new_vals = [3.0, -1.3, 0.0, 2.5];
  $lp->set_mat_col(3, $new_vals);

=head2 set_mat_row

Set elements of constraint matrix of a row

  # set matrix elements of second row
  $new_vals = [1.0, -0.3, 1.0, 0.0];
  $lp->set_mat_row(2, $new_vals);

=head2 set_obj_coef

Set objective coefficient of a variable/column

  # set objective coefficient of third variable/column
  $lp->set_obj_coef(3, -1.5);

=head2 set_obj_name

Set name of objective function

  $lp->set_obj_name("Smart_objective");

=head2 set_prob_name

Set name of linear problem

  $lp->set_prob_name("Biomass_optimization");

=head2 set_rii

  Set scaling factor of a row.

  # set scaling factor of second row to 2.0
  $lp->set_rii(2, 2.0);

=head2 set_row_bnds

Set bounds of a row. The following bound types are supported
&Math::GLPK::Base::GLP_FR, &Math::GLPK::Base::GLP_LO, &Math::GLPK::Base::GLP_UP,
&Math::GLPK::Base::GLP_DB, &Math::GLPK::Base::GLP_FX.

  # set bounds of sixth row
  $db = &Math::GLPK::Base::GLP_DB;
  $lp->set_row_bnds(6, $db, -3.0, -1.0);

=head2 set_row_name

Set name of a row

  # set name of second row
  $lp->set_row_name("IamNumber2");

=head2 set_row_stat

Set status of a row.  The following options are allowed:
GLP_BS (make the row basic), GLP_NL (make the row non-basic),
GLP_NU (make the row non-basic and set it to the upper bound -
if the row is not double-bounded, this status is equivalent to GLP_NL (only in the case of this routine)),
GLP_NF (the same as GLP_NL (only in the case of this routine)),
GLP_NS (the same as GLP_NL (only in the case of this routine)).

  # set status of second row
  $lp->set_row_stat(2, &Math::GLPK::Base::GLP_BS);

=head2 set_sjj

  Set scaling factor of a column.

  # set scaling factor of third column to 0.5
  $lp->set_sjj(3, 0.5);

=head2 sort_matrix

Sort elements of the constraint matrix rebuilding
its row and column linked lists. On exit from this method the
constraint matrix is unchanged. However, elements in the row linked lists
become ordered by ascending column indices, and the elements in the column
linked lists become ordered by ascending row indices.

  $lp->sort_matrix

=head2 std_basis

This method constructs the "standard" (trivial) initial LP basis.

  $lp->std_basis();

=head2 unscale_prob

Perform unscaling of problem data

  $lp->unscale_prob();

=head2 write_lp

Write linear problem in CPLEX LP format to file

  $lp->write_lp("linprob.lp");

Returns 0 if the operation was successful.

=head2 write_mps

Write linear problem in MPS format to file

  $lp->write_mps("linear_problem.mps");

=head2 write_prob

Write linear problem in GLPK LP/MIP format to a text file.

  $lp->write_prob();

=head2 write_sol

Write basic solution to a text file

  $lp->write_sol("solution.txt");

Returns 0 if the operation was successful.


=head1 SEE ALSO

Further information can be found in the GLPK documentation.

=head1 AUTHOR

Christian Jungreuthmayer, E<lt>christian.jungreuthmayer@boku.ac.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Christian Jungreuthmayer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
