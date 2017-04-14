package MooseX::AttributeShortcuts::Trait::Attribute::HasAnonBuilder;

# ABSTRACT: Attributes, etc, common to both the role-attribute and attribute traits

use Moose::Role;
use namespace::autoclean 0.24;

has anon_builder => (
    reader    => 'anon_builder',
    writer    => '_set_anon_builder',
    isa       => 'CodeRef',
    predicate => 'has_anon_builder',
    init_arg  => '_anon_builder',
);

!!42;
