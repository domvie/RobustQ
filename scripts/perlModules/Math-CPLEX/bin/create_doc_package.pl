#! /usr/bin/perl
################################################################################
################################################################################
# Author:  Christian Jungreuthmayer
# Date:    Thu Jun  5 11:25:12 CEST 2014
# Company: Austrian Centre of Industrial Biotechnology (ACIB)
################################################################################

use strict;
use warnings;
use File::Path qw(remove_tree);
use File::Copy qw(move);
use Cwd;

my $src_dir         = '../src/trunk/Math-CPLEX';
my $inp_dir         = '../doc';
my $built_dir       = $src_dir . '/' . '../../../built_packages';
my $pm_version_file = $src_dir . '/' . 'lib/Math/CPLEX/Base.pm';
my $tmp_dir = '/tmp';

my $version = get_current_version($pm_version_file);
print "current version of module: $version\n";

my $package_name = 'doc_Math-CPLEX' . '-' . $version;
my $dst_dir = $tmp_dir . '/' . $package_name;
my $filename_tmp_tar_bald = $dst_dir . '.tar.gz';

prepare_build_directory($tmp_dir, $package_name);
copy_src_to_tmp_dir($inp_dir, $dst_dir);
# remove_subversion_files($dst_dir); # not required anymore with new SVN file format
create_tar_ball($dst_dir, $filename_tmp_tar_bald);
copy_tar_ball_to_built_dir($filename_tmp_tar_bald, $built_dir, $package_name . '.tar.gz');
################################################################################


################################################################################
################################################################################
sub copy_tar_ball_to_built_dir
{
   my $s_file   = shift;
   my $d_dir    = shift;
   my $pck_name = shift;

   my $d_file = $d_dir . '/' . $pck_name;

   warn "INFO: going to copy tar ball '$s_file' to '$d_dir'\n";
   # warn "DEBUG: name of target file '$d_file'\n";

   die "ERROR: cannot copy file '$s_file' to '$d_dir', file '$d_file' already exists\n" if -e $d_file;

   system 'cp', $s_file, $d_dir;
}
################################################################################


################################################################################
################################################################################
sub create_tar_ball
{
   my $dir = shift;
   my $filename = shift;

   if( $dir =~ /(.+)\/(.+)/ )
   {
      my $cwd = getcwd();

      my $base_dir = $1;
      my $top_dir  = $2;
      warn "base_dir: $base_dir\n";
      warn "top_dir:  $top_dir\n";

      chdir  $base_dir;
      warn "DEBUG: current working directory '$base_dir'\n";
      warn "INFO: going to create tar ball '$filename' of directory $top_dir\n";
      # system("tar -cvzf $filename $dir");
      system("tar -czf $filename $top_dir");
      chdir $cwd;
   }
   else
   {
      die "ERROR: couldn't extract directories from '$dir'\n";
   }

}
################################################################################


################################################################################
################################################################################
sub remove_subversion_files
{
   my $dir = shift;

   warn "DEBUG: removing subversion directories from $dst_dir\n";
   system("find $dst_dir -name .svn | xargs rm -r");
}
################################################################################


################################################################################
################################################################################
sub copy_src_to_tmp_dir
{
   my $s_dir = shift;
   my $d_dir = shift;

   warn "INFO: going to copy $s_dir to $d_dir\n";

   die "ERROR: destination directory '$d_dir' exists\n" if -e $d_dir;

   system('cp', '-r', $s_dir, $d_dir);

   die "ERROR: destination directory '$d_dir' not created\n" unless -d $d_dir;
}
################################################################################


################################################################################
################################################################################
sub prepare_build_directory
{
   my $dir = shift;
   my $pck = shift;

   my $full_name =  $dir . '/' . $pck;

   if( -e $full_name )
   {
      if( -d $full_name )
      {
         print "INFO: Found a directory '$full_name' -> going to remove it\n";
         remove_tree $full_name;
         die "ERROR: Failed to remove directory '$full_name'\n" if -d $full_name;
      }
      elsif( -f $full_name )
      {
         print "INFO: Found a file '$full_name' -> going to remove it\n";
         die "ERROR: failed to delete file '$full_name'\n" if unlink($full_name) != 1;
         
      }
      else
      {
         die "ERROR: there exists a directory '$full_name' of invalid type -> removed an start script again\n";
      }
   }
   else
   {
      warn "DEBUG: target directory does not exist\n";
   }
}
################################################################################


################################################################################
################################################################################
sub get_current_version
{
   my $file = shift;
   my $version;

   open my $fh, $file or die "ERROR: couldn't open file '$file' for reading: $!\n";
   my @lines = <$fh>;
   close $fh;

   my $num_found = 0;
   for( my $i = 0; $i < @lines; $i++ )
   {
      if( $lines[$i] =~ /^our \$VERSION = '(\d+\.\d+)';/ )
      {
         $version = $1;
         # we found the line we want to change
         warn "INFO: found version $version in file '$file'\n";
         $num_found++;
      }
   }

   if( $num_found == 1 )
   {
      return $version;
   }
   elsif( $num_found == 0 )
   {
      die "ERROR: we couldn't find version line in file '$file'\n";
   }
   else
   {
      die "ERROR: version line was found more than once ($num_found)\n";
   }
}
################################################################################
