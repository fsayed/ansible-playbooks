#!/usr/bin/perl

# OUT OF MEMORY CHECK
#
# Written by Keith

# use some stuff
use strict; 
#use Net::SSH::Perl; 
# config/define

my $user        = "dravenst";   # username to login with
my $host        = $ARGV[0];     # hostname to check 
my $grep        = $ARGV[1];     # directory/path to epp_server.log 
my $warning     = $ARGV[2];     # warning percentage
my $critical    = $ARGV[3];     # critical percentage
my $error	= "OutOfMemoryError";
my $errors;
my $out;
my $err;
my $exit;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year		= $year+1900;
$mon		= $mon+1;

if($mday =~ m/^[1-9]$/)
{ $mday = "0"."$mday"; }
if($mon =~ m/^[1-9]$/)
{ $mon = "0"."$mon"; }

my $date = ("$year-$mon-$mday");

if (!$ARGV[0] || !$ARGV[1] || !$ARGV[2] || !$ARGV[3])
  {
        print "CRITICAL: Missing or not enough ARGVs\n";
        print "usage: $0 <host> <directory> <warning> <critical>\n";
        exit 2;
  }

if ($host =~ "localhost")
  {
	open (PIPE, "grep $date $grep|grep -ic $error |");
	while(<PIPE>)
	  { $out = $_ }
	close(PIPE);
  }
else
  {
	# ssh connection
	my $ssh = Net::SSH::Perl->new("$host", options => [ "protocol 1" ]);
	$ssh->login("$user");
	($out,$err,$exit)=$ssh->cmd("grep $date $grep|grep -ic $error ");
  }

## If the greps have a value, use the ARGV 2 and 3 to exit appropriately 
if ($err =~ m/grep/g)
  {
        print "WARNING: The grep didn't grep the grep and you should probably check the grep. grep? $err\n";
        exit 1;
  }
elsif ($out < $warning)
  {
        print "OK: $error is currently at $out \n";
        exit 0;
  }

elsif ($out > ($warning - 1) && $out < $critical)
  {
        print "WARNING: $error is currently at $out \n";
        exit 1;
  }

elsif ($out > ($critical - 1))
  {
        print "CRITICAL: $error is currently at $out \n";
        exit 2;
  }
else
  {
        print "WARNING: The grep didn't grep the grep and you should probably check the grep. grep?";
        exit 1;
  }
__END__

=head1 NAME

OUT_OF_MEMORY_CHECK

=head1 VERSION

0.1

=head1 SYNOPSIS

This script is used to localy or remotely check a log/file for out of memory errors.
The script checks the date and only checks for the current day.  Some logs do not rotate for a couple of days and this would leave the alert in nagios for too long.

=head1 USAGE

USAGE: out_of_memory_check.pl <host> <full path including epp_server.log name> <warning> <critical>

out_of_memory_check.pl = script name

host = localhost (causes the script to look locally) anything else and the script will ssh to that

full path including epp_server.log name = the full path where the epp_server.log is.

warning = the number of errors to exit warning at

critical = the number of errors to exit critical at

I was unable to get the script to automatically not use the ssh module if not present.  So, using this script locally on a machine where the ssh module does not exist just comment that line out. 

Example:
out_of_memory_check.pl localhost /opt/log/dotinfo/epp_server/epp_server.log 1 5 


=cut
