package MooseX::AttributeShortcuts::Simple::Trait::Attribute;

use Moose::Role;
use namespace::autoclean;

with 'MooseX::AttributeShortcuts::Trait::Attribute'
    => { allow_is_lazy => 0 },
    ;

!!42;
