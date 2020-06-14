#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Fri Oct 25 13:41:39 CEST 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Math::GLPK::EnvMip;
use Math::GLPK::Base;
use Getopt::Std;
use vars qw($opt_s $opt_m $opt_r $opt_v $opt_o $opt_h $opt_l);

use constant M             => -1000;
use constant CONSIDER_ZERO => 1e-8;
# use constant CONSIDER_ZERO => 0.0;


my ($sfile,$mfile,$rfile,$rvfile,$efm_filename);
my ($glpk_env,$lp);
my $num_reacs_expand;
my ($solutions,$sol_norm);
my $solution_cnt = 0;
my $write_lp_file = 0;

read_arguments();

my $reacs = read_reactions($rfile);
warn "reacs: @$reacs\n";

my $metas = read_metabolites($mfile);
warn "metas: @$metas\n";

my $rever = read_reversibility($rvfile);
warn "rever: @$rever\n";

my $stoim = read_stoichiomat($sfile);
print_matrix("stoich:\n", $stoim);

my $reacs_exp = expand_reac_names($reacs, $rever);
print "reacs_exp: @$reacs_exp\n";

my $stoim_exp = resolv_reversible_reac($stoim, $rever);
$num_reacs_expand = @$reacs_exp;
print_matrix("expanded stoich:\n", $stoim_exp);

open my $fh_o, ">$efm_filename" or die "ERROR: couldn't open file '$efm_filename' for writing: $!\n";

do_figueiredo();

close $fh_o;
################################################################################


################################################################################
################################################################################
sub do_figueiredo
{
   # get GLPK MIP environment
   $glpk_env = Math::GLPK::EnvMip->new();
   die "ERROR: openGLPK() failed!" unless $glpk_env;

   # create MIP problem
   $lp = $glpk_env->createLP();
   die "ERROR: couldn't create Linear Program\n" unless $lp;

   # switch on presolve
   $glpk_env->set_presolve(&Math::GLPK::Base::GLP_ON);

   die "ERROR: minimize() failed\n" unless $lp->minimize();
   
   fill_init_lp();

   #############################################################################
   # solve MIP problem
   #############################################################################
   die "ERROR: intopt() failed\n" unless $lp->intopt();
   #############################################################################

   #############################################################################
   # retrieve computed values
   #############################################################################
   while( $lp->mip_status() == &Math::GLPK::Base::GLP_OPT )
   {
      print "MIP objective value: ", $lp->mip_obj_val(), "\n";

      # write numerical values (tr-values) to file
      my $num_access_idx = 1;
      for( my $i = 1; $i <= @$reacs; $i++ )
      {
         my $val = $lp->mip_col_val($num_access_idx);
         if( $rever->[$i - 1] != 0 )
         {
            $num_access_idx++;
            if( abs($val) < CONSIDER_ZERO )
            {
               $val = $lp->mip_col_val($num_access_idx) * (-1);
            }
         }
         $val = 0 if abs($val) < CONSIDER_ZERO;
         print $fh_o $val;
         print $fh_o " " if $i != @$reacs;
         $num_access_idx++;
      }
      print $fh_o "\n";

      # fill array that contains all existing solutios
      $sol_norm->[$solution_cnt] = 0;
      for( my $i = 1; $i <= $num_reacs_expand; $i++ )
      {
         my $val = $lp->mip_col_val($i + $num_reacs_expand);
         $val = 0 if abs($val) < CONSIDER_ZERO;
         $solutions->[$solution_cnt][$i - 1] = $val;
         $sol_norm->[$solution_cnt]++ if $val != 0;
      }

      add_solution();

      $solution_cnt++;

      die "ERROR: intopt() failed\n" unless $lp->intopt();
   }

   print "GLPK didn't find an optimal solution -> algorithm stopped.\n";
   print "number of computed elementary flux modes: $solution_cnt\n";
   print "elementary flux modes were written to '$efm_filename'\n";
   #############################################################################

   #############################################################################
   #############################################################################
   die "ERROR: free() failed\n" unless $lp->free();
   die "ERROR: close() failed\n" unless $glpk_env->close();
   #############################################################################
}
################################################################################


