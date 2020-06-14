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
use vars qw($opt_s $opt_m $opt_r $opt_v $opt_t $opt_o $opt_h $opt_l $opt_p $opt_k);

use constant M             => -2000;
use constant M1            =>  2001;
use constant CONSIDER_ZERO => 1e-8;

my ($sfile,$mfile,$rfile,$rvfile,$tfile,$efm_filename,$max_efms);
my ($target_idx, $target_name);
my $num_tgts = 0;
my ($cplex_env,$lp);
my $num_reacs_expand;
my ($solutions,$sol_norm);
my $solution_cnt = 0;
my $write_lp_file = 0;
my $num_threads = 1;

read_arguments();

my $reacs = read_reactions($rfile);
warn "reacs: @$reacs\n";

my $metas = read_metabolites($mfile);
warn "metas: @$metas\n";

my $rever = read_reversibility($rvfile);
warn "rever: @$rever\n";

my $target = read_targets($rever,$tfile);
warn "target: @$target\n";

my $stoim = read_stoichiomat($sfile);
print_matrix("stoich:\n", $stoim);

my $reacs_exp = expand_reac_names($reacs, $rever);
print "reacs_exp: @$reacs_exp\n";

my $stoim_exp = resolv_reversible_reac($stoim, $rever);
$num_reacs_expand = @$reacs_exp;
print_matrix("expanded stoich:\n", $stoim_exp);

my $stoim_exp_T = transpose($stoim_exp);
print_matrix("transposed expanded stoich:\n", $stoim_exp_T);

open my $fh_o, ">$efm_filename" or die "ERROR: couldn't open file '$efm_filename' for writing: $!\n";
select((select($fh_o), $|=1 )[0]);

do_david_bockmayr();

close $fh_o;
################################################################################


################################################################################
################################################################################
sub do_david_bockmayr
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

   print "INFO: going to use $num_threads parallel threads\n";
   $cplex_env->setintparam(&Math::CPLEX::Base::CPX_PARAM_THREADS, $num_threads);
   $cplex_env->setintparam(&Math::CPLEX::Base::CPX_PARAM_SCRIND, &Math::CPLEX::Base::CPX_ON);

   fill_init_lp_network();

   while(1)
   {
      #############################################################################
      # solve MIP problem
      #############################################################################
      die "ERROR: mipopt() failed\n" unless $lp->mipopt();
      #############################################################################
   
   
      #############################################################################
      # retrieve computed values
      #############################################################################
      if( $lp->getstat() != &Math::CPLEX::Base::CPXMIP_OPTIMAL )
      {
         print "CPLEX didn't find an optimal solution (status=", $lp->getstat(), ") -> algorithm stopped.\n";
         print "return value if optimal solution was obtained: ", &Math::CPLEX::Base::CPXMIP_OPTIMAL, "\n";
         print "number of computed elementary flux modes: $solution_cnt\n";
         print "elementary flux modes were written to '$efm_filename'\n";
         die "ERROR: free() failed\n" unless $lp->free();
         die "ERROR: close() failed\n" unless $cplex_env->close();
         return 0;
      }
   
      my ($sol_status, $obj_val, @vals) = $lp->solution();
      my @vs = @vals[0 .. $num_reacs_expand-1];
      my @as = @vals[$num_reacs_expand .. 2*$num_reacs_expand-1];
   
      print "MIP objective value: ", $obj_val, "\n";
      print "vals: @vals\n";
      print "vs: @vs\n";
      print "as: @as\n";
   
      # write numerical values (tr-values) to file
      my $num_access_idx = 0;
      for( my $i = 0; $i < @$reacs; $i++ )
      {
         my $val = $vals[$num_access_idx];
         if( $rever->[$i] != 0 )
         {
            $num_access_idx++;  
            if( $val == 0 )
            {
               $val = $vals[$num_access_idx] * (-1);
            }
         }
         $val = 0 if abs($val) < CONSIDER_ZERO;
         print $fh_o $val;
         print $fh_o " " if $i != @$reacs - 1;
         $num_access_idx++;  
      }
      print $fh_o "\n";
   
      # fill array that contains all existing solutios
      $sol_norm->[$solution_cnt] = 0;
      for( my $i = 0; $i < $num_reacs_expand; $i++ )
      {
          my $val = $vals[$i + $num_reacs_expand];
          $val = 0 if abs($val) < CONSIDER_ZERO;
          $solutions->[$solution_cnt][$i] = $val;
          $sol_norm->[$solution_cnt]++ if $val != 0;
      }
   
      add_solution();
   
      $solution_cnt++;
   }

   #############################################################################

   #############################################################################
   #############################################################################
   die "ERROR: free() failed\n" unless $lp->free();
   die "ERROR: close() failed\n" unless $cplex_env->close();
   #############################################################################

   return 1;
}
################################################################################


