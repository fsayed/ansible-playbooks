#!/usr/bin/perl -w

# check_file_mtime.pl - NOC JP - Nov 2007
# Time::Duration would be better than the in-house "formatAgoTime", but this way we are not dependant on any modules.

use Getopt::Std;
our ($opt_f, $opt_c, $opt_w) = '';
getopt('fcw');
if (not $opt_f or not $opt_c or not $opt_w) {
	print "Usage: check_file_mtime.pl -f [file] -w [warning in seconds] -c [critical in seconds]\n";
	exit(3);
}

if (not -r $opt_f) {
	print "Could not read file!\n";
	exit(3);
}

$mtime_ago = time() - (stat($opt_f))[9];
if ($mtime_ago < 0) {
	print "File does not exist or was modified in the future!\n";
	exit(3);
}
elsif ($mtime_ago >= $opt_c) {
	print "File last modified " . formatAgoTime($mtime_ago) . " seconds ago.\n";
	exit(2);
}
elsif ($mtime_ago >= $opt_w) {
	print "File last modified " . formatAgoTime($mtime_ago) . " seconds ago.\n";
	exit(1);
}
else {
	print "File last modified " . formatAgoTime($mtime_ago) . " seconds ago.\n";
	exit(0);
}

sub formatAgoTime {
	my ($days, $hours, $mins, $secs);
	my $modsecs = $_[0]; # mod time in epoch secs.
	$days = $modsecs / 86400; # secs/day
	$modsecs %= 86400; # days remainder
	$hours = $modsecs / 3600; # secs/hour
	$modsecs %= 3600; # hours remainder
	$mins = $modsecs / 60; # secs/min
	$secs = $modsecs % 60; # remaining secs
	return sprintf("%02dd %02u:%02u:%02u ago", $days, $hours, $mins, $secs);
}
