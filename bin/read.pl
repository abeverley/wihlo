#!/usr/bin/env perl

=pod
Wihlo - Web-based weather logging and display software
Copyright (C) 2014 A Beverley

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
=cut

use FindBin;
use lib "$FindBin::Bin/../lib";

use Dancer2 ':script';
use Dancer2::Plugin::DBIC qw(schema resultset rset);
use Wihlo;
use Device::VantagePro;
use DateTime;
use DateTime::Format::DBI;
use HTTP::Request::Common qw(GET);
use LWP::UserAgent;
use URI;
use Ouch;
use Try::Tiny;

sub rainin($);

my $config = config;

my %arg_hsh;  
$arg_hsh{baudrate} = $config->{stations}->{vp}->{baudrate};
$arg_hsh{port} = $config->{stations}->{vp}->{device};

my $vp = new Device::VantagePro(\%arg_hsh);
error "Failed to wake up device" && exit unless $vp->wake_up() == 1;

my $timezone            = $vp->get_timezone;
my $arc_period          = $vp->get_archive_period;
my $setup_bits          = $vp->get_setup_bits;
my $rain_collector_size = $setup_bits->{RainCollectorSize};
my $raindiv             = $rain_collector_size == 2 ? 10
                        : $rain_collector_size == 1 ? 5
                        : 100;

my $data;
if (my $dt = rset('Station')->find(1)->lastdata) # The last item of data retrieved
{
    my ($dstamp, $tstamp) = split /,/, $dt;
    $data = $vp->do_dmpaft($dstamp,$tstamp);
} else
{
    # Otherwise get everything
    $data = $vp->do_dmpaft; 
}

unless ( @{$data} ) { debug "No records retrieved" };

my $dtf = schema->storage->datetime_parser; # XXXX Is this expensive? Move inside loop?
my $changing = 0; my $lastdata;
foreach my $d ( @{$data} ) 
{
    my $dt;
    # Make up for retarded weather station that produces
    # invalid times
    try {
        # Don't use unixtime parameter, as it depends on
        # timezone of PC, not datalogger
        $dt = DateTime->new(
            year       => $d->{year},
            month      => $d->{month},
            day        => $d->{day},
            hour       => $d->{hour},
            minute     => $d->{min},
            time_zone  => $timezone,
        );
    } catch {
        # Possible invalid time, because logger forwards
        # its clocks one hour too late (for GMT/BST at least).
        # Attempt again, with time one hour forward.
        $dt = DateTime->new(
            year       => $d->{year},
            month      => $d->{month},
            day        => $d->{day},
            hour       => $d->{hour} + 1,
            minute     => $d->{min},
            time_zone  => $timezone,
        );
    };

    # Monitor for a DST "ambiguous" time, when the clocks change.
    # For an hour when the clocks go back, the winter time minus
    # an hour equals the DST. See DateTime manual.
    if ($dt->clone->subtract( hours => 1 )->hms eq $dt->hms)
    {
        # Uh-oh, clocks are about to go back or have just gone back
        $changing = 1;

        # If the time stamp of the current reading is greater than
        # the maximum received so far, then we're probably still in DST.
        # DateTime defaults to local standard time, so take an hour
        # off it to adjust to DST.
        my $maxdst = rset('Station')->find(1)->maxdst || 0;
        if ( $maxdst < $d->{time_stamp} )
        {
            $dt->subtract( hours => 1);
            # Update status 
            rset('Station')->find(1)->update({ maxdst => $d->{time_stamp} });
        }

    } elsif ($changing == 1)
    {
        # We've just finished a clock change. Reset status for next time.
        rset('Station')->find(1)->update({ maxdst => undef });
    }

    # Store time as UTC in database
    $dt->set_time_zone( 'UTC' );


    my $row = 
    {
        # Return undef in event of dashed value
        usunits      => 1,
        usunitsrain  => $rain_collector_size == 0             ? 1 : 0,
        intvl        => $arc_period,
        et           => $d->{ET} == 0                         ? undef : $d->{ET},
        rainrate     => $d->{Rain_Rate_Clicks} / $raindiv,
        rain         => $d->{Rain_Clicks} / $raindiv,
        intemp       => $d->{Air_Temp_Inside} == 32767        ? undef : $d->{Air_Temp_Inside},
        outtemplo    => $d->{Air_Temp_Lo}     == 32767        ? undef : $d->{Air_Temp_Lo},
        outhumidity  => $d->{Relative_Humidity} == 255        ? undef : $d->{Relative_Humidity},
        outtemp      => $d->{Air_Temp} == 32767               ? undef : $d->{Air_Temp},
        radiationmax => $d->{Solar_Max} == 0                  ? undef : $d->{Solar_Max},
        inhumidity   => $d->{Relative_Humidity_Inside} == 255 ? undef : $d->{Relative_Humidity_Inside},
        windspeed    => $d->{Wind_Speed} == 255               ? undef : $d->{Wind_Speed},
        barometer    => $d->{Barometric_Press} == 0           ? undef : $d->{Barometric_Press},
        outtemphi    => $d->{Air_Temp_Hi} == -32768           ? undef : $d->{Air_Temp_Hi},
        uv           => $d->{UV} == 255                       ? undef : $d->{UV},
        uvmax        => $d->{UV_Max} == 0                     ? undef : $d->{UV_Max},
        datetime     => $dt,
        windgust     => $d->{Wind_Gust_Max} == 0              ? undef : $d->{Wind_Gust_Max},
        windgustdir  => $d->{Wind_Dir_Max} == 255             ? undef : $d->{Wind_Dir_Max} * 22.5,
        radiation    => $d->{Solar} == 32767                  ? undef : $d->{Solar},
        winddir      => $d->{Wind_Dir} == 255                 ? undef : $d->{Wind_Dir} * 22.5
    };
    if (rset('Reading')->search({ datetime => $dtf->format_datetime($row->{datetime}) })->count)
    {
        warning "Reading already exists for DTG $row->{datetime}. Not inserting.";
    } else
    {
        my $dbrecord = rset('Reading')->create($row);
        debug "Inserted record ID ".$dbrecord->id;
    }

    $lastdata = "$d->{date_stamp},$d->{time_stamp}"; # if $d->{unixtime} > $lastunix;
} 

