use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has bar => (is => 'ro',  isa_class => 'SomeClass');
    has baz => (is => 'rwp', isa_role  => 'SomeRole');
}

use Test::More;
use Test::Moose::More;

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
