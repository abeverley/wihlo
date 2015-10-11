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
use Wihlo::Data;

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

    my $range = session('range') || {};

    my $data = Wihlo::Data->new(
        schema   => schema,
        group_by => 'day',
    );
    $data->from($range->{from}) if $range->{from};
    $data->to($range->{to}) if $range->{to};

    template 'index' => {
        readings => $data->readings,
        range    => $range,
    };
};

get '/data' => sub {

    my $range = session('range') || {};

    my $data = Wihlo::Data->new(
        schema => schema,
        from   => $range->{from},
        to     => $range->{to},
    );

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
        data   => $data->readings_graph,
        groups => $groups,
    });
};

sub celsius($)
{
    my $f = shift;
    return ($f - 32) * (5/9);
}

true;
