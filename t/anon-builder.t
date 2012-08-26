use strict;
use warnings;

use Test::More;
use Test::Moose::More 0.010;

my $i = 0;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo => (is => 'ro', builder => sub { $i++ });
}

validate_class TestClass => (

    attributes => [ qw{ foo            } ],
    methods    => [ qw{ foo _build_foo } ],
);

is $i, 0, 'counter correct (sanity check)';
my $tc = TestClass->new;
isa_ok $tc, 'TestClass';
is $i, 1, 'counter correct';

done_testing;
