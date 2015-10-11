use utf8;
package Wihlo::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

# XXX Broken the rule. Will need to fix this later.
Wihlo::Schema->load_namespaces(
   default_resultset_class => 'ResultSet',
);

# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-12-29 21:57:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4l67aG992bcXZcWCzwzoUA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
