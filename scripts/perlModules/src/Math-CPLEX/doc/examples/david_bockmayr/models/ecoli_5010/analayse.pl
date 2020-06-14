#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Thu Jan 30 11:37:08 CET 2014
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

my $cnt = 0;

while(<>)
{
   my @flux = split;

   if( $flux[1] > 0 && $flux[2] > 0.0 && $flux[9] > 0 )
   {
      # print "$flux[1] $flux[1] $flux[9]\n";
      print "@flux\n";
   }

   $cnt++ if $flux[1] > 0 && $flux[2] > 0.0 && $flux[9] > 0;
}

print "found $cnt valid emfs\n";
