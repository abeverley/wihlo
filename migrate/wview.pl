#!/usr/bin/perl

use strict;
use warnings;
use Find::Lib '../lib' => 'Wihlo';
use DateTime;
use Dancer2 ':script';
use Dancer2::Plugin::DBIC qw(schema resultset rset);

use DBI;
my $dbh = DBI->connect("dbi:SQLite:dbname=/var/lib/wview/archive/wview-archive.sdb"
                      ,"","", { RaiseError => 1 },
                      ) or die $DBI::errstr;

my $sth = $dbh->prepare("SELECT * FROM archive");
$sth->execute();

my $readings = $dbh->selectall_arrayref('SELECT * FROM archive', { Slice => {} });
my @toadd;
foreach my $r (@$readings)
{
    my $new = {
        usunits      => $r->{usUnits},
        datetime     => DateTime->from_epoch(epoch=>$r->{dateTime}),
        intvl        => $r->{interval},
        barometer    => $r->{barometer},
        intemp       => $r->{inTemp},
        outtemp      => $r->{outTemp},
#        outtemphi    => $r->{inTemp},
#        outtemplo    => $r->{inTemp},
        inhumidity   => $r->{inHumidity},
        outhumidity  => $r->{outHumidity},
        windspeed    => $r->{windSpeed},
        winddir      => $r->{windDir},
        windgust     => $r->{windGust},
        windgustdir  => $r->{windGustDir},
        rainrate     => $r->{rainRate},
        rain         => $r->{rain},
        et           => $r->{ET},
        radiation    => $r->{radiation},
#        radiationmax => $r->{},
        uv           => $r->{UV},
#        uvmax        => $r->{},
        extratemp1   => $r->{extraTemp1},
        extratemp2   => $r->{extraTemp2},
        extratemp3   => $r->{extraTemp3},
        soiltemp1    => $r->{soilTemp1},
        soiltemp2    => $r->{soilTemp2},
        soiltemp3    => $r->{soilTemp3},
        soiltemp4    => $r->{soilTemp4},
        leaftemp1    => $r->{leafTemp1},
        leaftemp2    => $r->{leafTemp2},
        extrahumid1  => $r->{extraHumid1},
        extrahumid2  => $r->{extraHumid2},
        soilmoist1   => $r->{soilMoist1},
        soilmoist2   => $r->{soilMoist2},
        soilmoist3   => $r->{soilMoist3},
        soilmoist4   => $r->{soilMoist4},
        leafwet1     => $r->{leafWet1},
        leafwet2     => $r->{leafWet2},
    };
    push @toadd, $new;
}

my $reading_rs = rset('Reading');
$reading_rs->populate(\@toadd);

