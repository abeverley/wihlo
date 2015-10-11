package Wihlo::Schema::ResultSet;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::DateMethods1');

1;
