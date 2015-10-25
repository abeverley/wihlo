#!/usr/bin/env perl

=pod
Wihlo - Web-based weather logging and display software
Copyright (C) 2015 A Beverley

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

use Dancer2;
use Dancer2::Plugin::DBIC qw(schema resultset rset);
use DateTime;
use Image::Magick;
use LWP::Simple qw//;
use Wihlo::Schema;

my $image = LWP::Simple::get("http://192.168.1.201/img/snapshot.cgi");

my $imgm = Image::Magick->new(magick => 'jpg');
$imgm->BlobToImage($image);
$imgm->Resize(width => '64', height => '64');
$imgm->write(filename => 'xx.jpg');
my $thumbnail = $imgm->ImageToBlob;

rset('Webcam')->create({
    time      => DateTime->now,
    image     => $image,
    thumbnail => $thumbnail,
});

1;
