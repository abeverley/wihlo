use utf8;
package Wihlo::Schema::Result::Station;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wihlo::Schema::Result::Station

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

=head1 TABLE: C<station>

=cut

__PACKAGE__->table("station");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 lastdata

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 maxdst

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "lastdata",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "maxdst",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-01-01 21:26:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lWlHP80lRTSR9GXvt1TY8Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
