package MooseX::AttributeShortcuts::Trait::Attribute::HasAnonBuilder;

# ABSTRACT: Attributes, etc, common to both the role-attribute and attribute traits

use Moose::Role;
use namespace::autoclean 0.24;

has anon_builder => (
    reader    => 'anon_builder',
    writer    => '_set_anon_builder',
    isa       => 'CodeRef',
    predicate => 'has_anon_builder',
    # init_arg  => '_anon_builder',
);

has anon_builder_installed => (
    traits  => ['Bool'],
    is      => 'ro',
    default => 0,
    handles => {
        _set_anon_builder_installed => 'set',
    },
);

# FIXME Something Odd keeps this from succeeding as we'd like.
#requires 'canonical_builder_prefix';

sub _mxas_builder_name {
    my ($class, $name) = @_;

    return $class->canonical_builder_prefix . $name;
}

!!42;
__END__

=head1 DESCRIPTION

This is a role containing the elements common to both the
L<role attribute trait|MooseX::AttributeShortcuts::Trait::Role::Attribute>
and L<attribute trait|MooseX::AttributeShortcuts::Trait::Attribute>
of L<MooseX::AttributeShortcuts>.

=attr anon_builder

CodeRef, read-only. Stores the code reference that will become the attribute's
builder.  This code reference will be installed in the role or class as a
method, as appropriate.

=method has_anon_builder

Predicate for L</anon_builder>.

=attr anon_builder_installed

Boolean, read-only.  If true, the code reference in L</anon_builder> has been
installed as a method.

=cut
