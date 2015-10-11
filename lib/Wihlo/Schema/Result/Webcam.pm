use utf8;
package Wihlo::Schema::Result::Webcam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wihlo::Schema::Result::Webcam

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<webcam>

=cut

__PACKAGE__->table("webcam");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 image

  data_type: 'mediumblob'
  is_nullable: 1

=head2 thumbnail

  data_type: 'blob'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "image",
  { data_type => "mediumblob", is_nullable => 1 },
  "thumbnail",
  { data_type => "blob", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07038 @ 2015-10-11 23:23:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9rV+C16hOBNKphDBVFbktg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
