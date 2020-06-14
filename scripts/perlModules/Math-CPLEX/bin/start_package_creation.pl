#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Thu Jun  5 13:45:31 CEST 2014
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;

my $new_version = shift or die "ERROR: provide new version number of module\n";

system("./set_version_in_all_pm_files.pl", $new_version);
system("./create_cpan_html");
system("./create_tar_ball.pl");
system("./create_doc_package.pl");
