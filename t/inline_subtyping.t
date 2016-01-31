use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has bar => (
        is         => 'rw',
        isa        => 'Int',
        constraint => sub { $_ > 0 },
    );

    has baz => (
        is         => 'rw',
        isa        => 'Int',
        constraint => sub { $_ > 0 },
        constraint_msg => sub { "bad! $_" },
    );
}

use Test::More;
use Test::Moose::More 0.037;
use Test::Fatal;

# TODO shift the constraint checking out into TMM?

validate_class TestClass => (
    -subtest => 'Validating attributes composed with constraint shortcuts',
    attributes => [
        bar => {
            -does => [ 'MooseX::AttributeShortcuts::Trait::Attribute' ],
            -attributes   => [
                constraint  => { is => 'ro', isa => 'CodeRef' },
                constraint_msg => { is => 'ro', isa => 'CodeRef' },
            ],
            reader       => undef,
            writer       => undef,
            accessor     => 'bar',
            original_isa => 'Int',
            required     => undef,
            constraint_msg => undef,
        },
        baz => {
            -does => [ 'MooseX::AttributeShortcuts::Trait::Attribute' ],
            # -attributes => [ 'constraint', 'constraint_msg' ],
            -attributes   => [
                constraint  => { is => 'ro', isa => 'CodeRef' },
                constraint_msg => { is => 'ro', isa => 'CodeRef' },
            ],
            reader       => undef,
            writer       => undef,
            accessor     => 'baz',
            original_isa => 'Int',
            required     => undef,
        },
    ],
);


subtest 'value OK' => sub {

    my $tc;

    my $msg = exception { $tc = TestClass->new(bar => 10) };
    is $msg, undef, 'does not die on construction';
    is $tc->bar, 10, 'value is correct';

    $msg = exception { $tc->bar(20) };
    is $msg, undef, 'does not die on setting';
    is $tc->bar, 20, 'value is correct';
};

subtest 'value NOT OK' => sub {

    my $error = qr/Attribute \(bar\) does not pass the type constraint/;

    my $tc;
    my $msg = exception { $tc = TestClass->new(bar => -10) };
    ok !!$msg, 'dies on bad value';
    like $msg, $error, 'dies with expected message';

    $msg = exception { $tc = TestClass->new(bar => 10) };
    is $msg, undef, 'does not die on construction with OK value';
    is $tc->bar, 10, 'value is correct';

    $msg = exception { $tc->bar(-10) };
    ok !!$msg, 'dies on bad value';
    like $msg, $error, 'dies with expected message';
};

subtest 'value NOT OK, w/custom message' => sub {

    my $error = qr/Attribute \(baz\) does not pass the type constraint because: bad! -10/;

    my $tc;
    my $msg = exception { $tc = TestClass->new(baz => -10) };
    ok !!$msg, 'dies on bad value';
    like $msg, $error, 'dies with expected message';
};

done_testing;
