#!/usr/bin/perl
use strict;
use warnings;

use File::Spec ();
use FindBin ();
use Test::More;

use lib File::Spec->catdir($FindBin::Bin, File::Spec->updir, 'lib');

my %t = (
    default => <<'__TEMPLATE__',
<select name="{{name}}"{ multiple="{multiple}"}>
<!-- BEGIN option -->
<option{ value="{id}"}{ selected="{selected}"}>{{name}}</option>
<!-- END option -->
</select>
__TEMPLATE__
);

my %expected = (
    destination => <<'__RESULT__',
<select name="destination">
<option>Earth</option>
<option selected="selected">Pluke</option>
<option>Uzm</option>
</select>
__RESULT__
    origin => <<'__RESULT__',
<select name="origin">
<option selected="selected"></option>
<option>Earth</option>
<option>Pluke</option>
<option>Uzm</option>
</select>
__RESULT__
    visited_planets => <<'__RESULT__',
<select name="visited_planets" multiple="multiple">
<option selected="selected">Earth</option>
<option selected="selected">Pluke</option>
<option>Uzm</option>
</select>
__RESULT__
    destination2 => <<'__RESULT__',
<select name="destination">
<option value="013">Earth</option>
<option value="215" selected="selected">Pluke</option>
<option value="247">Uzm</option>
</select>
__RESULT__
    origin2 => <<'__RESULT__',
<select name="origin">
<option selected="selected"></option>
<option value="013">Earth</option>
<option value="215">Pluke</option>
<option value="247">Uzm</option>
</select>
__RESULT__
    visited_planets2 => <<'__RESULT__',
<select name="visited_planets" multiple="multiple">
<option value="013" selected="selected">Earth</option>
<option value="215" selected="selected">Pluke</option>
<option value="247">Uzm</option>
</select>
__RESULT__
);

my $options = [qw/Earth Pluke Uzm/];
my $options_hashref = [
    { id => '013',  name => 'Earth' },
    { id => 215,    name => 'Pluke' },
    { id => 247,    name => 'Uzm' },
];

my @tests = (
    {
        test_name   => 'simple',
        args => {
            template    => $t{default},
            options     => $options,
            name        => 'destination',
            value       => 'Pluke',
        },
        expected    => $expected{destination},
    },
    {
        test_name   => 'nullable',
        args => {
            template    => $t{default},
            options     => $options,
            name        => 'origin',
            nullable    => 1,
            value       => undef,
        },
        expected    => $expected{origin},
    },
    {
        test_name   => 'multiple',
        args => {
            template    => $t{default},
            options     => $options,
            name        => 'visited_planets',
            multiple    => 1,
            value       => [qw/Earth Pluke/],
        },
        expected    => $expected{visited_planets},
    },
    {
        test_name   => 'simple, hashref value',
        args => {
            template    => $t{default},
            options     => $options,
            name        => 'destination',
            value       => { destination => 'Pluke' },
        },
        expected    => $expected{destination},
    },
    {
        test_name   => 'nullable, hashref value',
        args => {
            template    => $t{default},
            options     => $options,
            name        => 'origin',
            nullable    => 1,
            value       => { origin => undef },
        },
        expected    => $expected{origin},
    },
    {
        test_name   => 'multiple, hashref value',
        args => {
            template    => $t{default},
            options     => $options,
            name        => 'visited_planets',
            multiple    => 1,
            value_from  => 'planet',
            value       => [
                { planet => 'Earth' },
                { planet => 'Pluke' },
            ],
        },
        expected    => $expected{visited_planets},
    },
    {
        test_name   => 'simple, hashref options',
        args => {
            template    => $t{default},
            options     => $options_hashref,
            name        => 'destination',
            value       => 215,
        },
        expected    => $expected{destination2},
    },
    {
        test_name   => 'nullable, hashref options',
        args => {
            template    => $t{default},
            options     => $options_hashref,
            name        => 'origin',
            nullable    => 1,
            value       => undef,
        },
        expected    => $expected{origin2},
    },
    {
        test_name   => 'multiple, hashref options',
        args => {
            template    => $t{default},
            options     => $options_hashref,
            name        => 'visited_planets',
            multiple    => 1,
            value       => [ '013', 215 ],
        },
        expected    => $expected{visited_planets2},
    },
    {
        test_name   => 'simple, hashref value + options',
        args => {
            template    => $t{default},
            options     => $options_hashref,
            name        => 'destination',
            value       => { destination => 215 },
        },
        expected    => $expected{destination2},
    },
    {
        test_name   => 'nullable, hashref value + options',
        args => {
            template    => $t{default},
            options     => $options_hashref,
            name        => 'origin',
            nullable    => 1,
            value       => { origin => undef },
        },
        expected    => $expected{origin2},
    },
    {
        test_name   => 'multiple, hashref value + options',
        args => {
            template    => $t{default},
            options     => $options_hashref,
            name        => 'visited_planets',
            multiple    => 1,
            value_from  => 'planet',
            value       => [ { planet => '013' }, { planet => 215 } ],
        },
        expected    => $expected{visited_planets2},
    },
);

plan tests => @tests + 1;

use_ok('Template::Input::Select');

# Vladimir Nikolayevich! Humankind spent millenia for a single stone
# from the Moon, and here we have a live alien and an etsykh made of
# unknown alloy! - Leave it, I said!
foreach my $test (@tests) {
    my $got = Template::Input::Select->new($test->{args});
    is("$got", $test->{expected}, $test->{test_name});
}
