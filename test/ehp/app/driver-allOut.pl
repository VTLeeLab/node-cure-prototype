#!/usr/bin/env perl

use strict;
use warnings;

use threads;
use Time::HiRes qw(usleep nanosleep gettimeofday tv_interval);

if (not @ARGV) {
  die "Usage: $0 PORT\n";
}

my $PORT = $ARGV[0];

print "Starting legitimate client on port $PORT\n";
my $t1 = threads->create(\&runLegitimateClient, ($PORT, 5000, 8));

print "Starting malicious REDOS client on port $PORT\n";
my $t2 = threads->create(\&runREDOSClient, ($PORT));
print "Starting malicious readDOS client on port $PORT\n";
my $t3 = threads->create(\&runReadDOSClient, ($PORT));

$t1->join();
$t2->join();
$t3->join();

print "Done\n";
exit 0;

sub runLegitimateClient {
  my ($PORT, $nSeconds) = @_;

  my $nIter = 2*$nSeconds;

  print "Legitimate clients\n";
  system("ab -n 99999999 -t 10 -c 80 'http://localhost:$PORT/\?fileToRead=/tmp/staticFile.txt' > /dev/null 2>&1");

  return;
}

sub runREDOSClient {
  my ($PORT) = @_;

  sleep 2;
  
  for (my $i = 0; $i < 10; $i++) {
    print time . ": REDOS: Malicious request $i\n";
    my $url = "http://localhost:$PORT/?fileToRead=/dev/random";
    system("wget '$url' > /dev/null 2>&1 &");
  }
}

sub runReadDOSClient {
  my ($PORT) = @_;

  sleep 2;
  
  for (my $i = 0; $i < 10; $i++) {
    print time . ": ReadDOS: Malicious request $i\n";
    my $url = "http://localhost:$PORT/?fileToRead=/dev/random";
    system("wget '$url' > /dev/null 2>&1 &");
  }
}