################################################################################
################################################################################
sub add_solution
{
   my $newRows;

   my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound

   for( my $r = 0; $r < $num_reacs_expand; $r++ )
   {
      if( $solutions->[$solution_cnt][$r] > 0 )
      {
         $newRows->[0][$r+$num_reacs_expand] = 1.0;
      }
   }

   my $row = { num_rows  => 1,
               lower_bnd => [0.0],
               upper_bnd => [$sol_norm->[$solution_cnt] - 1],
               sense     => [$up],
               row_names => ["sol_$solution_cnt"],
               row_coefs => $newRows};
               
   die "ERROR: addrows() failed\n" unless $lp->addrows($row);

   #############################################################################
   # write lp file
   #############################################################################
   if( $write_lp_file )
   {
      my $file_num = setLength($solution_cnt,4);
      my $filename = "/tmp/myGLPK_$file_num.lp";
      print "INFO: going to write lp-file '$filename'\n";
      die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);
   }
   #############################################################################
}
################################################################################


################################################################################
################################################################################
sub setLength
{
   my $inp = shift;
   my $len = shift;

   while( length $inp < $len )
   {
      $inp = '0' . $inp;
   }

   return $inp;
}
################################################################################


################################################################################
################################################################################
sub fill_init_lp
{
   my $cv = &Math::GLPK::Base::GLP_CV; # continuous variable;
   my $iv = &Math::GLPK::Base::GLP_IV; # integer variable;
   my $bv = &Math::GLPK::Base::GLP_BV; # binary variable.

   my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
   my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
   my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
   my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
   my $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable

   #############################################################################
   # define columns
   #############################################################################
   my $obj_coefs;
   my $types_bnd;
   my $lower_bnd;
   my $upper_bnd;
   my $col_types;
   my $col_names;
   my $col_cnt = 0;

   # numerical values tr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $obj_coefs->[$col_cnt] = 0.0;
      $types_bnd->[$col_cnt] = $lo;
      $lower_bnd->[$col_cnt] = 0.0;
      $upper_bnd->[$col_cnt] = 0.0; # irrelevant for lower bound columns
      $col_types->[$col_cnt] = $cv;
      $col_names->[$col_cnt] = "t_" . $reacs_exp->[$i];
      $col_cnt++;
   }

   # binary values zr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $obj_coefs->[$col_cnt] = 1.0;
      $types_bnd->[$col_cnt] = $db;
      $lower_bnd->[$col_cnt] = 0.0;
      $upper_bnd->[$col_cnt] = 1.0;
      $col_types->[$col_cnt] = $bv;
      $col_names->[$col_cnt] = "z_" . $reacs_exp->[$i];
      $col_cnt++;
   }

   my $cols = { num_cols  => $col_cnt,
                obj_coefs => $obj_coefs,
                types_bnd => $types_bnd,
                lower_bnd => $lower_bnd,
                upper_bnd => $upper_bnd,
                col_types => $col_types,
                col_names => $col_names};
   die "ERROR: newcols() failed\n" unless $lp->newcols($cols);
   #############################################################################

   #############################################################################
   # add initial rows
   #############################################################################
   add_inital_rows();
   #############################################################################

   #############################################################################
   # write lp file
   #############################################################################
   if( $write_lp_file )
   {
      my $filename = "/tmp/myGLPK_init.lp";
      print "INFO: going to write lp-file '$filename'\n";
      die "ERROR: write_lp() failed\n" unless $lp->write_lp($filename);
   }
   #############################################################################

}
################################################################################


