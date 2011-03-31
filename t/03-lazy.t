use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo => (is => 'lazy');
}

use Test::More;
use Test::Moose;

require 't/funcs.pm' unless eval { require funcs };

my %accessors = (
    reader   => 'foo',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_foo',
);

test_class_sanity_checks('TestClass');
check_attribute('TestClass', foo => %accessors);

done_testing;