################################################################################
################################################################################
sub add_solution
{
   my $newRows;

   for( my $r = 0; $r < $num_reacs_expand; $r++ )
   {
      if( $solutions->[$solution_cnt][$r] > 0 )
      {
         $newRows->[0][$r+$num_reacs_expand] = 1.0;
      }
   }

   my $row = { num_rows  => 1,
               rhs       => [$sol_norm->[$solution_cnt] - 1],
               sense     => ['L'],
               row_names => ["sol_$solution_cnt"],
               row_coefs => $newRows};
               
   die "ERROR: addrows() failed\n" unless $lp->addrows($row);

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
sub fill_init_lp_network
{
   print "entered fill_init_lp_network()\n";

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
      $col_names->[$col_cnt] = "v_" . $reacs_exp->[$i];
      $col_cnt++;
   }

   # binary values zr
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $obj_coefs->[$col_cnt] = 1.0;
      $lower_bnd->[$col_cnt] = 0.0;
      $upper_bnd->[$col_cnt] = 1.0;
      $col_types->[$col_cnt] = 'B';
      $col_names->[$col_cnt] = "a_" . $reacs_exp->[$i];
      $col_cnt++;
   }

   # numerical values y
   for( my $t = 0; $t < $num_tgts - 1; $t++ )
   {
      for( my $i = 0; $i < @$metas; $i++ )
      {
         $obj_coefs->[$col_cnt] = 0.0;
         $lower_bnd->[$col_cnt] = &Math::CPLEX::Base::CPX_INFBOUND*(-1);
         $upper_bnd->[$col_cnt] = &Math::CPLEX::Base::CPX_INFBOUND;
         $col_types->[$col_cnt] = 'C';
         $col_names->[$col_cnt] = "y_$t" . "_" . $metas->[$i];
         $col_cnt++;
      }
   }

   # numerical value for x values
   for( my $t = 0; $t < $num_tgts - 1; $t++ )
   {
      $obj_coefs->[$col_cnt] = 0.0;
      $lower_bnd->[$col_cnt] = &Math::CPLEX::Base::CPX_INFBOUND*(-1);
      $upper_bnd->[$col_cnt] = &Math::CPLEX::Base::CPX_INFBOUND;
      $col_types->[$col_cnt] = 'C';
      $col_names->[$col_cnt] = "x_$t";
      $col_cnt++;
   }

   my $cols = { num_cols  => $col_cnt,
                obj_coefs => $obj_coefs,
                lower_bnd => $lower_bnd,
                upper_bnd => $upper_bnd,
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
sub add_inital_rows()
{
   my $newRows;
   my $rhs;
   my $sense;
   my $row_names;
   my $row_cnt = 0;

   # tr <= M*zr
   #for( my $i = 0; $i < $num_reacs_expand; $i++ )
   #{
   #   $rhs->[$row_cnt]                    = 0.0;
   #   $sense->[$row_cnt]                  = 'L';
   #   $row_names->[$row_cnt]              = "t_lt_Mz_$i";
   #   $newRows->[$row_cnt][$i]            = 1.0;
   #   $newRows->[$row_cnt][$i+$num_reacs_expand] = M;
   #   $row_cnt++;
   #}

   # zr <= tr
   #for( my $i = 0; $i < $num_reacs_expand; $i++ )
   #{
   #   $rhs->[$row_cnt]                    = 0.0;
   #   $sense->[$row_cnt]                  = 'L';
   #   $row_names->[$row_cnt]              = "z_lt_t_$i";
   #   $newRows->[$row_cnt][$i]            = -1.0;
   #   $newRows->[$row_cnt][$i+$num_reacs_expand] =  1.0;
   #   $row_cnt++;
   #}

   # sum zr >= 1
   $rhs->[$row_cnt]                    = 1.0;
   $sense->[$row_cnt]                  = 'G';
   $row_names->[$row_cnt]              = "avoid_trivial";
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      $newRows->[$row_cnt][$i+$num_reacs_expand] =  1.0;
   }
   $row_cnt++;

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

   print "num_tgts: $num_tgts\n";
   for( my $t = 0; $t < $num_tgts; $t++ )
   {
      # v_rx >= 1
      $rhs->[$row_cnt]                        = 1.0;
      $sense->[$row_cnt]                      = 'G';
      $row_names->[$row_cnt]                  = "vr_$target_idx->[$t]";
      $newRows->[$row_cnt][$target_idx->[$t]] = 1.0;
      $row_cnt++;
   }

   for( my $t = 0; $t < $num_tgts - 1; $t++ )
   {
      # S^T*y + u_r1*x - M*(a - 1 - u_r2) >= 0
      for( my $r = 0; $r < @$reacs_exp; $r++ )
      {
         # if( $r == $second_target_idx )
         if( $r == $target_idx->[$t+1] )
         {
            $rhs->[$row_cnt]                        = M1*(-2);
         }
         else
         {
            $rhs->[$row_cnt]                        = M1*(-1);
         }

         $sense->[$row_cnt]                      = 'G';
         $row_names->[$row_cnt]                  = "ST_Dirc_" . $target_name->[$t] . "_" . $target_name->[$t+1];
         for( my $m = 0; $m < @$metas; $m++ )
         {
            $newRows->[$row_cnt][2*$num_reacs_expand + $t*scalar(@$metas) + $m] = $stoim_exp_T->[$r][$m];
         }

         $newRows->[$row_cnt][$num_reacs_expand + $r] = M1*(-1);

         if( $r == $target_idx->[$t] )
         {
            $newRows->[$row_cnt][2*$num_reacs_expand + @$metas*($num_tgts-1) + $t] = 1.0;
         }

         $row_cnt++;
      }

      # x >= 1
      $rhs->[$row_cnt]                                    = 1.0;
      $sense->[$row_cnt]                                  = 'G';
      $row_names->[$row_cnt]                              = "x_" . $target_name->[$t] . "_" . $target_name->[$t+1];
      $newRows->[$row_cnt][2*$num_reacs_expand + @$metas*($num_tgts-1) + $t] = -1.0;
      $row_cnt++;
   }

   
   my $rows = {num_rows  => $row_cnt,
               rhs       => $rhs,
               sense     => $sense,
               row_names => $row_names,
               row_coefs => $newRows};

   die "ERROR: addrows() failed\n" unless $lp->addrows($rows);

   # add indicator constraints
   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      my $val;
      $val->[$i] = 1.0;
      my $indconstr = {
                         indvar       => $num_reacs_expand + $i,
                         complemented => 1,
                         rhs          => 0.0,
                         sense        => 'L',
                         val          => $val,
                         name         => "indicatorA$i",
                      };

      die "ERROR: addindconstr() failed\n" unless $lp->addindconstr($indconstr);
   }

   for( my $i = 0; $i < $num_reacs_expand; $i++ )
   {
      my $val;
      $val->[$i] = 1.0;
      my $indconstr = {
                         indvar       => $num_reacs_expand + $i,
                         complemented => 0,
                         rhs          => 1.0,
                         sense        => 'G',
                         val          => $val,
                         name         => "indicatorB$i",
                      };

      die "ERROR: addindconstr() failed\n" unless $lp->addindconstr($indconstr);
   }

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
################################################################################
sub read_reversibility
{
   my $file = shift;
   my $rvs;
   my $num_rev_reacs = 0;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   $_ = <$fh>;
   @$rvs = split;
   close $fh;

   for( my $i = 0; $i < @$rvs; $i++ )
   {
      if( $rvs->[$i] != 0 )
      {
         $num_rev_reacs++;
      }
   }
   # die "ERROR: number of reversible reactions must be 0, but is $num_rev_reacs\n" if $num_rev_reacs > 0;

   return $rvs;
}
################################################################################