################################################################################
################################################################################
sub add_inital_rows
{
   my $newRows;
   my $lower_bnd;
   my $upper_bnd;
   my $sense;
   my $row_names;
   my $row_cnt = 0;

   my $fr = &Math::GLPK::Base::GLP_FR; # -inf < x < +inf Free (unbounded) variable
   my $lo = &Math::GLPK::Base::GLP_LO; #   lb < x < +inf Variable with lower bound
   my $up = &Math::GLPK::Base::GLP_UP; # -inf < x <   ub Variable with upper bound
   my $db = &Math::GLPK::Base::GLP_DB; #   lb < x <   ub Double-bounded variable
   my $fx = &Math::GLPK::Base::GLP_FX; #   lb = x =   ub Fixed variable

   # tr <= M*zr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $lower_bnd->[$row_cnt]              = 0.0; # irrelevant for upper bound rows
      $upper_bnd->[$row_cnt]              = 0.0;
      $sense->[$row_cnt]                  = $up;
      $row_names->[$row_cnt]              = "t_lt_Mz_$i";
      $newRows->[$row_cnt][$i]            = 1.0;
      $newRows->[$row_cnt][$i+$num_reacs_expand] = M;
      $row_cnt++;
   }

   # zr <= tr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $lower_bnd->[$row_cnt]              = 0.0; # irrelevant for upper bound rows
      $upper_bnd->[$row_cnt]              = 0.0;
      $sense->[$row_cnt]                  = $up;
      $row_names->[$row_cnt]              = "z_lt_t_$i";
      $newRows->[$row_cnt][$i]            = -1.0;
      $newRows->[$row_cnt][$i+$num_reacs_expand] =  1.0;
      $row_cnt++;
   }

   # z_alpha + z_beta <= 1, for all reversible reactions
   my $accessor = 0;
   for( my $i = 0; $i < @$reacs; $i++ )
   {
      if( $rever->[$i] != 0 )
      {
         $lower_bnd->[$row_cnt] = 0.0; # irrelevant for upper bound rows
         $upper_bnd->[$row_cnt] = 1.0;
         $sense->[$row_cnt]     = $up;
         $row_names->[$row_cnt] = "za_plus_zb_$i";
         $newRows->[$row_cnt][$num_reacs_expand+$accessor] = 1.0;
         $accessor++;
         $newRows->[$row_cnt][$num_reacs_expand+$accessor] = 1.0;
         $row_cnt++;
      }
      $accessor++;
   }

   # S*tr = 0
   for( my $m = 0; $m < @$metas; $m++ )
   {
      $lower_bnd->[$row_cnt]               = 0.0;
      $upper_bnd->[$row_cnt]               = 0.0;
      $sense->[$row_cnt]                   = $fx;
      $row_names->[$row_cnt]               = $metas->[$m];

      for( my $r = 0; $r < $num_reacs_expand; $r++ )
      {
         $newRows->[$row_cnt][$r] = $stoim_exp->[$m][$r] if abs($stoim_exp->[$m][$r]) > CONSIDER_ZERO;
      }
      $row_cnt++;
   }

   # sum of zr >= 1, avoid trivial solution
   $lower_bnd->[$row_cnt]               = 1.0;
   $upper_bnd->[$row_cnt]               = 0.0;
   $sense->[$row_cnt]                   = $lo;
   $row_names->[$row_cnt]               = "sum_z";
   for( my $r = 0; $r < $num_reacs_expand; $r++ )
   {
      $newRows->[$row_cnt][$r+$num_reacs_expand] = 1.0;
   }
   $row_cnt++;

   my $rows = {num_rows  => $row_cnt,
               lower_bnd => $lower_bnd,
               upper_bnd => $upper_bnd,
               sense     => $sense,
               row_names => $row_names,
               row_coefs => $newRows};

   die "ERROR: addrows() failed\n" unless $lp->addrows($rows);
}
################################################################################





################################################################################
# reaction file has one line that contains a list of the reaction names
# the reaction names are separated by white spaces
################################################################################
sub read_stoichiomat
{
   my $file = shift;
   my $sm;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";

   while( <$fh> )
   {
      my @st_facs = split;
      push @$sm, \@st_facs;
   }

   close $fh;

   return $sm;
}
################################################################################


################################################################################
# reaction file has one line that contains a list of the reaction names
# the reaction names are separated by white spaces
################################################################################
sub read_reversibility
{
   my $file = shift;
   my $rvs;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   $_ = <$fh>;
   @$rvs = split;
   close $fh;

   return $rvs;
}
################################################################################

################################################################################
# reaction file has one line that contains a list of the reaction names
# the reaction names are separated by white spaces
################################################################################
sub read_metabolites
{
   my $file = shift;
   my $mbs;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   $_ = <$fh>;
   s/"//g;
   s/_//g;
   s/#//g;
   @$mbs = split;
   close $fh;

   return $mbs;
}
################################################################################


