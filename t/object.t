#!/usr/bin/perl
use strict;
use warnings;

use File::Spec ();
use FindBin ();
use Test::More tests => 2;

use lib File::Spec->catdir($FindBin::Bin, File::Spec->updir, 'lib');

use_ok('Template::Object');

my $t = Template::Object->new->vars(value => {destination => 215});
is_deeply($t->{vars}{value}, [{destination => 215}], 'vars, attributes');
