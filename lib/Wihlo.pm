=pod
Wihlo - Web-based weather logging and display software
Copyright (C) 2014 A Beverley andy@andybev.com

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

package Wihlo;
use Dancer2;
use Dancer2::Plugin::DBIC qw(schema resultset rset);
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::DBI;
use JSON;

our $VERSION = '0.1';

any '/' => sub {

    if (param 'update')
    {
        my $strp = DateTime::Format::Strptime->new( pattern   => '%F' );
        session 'range' => {
            to   => param('to') ? $strp->parse_datetime(param 'to') : undef,
            from => param('from') ? $strp->parse_datetime(param 'from') : undef,
        };
    }

    template 'index' => {
        range => session('range'),
    };
};

get '/data' => sub {

    my $range = session('range') || {};
    my $to    = $range->{to}   || DateTime->now;
    my $from  = $range->{from} || $to->clone->subtract(days => 5);

    my $reading_rs = rset('Reading');
    schema->storage->debug(1);

    # Format DateTime objects for the database query
    my $db_parser = DateTime::Format::DBI->new(schema->storage->dbh);
    my $from_db = $db_parser->format_date($from);
    my $to_db   = $db_parser->format_date($to->add( days => 1));

    # Calculate how many readings to extract from DB and group accordingly
    my $group = "";
    my $diff = $from->subtract_datetime( $to );
    if ($diff->months || $diff->years)
    {
        $group = "DATE_FORMAT(datetime, '%Y%j')";
    }
    elsif ($diff->weeks)
    {
        $group = "DATE_FORMAT(datetime, '%Y%j%H')";
    }
    else
    {
        $group = "DATE_FORMAT(datetime, '%Y%j%H%i')";
    }

    my $readdisp = $reading_rs->search(
        {
            datetime => {
                -between => [
                    $from_db, $to_db
                ]
            }
        },{
            '+select' => [
                {
                    max => 'outtemp',
                    -as => 'maxtemp'
                },{
                    min => 'outtemp',
                    -as => 'mintemp',
                },{
                    max => 'windgust',
                    -as => 'windgust',
                },{
                    sum => 'rain',
                    -as => 'rain',
                },{
                    avg => 'barometer',
                    -as => 'baramoter',
                }
            ],
            group_by => [
                \$group,
            ]
        }
    );

    my $count = $readdisp->count;
    my $raintot = 0; my $lasthms = 0;
    my @data;
    while (my $r = $readdisp->next)
    {
        push @data, {
            x     => $r->datetime->datetime,
            y     => celsius($r->get_column('maxtemp')),
            group => 2,
        };
        push @data, {
            x     => $r->datetime->datetime,
            y     => celsius($r->get_column('mintemp')),
            group => 1,
        };
        push @data, {
            x     => $r->datetime->datetime,
            y     => $r->windgust || 0,
            group => 3,
        };
        push @data, {
            x     => $r->datetime->datetime,
            y     => $r->barometer || 0,
            group => 4,
        };
        $raintot = 0
            if ($r->datetime->hms('') <= $lasthms);
        my $rain = $r->rain ? $r->rain : 0;
        $raintot += $rain;
        push @data, {
            x     => $r->datetime->datetime,
            y     => $raintot,
            group => 0,
        };
        $lasthms = $r->datetime->hms('');
    }

    my $groups = [
        {
            id      => 0,
            content => 'Rain (mm)',
            options => {
                style => 'bar',
                drawPoints => \0,
            }
        },{
            id      => 1,
            content => 'Temp min (C)',
            options => {
                drawPoints => {
                    style => 'circle'
                },
            }
        },{
            id      => 2,
            content => 'Temp max (C)',
            options => {
                drawPoints => {
                    style => 'square'
                },
            }
        },{
            id      => 3,
            content => 'Wind gust',
            options => {
                drawPoints => {
                    style => 'square'
                },
            }
        },{
            id      => 4,
            content => 'Pressure (in)',
            options => {
                drawPoints => \0
            }
        }
    ];

    header "Cache-Control" => "max-age=0, must-revalidate, private";
    content_type 'application/json';
    encode_json({
        data   => \@data,
        groups => $groups,
    });
};

sub celsius($)
{
    my $f = shift;
    return ($f - 32) * (5/9);
}

true;