################################################################################
################################################################################
sub read_targets
{
   my $rv   = shift;
   my $file = shift;
   my $tgts;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   $_ = <$fh>;
   @$tgts = split;
   close $fh;

   my $expand_cnt = 0;
   for( my $i = 0; $i < @$tgts; $i++ )
   {
      die "ERROR: i=$i: target reaction $reacs->[$i] is reversible -> not supported yet\n" if( $tgts->[$i] != 0 && $rv->[$i] != 0 );

      $expand_cnt++ if $rv->[$i] != 0;

      if( $tgts->[$i] != 0 )
      {
         $target_idx->[$num_tgts]  = $i + $expand_cnt;
         $target_name->[$num_tgts] = $reacs->[$i];
         $num_tgts++;
         print "we found target reactions #$num_tgts at index $i: $reacs->[$i]\n";
      }
   }

   return $tgts;
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
   getopts('s:m:r:v:t:o:hlp:k:');

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

   if( $opt_t )
   {
      $tfile = $opt_t;
   }
   else
   {
      usage('ERROR: name of input file containing target reactions not provided ',-1);
   }

   if( $opt_l )
   {
      $write_lp_file = 1;
   }

   if( $opt_p )
   {
      $num_threads = $opt_p;
   }

   $max_efms = -1;
   if( $opt_k )
   {
      $max_efms = $opt_k;
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
sub transpose
{
   my $mat = shift;
   my $trp;

   for( my $j = 0; $j < scalar( @$mat ); $j++ )
   {
      for( my $k = 0; $k < scalar( @{$mat->[$j]}); $k++ )
      {
         $trp->[$k][$j] = $mat->[$j][$k];
      }
   }

   return $trp;
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

   print "david_bockmayr_k-shortest.pl -s sfile -m file -r rfile -v rvfile -t tffile -o modes_filename [-h -l -p num_threads -k max_efms]\n";
   print "\n";
   print "-s ..... name of file containing stoichiometric matrix (input)\n";
   print "-m ..... name of file containing metabolites (input)\n";
   print "-r ..... name of file containing reactions (input)\n";
   print "-v ..... name of file containing reversibility information (input)\n";
   print "-t ..... name of file containing target reactions (input)\n";
   print "-o ..... name of ouput mode file\n";
   print "-l ..... write lp file for each step\n";
   print "-k ..... maximum number of modes that are computed\n";
   print "-p ..... number of parallel threads used by CPLEX to solve linear problem\n";
   print "-h ..... print this message\n";
   print "\n";
   print "david_bockmayr_k-shortest.pl computes elementary flux modes of a given metabolic system\n";

   exit($exit_code);
}
################################################################################
