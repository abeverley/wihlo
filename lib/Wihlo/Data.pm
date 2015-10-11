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

package Wihlo::Data;

use DateTime;
use DateTime::Format::Strptime;

use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use MooX::Types::MooseLike::DateTime qw/DateAndTime/;

has schema => (
    is       => 'ro',
    required => 1,
);

has from => (
    is      => 'rw',
    isa     => DateAndTime,
    lazy    => 1,
    builder => sub {
        my $self = shift;
        $self->to->clone->subtract(days => 5);
    },
);

has to => (
    is      => 'rw',
    isa     => DateAndTime,
    lazy    => 1,
    builder => sub { DateTime->now },
);

has readings => (
    is  => 'lazy',
    isa => ArrayRef,
);

has readings_graph => (
    is  => 'lazy',
    isa => ArrayRef,
);

# day, hour, minute. Defaults to sensible value
# depending on range
has group_by => (
    is  => 'lazy',
    isa => Str,
);

# The actual SQL grouping, based on group_by
has _sql_group_by => (
    is  => 'lazy',
    isa => ArrayRef,
);

sub _build_readings
{   my $self = shift;

    my $parser = $self->schema->storage->datetime_parser;
    my $readdisp = $self->schema->resultset('Reading')->search(
        {
            datetime => {
                -between => [
                    $parser->format_datetime($self->from),
                    $parser->format_datetime($self->to),
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
                $self->_sql_group_by,
            ]
        }
    );

    my $raintot = 0; my $lasthms = 0;
    my @readings;
    while (my $r = $readdisp->next)
    {
        $raintot = 0
            if ($r->datetime->hms('') <= $lasthms);
        my $rain = $r->rain ? $r->rain : 0;
        $raintot += $rain;

        push @readings, {
            datetime  => $r->datetime,
            maxtemp   => celsius($r->get_column('maxtemp')),
            mintemp   => celsius($r->get_column('mintemp')),
            windgust  => $r->windgust || 0,
            barometer => $r->barometer || 0,
            raintot   => $raintot,
        };
        $lasthms = $r->datetime->hms('');
    }

    \@readings;
};

sub _build_readings_graph
{   my $self = shift;
    my @readings;

    foreach my $reading (@{$self->readings})
    {
        my $datetime = $reading->{datetime}->datetime;
        push @readings, {
            x     => $datetime,
            y     => $reading->{maxtemp},
            group => 2,
        };
        push @readings, {
            x     => $datetime,
            y     => $reading->{mintemp},
            group => 1,
        };
        push @readings, {
            x     => $datetime,
            y     => $reading->{windgust},
            group => 3,
        };
        push @readings, {
            x     => $datetime,
            y     => $reading->{barometer},
            group => 4,
        };
        push @readings, {
            x     => $datetime,
            y     => $reading->{raintot},
            group => 0,
        };
    }
    \@readings;
}

sub _build_group_by
{   my $self = shift;
    my $diff = $self->from->subtract_datetime( $self->to );
    my $group = !$diff->months && !$diff->years && !$diff->weeks
              ? 'minute'
              : !$diff->months && !$diff->years
              ? 'hour'
              : 'day';
    $group;
}

sub _build__sql_group_by
{   my $self = shift;

    my @group = (
        $self->schema->resultset('Reading')->dt_SQL_pluck({ -ident => '.datetime' }, 'year'),
        $self->schema->resultset('Reading')->dt_SQL_pluck({ -ident => '.datetime' }, 'month'),
        $self->schema->resultset('Reading')->dt_SQL_pluck({ -ident => '.datetime' }, 'day_of_month'),
    );

    push @group, $self->schema->resultset('Reading')->dt_SQL_pluck({ -ident => '.datetime' }, 'hour')
        if $self->group_by eq 'hour' || $self->group_by eq 'minute';
    push @group, $self->schema->resultset('Reading')->dt_SQL_pluck({ -ident => '.datetime' }, 'minute')
        if $self->group_by eq 'minute';
    \@group;
}

sub celsius($)
{
    my $f = shift;
    my $c = ($f - 32) * (5/9);
    sprintf("%.2f", $c);
}

1;
