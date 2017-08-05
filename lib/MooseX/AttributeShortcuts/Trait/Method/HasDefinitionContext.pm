package MooseX::AttributeShortcuts::Trait::Method::HasDefinitionContext;

# ABSTRACT: Trait for method metaclasses that have definition contexts

use Moose::Role;
use namespace::autoclean;

=attr definition_context

Read only, required, must be a reference to a hash.

This is the definition context of this method; e.g. where it was defined and
to what.

=cut

has definition_context => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

!!42;
__END__

=head1 DESCRIPTION

This is a L<method metaclass:Moose::Meta::Method> trait that allows inline
builder methods to be associated with their attribute, and to take on a
definition context.  This additional information will allow inline builders to
be more readily identified and associated with their owning attributes.

=cut
