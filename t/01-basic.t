use strict;
use warnings;
use Test::More tests => 2;
use FindBin;
use JSON;

use lib "$FindBin::Bin/lib";
use Class;

my $object = Class->new;

is_deeply($object->TO_JSON(), {
    string    => 'hello',
    integer   => 3,
    number    => 3.1415,
    bool      => JSON::false,
    array     => [1,2,3],
    array_ref => [1,2,3],
    hash      => {one => 1, two => 2, three => 3},
    hash_ref  => {one => 1, two => 2, three => 3},
    custom    => "hello world",
}, 'object TO_JSON');

is_deeply(Class::TO_JSON(), {
    string    => 'hello',
    integer   => 3,
    number    => 3.1415,
    bool      => JSON::false,
    array     => [1,2,3],
    array_ref => [1,2,3],
    hash      => {one => 1, two => 2, three => 3},
    hash_ref  => {one => 1, two => 2, three => 3},
    custom    => "hello world",
}, 'package TO_JSON');


done_testing();
