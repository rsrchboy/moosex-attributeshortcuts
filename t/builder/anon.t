use strict;
use warnings;

use Test::More;
use Test::Moose::More 0.011;

my $i = 0;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo => (is => 'ro', builder => sub { $i++ });
}
{
    package TestRole;

    use Moose::Role;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has bar => (is => 'ro', builder => sub { $i++ });
}

validate_class TestClass => (
    attributes => [ qw{ foo            } ],
    methods    => [ qw{ foo _build_foo } ],
);

is $i, 0, 'counter correct (sanity check)';
my $tc = TestClass->new;
isa_ok $tc, 'TestClass';
is $i, 1, 'counter correct';

TODO: {
    local $TODO = 'not currently setting up anon builder as method in roles yet';

    # using builders in roles and being able to exclude/alias them as
    # necessary when consuming them is a major win.  Because of that -- and
    # because that's what we'd expect to be able to do with a builder when
    # created in the usual fashion (aka not anon sub via us) we want to create
    # the builder as a method in the role when we define the attribute to a
    # role.
    #
    # We don't do that quite yet :)

    validate_role TestRole => (
        attributes => [ qw{ bar } ],
        methods    => [ qw{ _build_bar } ],
    );
}

done_testing;
