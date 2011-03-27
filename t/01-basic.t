use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo => (is => 'rwp');
    has bar => (is => 'ro', builder => 1);
    has baz => (is => 'rwp', builder => 1);

}

use Test::More;
use Test::Moose;

# sanity checks
meta_ok('TestClass');
has_attribute_ok('TestClass', $_) for qw{ foo bar baz };
does_ok(
    TestClass->meta->attribute_metaclass,
    'MooseX::AttributeShortcuts::Trait::Attribute',
);

my $meta = TestClass->meta;
my ($foo, $bar, $baz) = map { $meta->get_attribute($_) } qw{ foo bar baz };
is($_->reader, $_->name, $_->name . ': reader => correct') for $foo, $bar, $baz;
is($_->writer, '_' . $_->name, $_->name . ': writer => correct') for $foo, $baz;
is($_->writer, undef, $_->name . ': writer => correct (undef)') for $bar;
is($_->builder, undef, $_->name . ': builder => correct (undef)') for $foo;
is($_->accessor, undef, $_->name . ': accessor => correct (undef)') for $foo, $bar, $baz;
is($_->builder, '_build_' . $_->name, $_->name . ': builder => correct') for $bar, $baz;

done_testing;


