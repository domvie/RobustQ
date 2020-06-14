#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Fri Oct 25 13:41:39 CEST 2013
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use Math::CPLEX::Env;
use Math::CPLEX::Base;
use Getopt::Std;
use vars qw($opt_s $opt_m $opt_r $opt_v $opt_o $opt_h $opt_l $opt_t);

use constant M             => -10000;
use constant CONSIDER_ZERO => 1e-8;

my ($sfile,$mfile,$rfile,$rvfile,$efm_filename);
my ($cplex_env,$lp);
my $num_reacs_expand;
my ($solutions,$sol_norm);
my $solution_cnt = 0;
my $write_lp_file = 0;
my $num_threads = 1;
my $line_num_sum_z;
my $start_fill = 0;
my $stop_fill = 0;

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
select((select($fh_o),$|=1)[0]);

do_figueiredo();

close $fh_o;
################################################################################


################################################################################
################################################################################
sub do_figueiredo
{
   # get CPLEX environment
   $cplex_env = Math::CPLEX::Env->new();
   die "ERROR: creating CPLEX environment failed!" unless $cplex_env;

   # get CPLEX version
   my $version = $cplex_env->version();
   print "CPLEX Version: $version\n";

   # create MIP problem
   $lp = $cplex_env->createOP();
   die "ERROR: couldn't create Linear Program\n" unless $lp;

   die "ERROR: minimize() failed\n" unless $lp->minimize();

   print "INFO: going to use $num_threads threads\n";
   $cplex_env->setintparam(&Math::CPLEX::Base::CPX_PARAM_THREADS, $num_threads);
   $cplex_env->setdblparam(&Math::CPLEX::Base::CPX_PARAM_EPAGAP,  1e-15);
   $cplex_env->setdblparam(&Math::CPLEX::Base::CPX_PARAM_EPINT,  0.0);
   $cplex_env->setintparam(&Math::CPLEX::Base::CPX_PARAM_POPULATELIM,  9000);
   $cplex_env->setintparam(&Math::CPLEX::Base::CPX_PARAM_SOLNPOOLINTENSITY,  4);
   
   fill_init_lp();

   #############################################################################
   # solve MIP problem
   #############################################################################
   die "ERROR: populate() failed\n" unless $lp->populate();
   #############################################################################

   # for( my $card = 1; $card <= 2; $card++ )
   for( my $card = 1; $card <= $num_reacs_expand; $card++ )
   {
      print "computing solutions with cardinality of $card/$num_reacs_expand, current number of solutions: $solution_cnt\n";
      my $num_sols = $lp->getsolnpoolnumsolns();
      if( $num_sols )
      {
         print "number of solutions for cardinality $card: $num_sols\n";

         $start_fill = $solution_cnt;
         for( my $s = 0; $s < $num_sols; $s++ )
         {
            my $obj_val = int( $lp->getsolnpoolobjval($s) + 0.5 );
            print "MIP objective value for solution $s/$solution_cnt: ", $obj_val, "\n";

            my @vals = $lp->getsolnpoolx($s);
      
            # write numerical values (tr-values) to file
            my $num_access_idx = 0;
            for( my $i = 0; $i < @$reacs; $i++ )
            {
               my $val = $vals[$num_access_idx];
               # my $val = $vals[$num_access_idx + $num_reacs_expand];
               if( $rever->[$i] != 0 )
               {
                  $num_access_idx++;  
                  if( abs($val) < CONSIDER_ZERO )
                  {
                     $val = $vals[$num_access_idx] * (-1);
                     # $val = $vals[$num_access_idx + $num_reacs_expand] * (-1);
                  }
               }
               $val = 0 if abs($val) < CONSIDER_ZERO;
               print $fh_o $val;
               print $fh_o " " if $i != @$reacs - 1;
               $num_access_idx++;  
            }
            print $fh_o "\n";

            # fill array that contains all existing solutions
            $sol_norm->[$solution_cnt] = 0;
            for( my $i = 0; $i < $num_reacs_expand; $i++ )
            {
               my $val = $vals[$i + $num_reacs_expand];
               my $rounded_val = int($val + 0.5);
               # $val = 0 if abs($val) < CONSIDER_ZERO;
               $solutions->[$solution_cnt][$i] = $rounded_val;
               $sol_norm->[$solution_cnt]++ if $rounded_val != 0;
            }

            $solution_cnt++;

         }
         $stop_fill = $solution_cnt;
         add_solutions();
      }
      else
      {
         print "no solutions found for cardinality $card\n";
      }

      print "going to set rhs for sum of Z to ", $card + 1, "\n";
      my $newrhs = [];
      $newrhs->[$line_num_sum_z] = $card + 1;
      $lp->chgrhs($newrhs);

      die "ERROR: populate() failed\n" unless $lp->populate();
   }

   print "number of computed elementary flux modes: $solution_cnt\n";
   print "elementary flux modes were written to '$efm_filename'\n";
   #############################################################################

   #############################################################################
   #############################################################################
   die "ERROR: free() failed\n" unless $lp->free();
   die "ERROR: close() failed\n" unless $cplex_env->close();
   #############################################################################
}
################################################################################


