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
use DateTime::Format::Strptime;
use DateTime::Format::DBI;
use JSON;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get qr{^/data/?([-\d]*)/?([-\d]*)/?$} => sub {
    my ( $from_param, $to_param ) = splat;

    my $reading_rs = rset('Reading');
    schema->storage->debug(1);

    # Convert date parameters to DateTime objects
    my $strp = DateTime::Format::Strptime->new( pattern   => '%F' );
    my $to   = $strp->parse_datetime($to_param)   || DateTime->now( time_zone => 'floating' );
    my $from = $strp->parse_datetime($from_param) || $to->clone->subtract( days => 1 );

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

    my $readdisp = $reading_rs->search({ datetime => {'-between' => [$from_db, $to_db]} }
                                      ,{ '+select' => [ { max => 'outtemp'  , -as => 'maxtemp'   },
                                                        { min => 'outtemp'  , -as => 'mintemp'   },
                                                        { max => 'windgust' , -as => 'windgust'  },
                                                        { sum => 'rain'     , -as => 'rain'      },
                                                        { avg => 'barometer', -as => 'baramoter' }
                                                    ],
                                         group_by => [ \$group ] }
    );

    my @max; my @min; my @wind; my @rain; my @barom;
    my $count = $readdisp->count;
    my $raintot = 0; my $lasthms = 0;
    while (my $r = $readdisp->next)
    {
        push @max,   { x=>$r->datetime->epoch, y=>celsius($r->get_column('maxtemp'))};
        push @min,   { x=>$r->datetime->epoch, y=>celsius($r->get_column('mintemp'))};
        push @wind,  { x=>$r->datetime->epoch, y=>$r->windgust+0 };
        push @barom, { x=>$r->datetime->epoch, y=>$r->barometer+0};
        $raintot = 0
            if ($r->datetime->hms('') <= $lasthms);
<<<<<<< HEAD
        my $rain = $r->rain ? $r->rain : 0;
        $raintot += $rain; # $r->rain;
=======
        $raintot += $r->rain;
>>>>>>> 590a991c842702ea7715881f47332bd947308e85
        push @rain, { x=>$r->datetime->epoch, y=>$raintot};
        $lasthms = $r->datetime->hms('');
    }

    my $data = 
        [
        {
                "color" => "darkblue",
                "name"=> "Rain (mm)",
                "data"=> \@rain,
                "renderer" => "bar",
        }, 
        {
                "color" => "lightblue",
                "name"=> "Temp min (C)",
                "data"=> \@min,
                "renderer" => "line",
        }, 
        {
                "color" => "red",
                "name"=> "Temp max (C)",
                "data"=> \@max,
                "renderer" => "line",
        }, 
        {
                "color" => "forestgreen",
                "name"=> "Wind gust",
                "data"=> \@wind,
                "renderer" => "line",
        }, 
        {
                "color" => "orange",
                "name"=> "Pressure (in)",
                "data"=> \@barom,
                "renderer" => "line",
        }, 
        ]
    ;

<<<<<<< HEAD
    header "Cache-Control" => "max-age=0, must-revalidate, private";
    content_type 'application/json';
    encode_json($data);
=======
    $data;
>>>>>>> 590a991c842702ea7715881f47332bd947308e85
};

sub celsius($)
{
    my $f = shift;
    return ($f - 32) * (5/9);
}

true;
