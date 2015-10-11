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

package Wihlo::Webcam;

use DateTime;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use MooX::Types::MooseLike::DateTime qw/DateAndTime/;

has schema => (
    is       => 'ro',
    required => 1,
);

sub image
{   my ($self, %options) = @_;
    my $dt = DateTime->from_epoch(epoch => $options{time});
    my $parser = $self->schema->storage->datetime_parser;
    my ($image) = $self->schema->resultset('Webcam')->search({
        time => {
            '<' => $parser->format_datetime($dt),
        },
    },{
        rows     => 1,
        order_by => {
            -desc => 'time',
        },
    })->all;
    $image->get_column('image');
}

1;
