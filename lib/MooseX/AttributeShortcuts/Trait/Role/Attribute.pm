package MooseX::AttributeShortcuts::Trait::Role::Attribute;

# ABSTRACT: Role attribute trait to create builder method

use MooseX::Role::Parameterized;
use namespace::autoclean 0.24;
use MooseX::Types::Common::String ':all';

with 'MooseX::AttributeShortcuts::Trait::Attribute::HasAnonBuilder';

parameter builder_prefix => (isa => NonEmptySimpleStr, default => '_build_');

=after attach_to_role

If we have an anonymous builder defined in our role options, install it as a
method.

=around new

If we have an anonymous builder defined in our role options, swizzle our options
such that C<builder> becomes the builder method name, and C<anon_builder>
is the anonymous sub.

=cut

after attach_to_role  => sub {
    my ($self, $role) = @_;

    ### has anon builder?: $self->has_anon_builder
    return unless $self->has_anon_builder;

    ### install our anon builder as a method
    $role->add_method($self->builder => $self->anon_builder);
};

role {
    my $p = shift @_;

    around new => sub {
        # my ($orig, $class) = (shift, shift);
        my ($orig, $class, $name, %options) = @_;

        # just pass to the original new() if we don't have an anon builder
        return $class->$orig($name => %options)
            unless exists $options{builder} && (ref $options{builder} || q{}) eq 'CODE';

        # stash anon_builder, set builder => 1
        $options{anon_builder} = $options{builder};
        $options{builder}      = $p->builder_prefix . $name;

        ### %options
        ### anon builder: $options{builder}
        return $class->$orig($name => %options);
    };
};

!!42;
__END__

=head1 DESCRIPTION

Normally, attribute options processing takes place at the time an attribute is created and attached
to a class, either by virtue of a C<has> statement in a class definition or when a role is applied to a
class.

This is not an optimal approach for anonymous builder methods.

This is a role attribute trait, to create builder methods when role attributes are created,
so that they can be aliased, excluded, etc, like any other role method.

=cut
