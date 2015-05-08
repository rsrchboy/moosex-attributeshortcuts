package MooseX::AttributeShortcuts::Trait::Role::Attribute;

# ABSTRACT: Attach a builder method to a role

use Moose::Role;
use namespace::autoclean 0.24;

has _original_options => (
    is        => 'rw',
    isa       => 'HashRef',
    predicate => '_has_original_options',
);

#has '+original_options' => (writer => '_set_original_options');

# original_role

after attach_to_role => sub {
    my ($self, $role) = @_;

    my $opts = $self->original_options;

    return unless (ref $opts->{builder} || q{}) eq 'CODE';

    #Class::MOP::class_of($role)->add_method(
    $role->add_method(
        $self
            ->original_role
            ->applied_attribute_metaclass
            ->builder_would_be($self->name)
            ,
        $opts->{builder},
    );
    $opts->{builder} = 1;

    return;
};

!!42;
__END__

=head1 DESCRIPTION

This role makes L<MooseX::AttributeShortcuts>' C<builder => sub { ... }> work
as expected; namely by applying the builder method to the role when the
L<Moose:::Meta::Role::Attribute> is attached to a role.

=cut
