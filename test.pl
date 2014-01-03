#!/usr/bin/perl

use strict;
use warnings;

use DateTime;

my $dt = DateTime->new(
      year       => 2013,
      month      => 10,
      day        => 27,
      hour       => 00,
      minute     => 15,
      time_zone  => 'Europe/London',
  );

if ($dt->clone->subtract( hours => 1 )->hms eq $dt->hms)
{
    print "clocks changing\n";
}
# exit;

print "First time is ".$dt->hms."\n";
print "BST\n" if $dt->is_dst;
print $dt->epoch."\n";
my $dt2 = $dt->clone->subtract( hours => 1 );
# my $dt1 = $dt2->clone->subtract( hours => 1 );
print "Second time is ".$dt2->hms."\n";
print "BST\n" if $dt2->is_dst;
print $dt2->epoch."\n";

