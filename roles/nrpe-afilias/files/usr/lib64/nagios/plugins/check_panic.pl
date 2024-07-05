#!/usr/bin/perl

$LOG = $ARGV[0];
open(LOG) or die("Could not open log file");
$count = 0;
foreach $line (<LOG>) {
	$count += 1;
}
if ($count < 1) { print "OK: Log empty.\n"; exit(0); }
else { print "Errors found in $LOG: " . `head -n 1 $LOG`; exit(2); }
