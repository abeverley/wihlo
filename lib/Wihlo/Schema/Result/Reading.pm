use utf8;
package Wihlo::Schema::Result::Reading;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wihlo::Schema::Result::Reading

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

=head1 TABLE: C<reading>

=cut

__PACKAGE__->table("reading");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 usunits

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=head2 usunitsrain

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=head2 datetime

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 intvl

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 barometer

  data_type: 'decimal'
  is_nullable: 1
  size: [5,3]

=head2 intemp

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 outtemp

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 outtemphi

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 outtemplo

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 inhumidity

  data_type: 'decimal'
  is_nullable: 1
  size: [3,1]

=head2 outhumidity

  data_type: 'decimal'
  is_nullable: 1
  size: [3,1]

=head2 windspeed

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 winddir

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 windgust

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 windgustdir

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 rainrate

  data_type: 'decimal'
  is_nullable: 1
  size: [5,2]

=head2 rain

  data_type: 'decimal'
  is_nullable: 1
  size: [5,2]

=head2 et

  data_type: 'decimal'
  is_nullable: 1
  size: [4,3]

=head2 radiation

  data_type: 'decimal'
  is_nullable: 1
  size: [6,1]

=head2 radiationmax

  data_type: 'decimal'
  is_nullable: 1
  size: [6,1]

=head2 uv

  data_type: 'decimal'
  is_nullable: 1
  size: [3,1]

=head2 uvmax

  data_type: 'decimal'
  is_nullable: 1
  size: [3,1]

=head2 extratemp1

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 extratemp2

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 extratemp3

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 soiltemp1

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 soiltemp2

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 soiltemp3

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 soiltemp4

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 leaftemp1

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 leaftemp2

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 extrahumid1

  data_type: 'decimal'
  is_nullable: 1
  size: [3,1]

=head2 extrahumid2

  data_type: 'decimal'
  is_nullable: 1
  size: [3,1]

=head2 soilmoist1

  data_type: 'integer'
  is_nullable: 1

=head2 soilmoist2

  data_type: 'integer'
  is_nullable: 1

=head2 soilmoist3

  data_type: 'integer'
  is_nullable: 1

=head2 soilmoist4

  data_type: 'integer'
  is_nullable: 1

=head2 leafwet1

  data_type: 'integer'
  is_nullable: 1

=head2 leafwet2

  data_type: 'integer'
  is_nullable: 1

=head2 uploaded_wg

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 uploaded_wow

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "usunits",
  { data_type => "smallint", default_value => 1, is_nullable => 0 },
  "usunitsrain",
  { data_type => "smallint", default_value => 1, is_nullable => 0 },
  "datetime",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "intvl",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "barometer",
  { data_type => "decimal", is_nullable => 1, size => [5, 3] },
  "intemp",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "outtemp",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "outtemphi",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "outtemplo",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "inhumidity",
  { data_type => "decimal", is_nullable => 1, size => [3, 1] },
  "outhumidity",
  { data_type => "decimal", is_nullable => 1, size => [3, 1] },
  "windspeed",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "winddir",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "windgust",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "windgustdir",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "rainrate",
  { data_type => "decimal", is_nullable => 1, size => [5, 2] },
  "rain",
  { data_type => "decimal", is_nullable => 1, size => [5, 2] },
  "et",
  { data_type => "decimal", is_nullable => 1, size => [4, 3] },
  "radiation",
  { data_type => "decimal", is_nullable => 1, size => [6, 1] },
  "radiationmax",
  { data_type => "decimal", is_nullable => 1, size => [6, 1] },
  "uv",
  { data_type => "decimal", is_nullable => 1, size => [3, 1] },
  "uvmax",
  { data_type => "decimal", is_nullable => 1, size => [3, 1] },
  "extratemp1",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "extratemp2",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "extratemp3",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "soiltemp1",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "soiltemp2",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "soiltemp3",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "soiltemp4",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "leaftemp1",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "leaftemp2",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "extrahumid1",
  { data_type => "decimal", is_nullable => 1, size => [3, 1] },
  "extrahumid2",
  { data_type => "decimal", is_nullable => 1, size => [3, 1] },
  "soilmoist1",
  { data_type => "integer", is_nullable => 1 },
  "soilmoist2",
  { data_type => "integer", is_nullable => 1 },
  "soilmoist3",
  { data_type => "integer", is_nullable => 1 },
  "soilmoist4",
  { data_type => "integer", is_nullable => 1 },
  "leafwet1",
  { data_type => "integer", is_nullable => 1 },
  "leafwet2",
  { data_type => "integer", is_nullable => 1 },
  "uploaded_wg",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "uploaded_wow",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<dateTime>

=over 4

=item * L</datetime>

=back

=cut

__PACKAGE__->add_unique_constraint("dateTime", ["datetime"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-04-14 12:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:42H+MIylHVJpMqGF1EVwxQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