# Last item of data revieved, so we can start where we left off
rset('Station')->find(1)->update({ lastdata => $lastdata })
    if ( @{$data} );

my $ua = LWP::UserAgent->new;
# Add to Wunderground
if ($config->{upload}->{wunderground})
{
    my @toupload = rset('Reading')->search({ uploaded_wg => 0 })->all;
    for my $u (@toupload)
    {
        my $dt = $u->datetime; # UTC in DB, in object as floating

        my $data = {
            dateutc      => $dt->ymd('-') . ' ' . $u->datetime->hms(':'),
            winddir      => $u->winddir,
            windspeedmph => $u->windspeed,
            windgustdir  => $u->windgustdir,
            windgustmph  => $u->windgust,
            humidity     => $u->outhumidity,
            tempf        => $u->outtemp,
            baromin      => $u->barometer,
            rainin       => rainin($u->datetime),
        };


        if (upload_wg($data))
        {
            $u->update({ uploaded_wg => 1 });
            debug "Uploaded record $dt successfully to Wunderground";
        }
    }
}

# Add to WOW
if ($config->{upload}->{wow})
{
    my @toupload = rset('Reading')->search({ uploaded_wow => 0 })->all;
    for my $u (@toupload)
    {
        my $dt = $u->datetime; # In UTC in DB. Retrieved as floating

        my $data = {
            dateutc      => $dt->ymd('-') . ' ' . $u->datetime->hms(':'),
            winddir      => int $u->winddir,
            windspeedmph => $u->windspeed,
            windgustdir  => int $u->windgustdir,
            windgustmph  => $u->windgust,
            humidity     => $u->outhumidity,
            tempf        => $u->outtemp,
            baromin      => $u->barometer,
            rainin       => rainin($u->datetime),
        };
        say STDERR $data->{dateutc};

        if (upload_wow($data))
        {
            $u->update({ uploaded_wow => 1 });
            debug "Uploaded record $dt successfully to WOW";
        }
    }
}

sub upload_wow
{
    my $record = shift;

    # Pick out only the required fields
    my @fields = qw(dateutc winddir windspeedmph windgustdir windgustmph humidity tempf baromin);
    my %newdata;
    @newdata{@fields} = undef;
    @newdata{ keys %newdata } = @$record{ keys %newdata };

    $newdata{action}                = "updateraw";
    $newdata{softwaretype}          = "Wihlo";
    $newdata{siteid}                = $config->{upload}->{wow}->{id};
    $newdata{siteAuthenticationKey} = $config->{upload}->{wow}->{password};

    my $uri = $config->{upload}->{wow}->{url};

    eval { putdata($uri, \%newdata) };
    if (hug)
    {
        debug "Failed to upload to WOW: ".bleep;
        return;
    }
    return 1;
}

sub upload_wg
{
    my $record = shift;

    # Pick out only the required fields
    my @fields = qw(dateutc winddir windspeedmph windgustdir windgustmph humidity tempf baromin);
    my %newdata;
    @newdata{@fields} = undef;
    @newdata{ keys %newdata } = @$record{ keys %newdata };

    $newdata{action}   = "updateraw";
    $newdata{ID}       = $config->{upload}->{wunderground}->{id};
    $newdata{PASSWORD} = $config->{upload}->{wunderground}->{password};

    my $uri = $config->{upload}->{wunderground}->{url};

    my $content;
    eval { $content = putdata($uri, \%newdata) };
    if (hug)
    {
        debug "Failed to upload to Wunderground: ".bleep;
        return;
    }
    elsif ($content ne "success")
    {
        debug "Failed to upload to Wunderground. Returned: $content";
        return;
    }
    return 1;
}

sub putdata($$)
{
    my ($uri, $data) = @_;

    my $urio = URI->new($uri);
    $urio->query_form($data);

    my $content;
    if (my $response = $ua->get($urio))
    {
        my $code = $response->code;
        $content = $response->decoded_content;
        $content =~ s/\s+$//;
        unless ($code == 200)
        {
            ouch 'failupload', "Failed to upload. Return code: $code, Response: $content";
        }
    }
    else {
        ouch 'failput', "Failed to upload: ".$response->status_line;
    }
    return $content;
}

sub rainin($)
{
    my $end = shift;
    my $start = $end->clone->subtract( hours => 1 );

    my $rain = rset('Reading')->search(
        {
            datetime => {
                -between => [
                    $dtf->format_datetime($start),
                    $dtf->format_datetime($end),
                ],
            }
        },
    )->get_column('rain')->sum;

    $rain / 25.4;
}

