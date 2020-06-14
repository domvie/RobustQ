#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Thu Jan 30 11:37:08 CET 2014
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;
use constant CONSIDER_ZERO => 1e-8;


while(<>)
{
   s/^\s*//;
   s/\s*$//;
   my @flux = split;

   my $cnt = 0;
   foreach my $flu (@flux)
   {
      $cnt++ if abs($flu) > CONSIDER_ZERO;
   }
   print "@flux cardinality: $cnt\n";
}
