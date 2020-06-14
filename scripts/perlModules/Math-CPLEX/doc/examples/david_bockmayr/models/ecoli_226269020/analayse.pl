#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Thu Jan 30 11:37:08 CET 2014
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;
use constant CONSIDER_ZERO => 1e-08;

my $cnt = 0;

while(<>)
{
   my @flux = split;

   if( abs($flux[ 7]) > CONSIDER_ZERO && abs($flux[15]) > CONSIDER_ZERO && abs($flux[41]) > CONSIDER_ZERO &&
       abs($flux[44]) > CONSIDER_ZERO && abs($flux[67]) > CONSIDER_ZERO && abs($flux[79]) > CONSIDER_ZERO )
   {
      # print "$flux[1] $flux[1] $flux[9]\n";
      print "@flux\n";
   }

   $cnt++ if( abs($flux[ 7]) > CONSIDER_ZERO && abs($flux[15]) > CONSIDER_ZERO && abs($flux[41]) > CONSIDER_ZERO &&
              abs($flux[44]) > CONSIDER_ZERO && abs($flux[67]) > CONSIDER_ZERO && abs($flux[79]) > CONSIDER_ZERO );

   warn "processed $. EFMs, cnt=$cnt\n" unless $.%10000;
}

print "found $cnt valid emfs\n";
