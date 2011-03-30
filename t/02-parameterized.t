use strict;
use warnings;

{
    package TestClass::WriterPrefix;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts -writer_prefix => '_set_';

    has foo => (is => 'rwp');
    has bar => (is => 'ro', builder => 1);
    has baz => (is => 'rwp', builder => 1);

}
{
    package TestClass::BuilderPrefix;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts -builder_prefix => '_silly_';

    has foo => (is => 'rwp');
    has bar => (is => 'ro', builder => 1);
    has baz => (is => 'rwp', builder => 1);

}

use Test::More;
use Test::Moose;

test_class('TestClass::WriterPrefix', '_set_');
test_class('TestClass::BuilderPrefix', undef, '_silly_');

done_testing;

sub test_class {
    my $classname      = shift @_;
    my $writer_prefix  = shift @_ || '_';
    my $builder_prefix = shift @_ || '_build_';

    # sanity checks
    meta_ok($classname);
    has_attribute_ok($classname, $_) for qw{ foo bar baz };
    does_ok(
        $classname->meta->attribute_metaclass,
        'MooseX::AttributeShortcuts::Trait::Attribute',
    );

    my $meta = $classname->meta;
    my ($foo, $bar, $baz) = map { $meta->get_attribute($_) } qw{ foo bar baz };

    is($_->reader, $_->name, $_->name . ': reader => correct') for $foo, $bar, $baz;
    is($_->writer, $writer_prefix . $_->name, $_->name . ': writer => correct') for $foo, $baz;
    is($_->writer, undef, $_->name . ': writer => correct (undef)') for $bar;
    is($_->builder, undef, $_->name . ': builder => correct (undef)') for $foo;
    is($_->accessor, undef, $_->name . ': accessor => correct (undef)') for $foo, $bar, $baz;
    is($_->builder, $builder_prefix . $_->name, $_->name . ': builder => correct') for $bar, $baz;
}

