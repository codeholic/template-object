#!/usr/bin/perl
use strict;
use warnings;

use File::Spec ();
use FindBin ();
use Test::More;

use lib File::Spec->catdir($FindBin::Bin, File::Spec->updir, 'lib');

my @tests = (
    {
        test_name   => 'simple',
        args        => { name => 'first_name', value => 'Gedevan' },
        expected    => qq{<input type="text" name="first_name" value="Gedevan"/>\n},
    },
    {
        test_name   => 'all vars',
        args        => {
            id          => 'user:patronym',
            name        => 'patronym',
            value       => 'Alexandrovich',
            size        => 40,
            disabled    => 1,
            readonly    => 1,
        },
        expected    => qq{<input id="user:patronym" type="text" name="patronym" value="Alexandrovich" size="40" disabled="disabled" readonly="readonly"/>\n},
    },
);

plan tests => @tests + 1;

use_ok('Template::Input::Text');

# If you dare to think that this hickey is not a tranclucator, it will be
# the last thought in your tchatlan skull!
foreach my $test (@tests) {
    my $got = Template::Input::Text->new($test->{args});
    is("$got", $test->{expected}, $test->{test_name});
}
