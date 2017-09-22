package MooseX::AttributeShortcuts::Trait::Method::Builder;

# ABSTRACT: Trait for inline builder method metaclasses

use Moose::Role;
use namespace::autoclean;

with 'MooseX::AttributeShortcuts::Trait::Method::HasDefinitionContext';

=attr associated_attribute

Read only, required, weak, must be a L<Moose::Meta::Attribute> or descendant.

Contains the attribute this builder is associated with.

=cut

has associated_attribute => (
    is       => 'ro',
    isa      => 'Moose::Meta::Attribute',
    required => 1,
    weak_ref => 1,
);

!!42;
__END__

=head1 DESCRIPTION

This is a L<method metaclass|Moose::Meta::Method> trait that allows inline
builder methods to be associated with their attribute, and to take on a
definition context.  This additional information will allow inline builders to
be more readily identified and associated with their owning attributes.

=cut
