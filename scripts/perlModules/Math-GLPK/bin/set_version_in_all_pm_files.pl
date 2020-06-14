#! /usr/bin/perl
################################################################################r
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Thu Jun  5 10:45:50 CEST 2014
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

use File::Copy qw(copy move);

my $version = shift || die "ERROR: provided version, such as '0.01'\n";

die "ERROR: invalid version '$version'\n" if $version =~ /[^0123456789.]/;

foreach my $file (<../src/trunk/Math-GLPK/lib/Math/GLPK/*>)
{
   print "INFO: updating version for file '$file'\n";

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   my @lines = <$fh>;
   close $fh;

   my $num_found = 0;
   for( my $i = 0; $i < @lines; $i++ )
   {
      if( $lines[$i] =~ /^our \$VERSION = '(\d+\.\d+)';/ )
      {
         # we found the line we want to change
         warn "INFO: found version $1 in file '$file', changing to $version\n";
         $lines[$i] = "our \$VERSION = '$version';\n";
         $num_found++;
      }
   }

   if( $num_found == 1 )
   {
      # print new version to file;
      open my $fh, ">$file" or die "ERROR: couldn't open file '$file' for writing: $!\n";
      print $fh @lines;
      close $fh;
   }
   elsif( $num_found == 0 )
   {
      die "ERROR: we couldn't find version line in file '$file' -> couldn't change version of module!\n";
   }
   else
   {
      die "ERROR: version line was found more than once ($num_found)\n";
   }
}