################################################################################
################################################################################
sub add_solutions
{
   for( my $s = $start_fill; $s < $stop_fill; $s++ )
   {
      my $newRows;

      for( my $r = 0; $r < $num_reacs_expand; $r++ )
      {
         if( $solutions->[$s][$r] > 0 )
         {
            $newRows->[0][$r+$num_reacs_expand] = 1.0;
         }
      }

      my $row = { num_rows  => 1,
                  rhs       => [$sol_norm->[$s] - 1],
                  sense     => ['L'],
                  row_names => ["sol_$s"],
                  row_coefs => $newRows};

      die "ERROR: addrows() failed\n" unless $lp->addrows($row);
   }

   #############################################################################
   # write lp file
   #############################################################################
   if( $write_lp_file )
   {
      my $file_num = setLength($solution_cnt,4);
      my $filename = "/tmp/myCPLEX_$file_num.lp";
      print "INFO: going to write lp-file '$filename'\n";
      die "ERROR: writeprob() failed\n" unless $lp->writeprob($filename);
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
   print "entered fill_init_lp()\n";

   #############################################################################
   # define columns
   #############################################################################
   my $obj_coefs;
   my $lower_bnd;
   my $upper_bnd;
   my $col_types;
   my $col_names;
   my $col_cnt = 0;

   # numerical values tr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $obj_coefs->[$col_cnt] = 0.0;
      $lower_bnd->[$col_cnt] = 0.0;
      $upper_bnd->[$col_cnt] = &Math::CPLEX::Base::CPX_INFBOUND;
      $col_types->[$col_cnt] = 'C';
      $col_names->[$col_cnt] = "t_" . $reacs_exp->[$i];
      $col_cnt++;
   }

   # binary values zr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $obj_coefs->[$col_cnt] = 1.0;
      $lower_bnd->[$col_cnt] = 0.0;
      $upper_bnd->[$col_cnt] = 1.0;
      $col_types->[$col_cnt] = 'B';
      $col_names->[$col_cnt] = "z_" . $reacs_exp->[$i];
      $col_cnt++;
   }

   my $cols = { num_cols  => $col_cnt,
                obj_coefs => $obj_coefs,
                # lower_bnd => $lower_bnd,
                # upper_bnd => $upper_bnd,
                col_types => $col_types,
                col_names => $col_names
              };
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
      my $filename = "/tmp/myCPLEX.lp";
      print "INFO: going to write lp-file '$filename'\n";
      die "ERROR: writeprob() failed\n" unless $lp->writeprob($filename);
   }
   #############################################################################
}
################################################################################


