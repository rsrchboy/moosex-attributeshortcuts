package MooseX::AttributeShortcuts::Simple;

# ABSTRACT: Shorthand for common attribute options

use strict;
use warnings;

use namespace::autoclean;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

my $base_trait = 'MooseX::AttributeShortcuts::Trait::Attribute';
my $trait      = 'MooseX::AttributeShortcuts::Simple::Trait::Attribute';

Moose::Exporter->setup_import_methods(
    trait_aliases => [
        [ $base_trait => 'Shortcuts'       ],
        [ $trait      => 'SimpleShortcuts' ],
    ],
    class_metaroles => {
        attribute => [ $trait ], 
    },
    role_metaroles => {
        applied_attribute => [ $trait ],
    },
);

!!42;
