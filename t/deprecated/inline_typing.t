use strict;
use warnings;

use Test::More;
use Test::Moose::More;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;
    use Test::Warn;

    warnings_exist {
            has bar => (is => 'ro',  isa_class => 'SomeClass');
            has baz => (is => 'rwp', isa_role  => 'SomeRole');
        }
        [ qr/Naughty! isa_class, isa_role, and isa_enum will be removed on or after 01 July 2015!/ ],
        'expected warnings thrown for isa_class, isa_role usage',
        ;
}

# TODO shift the constraint checking out into TMM?

validate_class TestClass => (
    attributes => [ qw{ bar baz } ],
);

subtest 'isa_class check' => sub {
    my $att = 'bar';
    my $meta = TestClass->meta->get_attribute($att);
    ok $meta->has_type_constraint, "$att has a type constraint";
    my $tc = $meta->type_constraint;
    isa_ok $tc, 'Moose::Meta::TypeConstraint::Class';
    is $tc->class, 'SomeClass', 'tc looks for correct class';
};

subtest 'isa_role check' => sub {
    my $att = 'baz';
    my $meta = TestClass->meta->get_attribute($att);
    ok $meta->has_type_constraint, "$att has a type constraint";
    my $tc = $meta->type_constraint;
    isa_ok $tc, 'Moose::Meta::TypeConstraint::Role';
    is $tc->role, 'SomeRole', 'tc looks for correct role';
};


done_testing;