################################################################################
################################################################################
sub add_inital_rows
{
   my $newRows;
   my $rhs;
   my $sense;
   my $row_names;
   my $row_cnt = 0;

   # tr <= M*zr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $rhs->[$row_cnt]                    = 0.0;
      $sense->[$row_cnt]                  = 'L';
      $row_names->[$row_cnt]              = "t_lt_Mz_$i";
      $newRows->[$row_cnt][$i]            = 1.0;
      $newRows->[$row_cnt][$i+$num_reacs_expand] = M;
      $row_cnt++;
   }

   # zr <= tr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $rhs->[$row_cnt]                    = 0.0;
      $sense->[$row_cnt]                  = 'L';
      $row_names->[$row_cnt]              = "z_lt_t_$i";
      $newRows->[$row_cnt][$i]            = -1.0;
      $newRows->[$row_cnt][$i+$num_reacs_expand] =  1.0;
      $row_cnt++;
   }

   # add upper bound for flux values tr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $rhs->[$row_cnt]                    = M*(-0.9);
      $sense->[$row_cnt]                  = 'L';
      $row_names->[$row_cnt]              = "ub_$i";
      $newRows->[$row_cnt][$i]            = 1.0;
      $row_cnt++;
   }

   # z_alpha + z_beta <= 1, for all reversible reactions
   my $accessor = 0;
   for( my $i = 0; $i < @$reacs; $i++ )
   {
      if( $rever->[$i] != 0 )
      {
         $rhs->[$row_cnt]                     = 1.0;
         $sense->[$row_cnt]                   = 'L';
         $row_names->[$row_cnt]               = "za_plus_zb_$i";
         $newRows->[$row_cnt][$num_reacs_expand+$accessor]   = 1.0;
         $accessor++;
         $newRows->[$row_cnt][$num_reacs_expand+$accessor] = 1.0;
         $row_cnt++;
      }
      $accessor++;
   }

   # S*tr = 0
   for( my $m = 0; $m < @$metas; $m++ )
   {
      $rhs->[$row_cnt]                     = 0.0;
      $sense->[$row_cnt]                   = 'E';
      $row_names->[$row_cnt]               = $metas->[$m];

      for( my $r = 0; $r < $num_reacs_expand; $r++ )
      {
         $newRows->[$row_cnt][$r] = 0.0;
         $newRows->[$row_cnt][$r] = $stoim_exp->[$m][$r] if abs($stoim_exp->[$m][$r]) > CONSIDER_ZERO;
      }
      $row_cnt++;
   }
   #for( my $m = 0; $m < @$metas; $m++ )
   #{
   #   $rhs->[$row_cnt]                     = CONSIDER_ZERO;
   #   $sense->[$row_cnt]                   = 'L';
   #   $row_names->[$row_cnt]               = $metas->[$m];

   #   for( my $r = 0; $r < $num_reacs_expand; $r++ )
   #   {
   #      $newRows->[$row_cnt][$r] = 0.0;
   #      $newRows->[$row_cnt][$r] = $stoim_exp->[$m][$r] if abs($stoim_exp->[$m][$r]) > CONSIDER_ZERO;
   #   }
   #   $row_cnt++;
   #}
   #for( my $m = 0; $m < @$metas; $m++ )
   #{
   #   $rhs->[$row_cnt]                     = CONSIDER_ZERO*(-1);
   #   $sense->[$row_cnt]                   = 'G';
   #   $row_names->[$row_cnt]               = $metas->[$m];

   #   for( my $r = 0; $r < $num_reacs_expand; $r++ )
   #   {
   #      $newRows->[$row_cnt][$r] = 0.0;
   #      $newRows->[$row_cnt][$r] = $stoim_exp->[$m][$r] if abs($stoim_exp->[$m][$r]) > CONSIDER_ZERO;
   #   }
   #   $row_cnt++;
   #}

   # sum of zr >= 1, avoid trivial solution
   $rhs->[$row_cnt]                     = 1.0;
   # $sense->[$row_cnt]                   = 'G';
   $sense->[$row_cnt]                   = 'E';
   $row_names->[$row_cnt]               = "sum_z";
   for( my $r = 0; $r < $num_reacs_expand; $r++ )
   {
      $newRows->[$row_cnt][$r+$num_reacs_expand] = 1.0;
   }
   $line_num_sum_z = $row_cnt;
   $row_cnt++;

   my $rows = {num_rows  => $row_cnt,
               rhs       => $rhs,
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
   getopts('s:m:r:v:o:hlt:');

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

   if( $opt_t )
   {
      $num_threads = $opt_t;
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

   print "defigueiredo.pl -s sfile -m file -r rfile -v rvfile -o modes_filename [-h -l -t num_threads]\n";
   print "\n";
   print "-s ..... name of file containing stoichiometric matrix (input)\n";
   print "-m ..... name of file containing metabolites (input)\n";
   print "-r ..... name of file containing eactions (input)\n";
   print "-v ..... name of file containing reversibility information (input)\n";
   print "-o ..... name of ouput mode file\n";
   print "-l ..... write lp file for each step\n";
   print "-t ..... number of threads used by CPLEX to solve linear problem\n";
   print "-h ..... print this message\n";
   print "\n";
   print "defigueiredo.pl computes elementary flux modes of a given metabolic system\n";

   exit($exit_code);
}
################################################################################