################################################################################
# reaction file has one line that contains a list of the reaction names
# the reaction names are separated by white spaces
################################################################################
sub read_reactions
{
   my $file = shift;
   my $rcs;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   $_ = <$fh>;
   s/"//g;
   s/>//g;
   s/_//g;
   s/#//g;
   @$rcs = split;
   close $fh;

   return $rcs;
}
################################################################################


################################################################################
# read in program options
################################################################################
sub read_arguments
{
   getopts('s:m:r:v:o:hl');

   if( $opt_h )
   {
      usage();
   }

   if( $opt_s )
   {
      $sfile = $opt_s;
   }
   else
   {
      usage('ERROR: name of input file containing stoichiometric matrix not provided ',-1);
   }

   if( $opt_m )
   {
      $mfile = $opt_m;
   }
   else
   {
      usage('ERROR: name of input file containing metabolite names not provided ',-1);
   }

   if( $opt_r )
   {
      $rfile = $opt_r;
   }
   else
   {
      usage('ERROR: name of input file containing reaction names not provided ',-1);
   }

   if( $opt_v )
   {
      $rvfile = $opt_v;
   }
   else
   {
      usage('ERROR: name of input file containing reaction reversibility information not provided ',-1);
   }

   if( $opt_l )
   {
      $write_lp_file = 1;
   }

   if( $opt_o )
   {
      $efm_filename = $opt_o;
   }
   else
   {
      usage('ERROR: name of mode file (output) not provided',-2);
   }
}
################################################################################


################################################################################
################################################################################
sub expand_reac_names
{
   my $r_names = shift;
   my $rv      = shift;
   my $exp_names;

   for( my $i = 0; $i < @$r_names; $i++ )
   {
      push @$exp_names, $r_names->[$i];

      push @$exp_names, $r_names->[$i] . '_rev' if $rv->[$i] != 0;
   }

   return $exp_names;
}
################################################################################


################################################################################
################################################################################
sub resolv_reversible_reac
{
   my $s = shift;
   my $r = shift;
   my $splice_pos = 0;
   my $new_s;

   # copy existing stoichiometric
   for( my $m = 0; $m < @$s; $m++ )
   {
      for( my $r = 0; $r < @{$s->[$m]}; $r++ )
      {
         $new_s->[$m][$r] = $s->[$m][$r];
      }
   }

   for( my $r = 0; $r < @$rever; $r++ )
   {
      $splice_pos++;
      if( $rever->[$r] )
      {
         # warn "We found a reversible reaction at position $r\n";
         for( my $m = 0; $m < @$s; $m++ )
         {
            # warn "split reversible reaction into two irreversible reaction for metabolite $m\n";
            splice @{$new_s->[$m]}, $splice_pos, 0, -$s->[$m][$r];
         }
         $splice_pos++;
      }
   }

   return $new_s;
}
################################################################################


################################################################################
################################################################################
sub print_matrix
{
   my $message = shift;
   my $matrix  = shift;

   warn $message;

   for( my $m = 0; $m < @$matrix; $m++ )
   {
      for( my $r = 0; $r < @{$matrix->[$m]}; $r++ )
      {
         print STDERR "\t$matrix->[$m][$r]";
      }
      warn "\n";
   }
}
################################################################################


################################################################################
################################################################################
sub usage
{
   my $message   = shift || '';
   my $exit_code = shift || 0;

   print "$message\n" if $message;

   print "defigueiredo.pl -s sfile -m file -r rfile -v rvfile -o modes_filename [-h -w]\n";
   print "\n";
   print "-s ..... name of file containing stoichiometric matrix (input)\n";
   print "-m ..... name of file containing metabolites (input)\n";
   print "-r ..... name of file containing eactions (input)\n";
   print "-v ..... name of file containing reversibility information (input)\n";
   print "-o ..... name of ouput mode file\n";
   print "-w ..... write lp file for each step\n";
   print "-h ..... print this message\n";
   print "\n";
   print "defigueiredo.pl computes elementary flux modes of a given metabolic system\n";

   exit($exit_code);
}
################################################################################
