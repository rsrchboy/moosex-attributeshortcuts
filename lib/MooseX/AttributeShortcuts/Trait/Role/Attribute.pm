package MooseX::AttributeShortcuts::Trait::Role::Attribute;

# ABSTRACT: Role attribute trait to create builder method

use MooseX::Role::Parameterized;
use namespace::autoclean 0.24;
use MooseX::Types::Common::String ':all';

# debugging...
use Smart::Comments '###';

parameter builder_prefix => (isa => NonEmptySimpleStr, default => '_build_');

role {
    my $p = shift @_;

    has anon_builder => (
        reader    => 'anon_builder',
        writer    => '_set_anon_builder',
        isa       => 'CodeRef',
        predicate => 'has_anon_builder',
        init_arg  => '_anon_builder',
    );

    around new => sub {
        # my ($orig, $class) = (shift, shift);
        my ($orig, $class, $name, %options) = @_;

        # just pass to the original new() if we don't have an anon builder
        return $class->$orig($name => %options)
            unless exists $options{builder} && (ref $options{builder} || q{}) eq 'CODE';

        # stash anon_builder, set builder => 1
        $options{_anon_builder} = $options{builder};
        $options{builder} = $p->builder_prefix . $name;

        ### anon builder: $options{builder}
        return $class->$orig($name => %options);
    };

    after attach_to_role  => sub {
        my ($self, $role) = @_;

        return unless $self->has_anon_builder;

        ### install our anon builder as a method
        $role->add_method($self->builder => $self->anon_builder);
    };

};

!!42;
