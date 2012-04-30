use strict;
use warnings;

use Test::More;
use Test::Fatal;

use MooseX::AttributeShortcuts ();

{ package TestClass; }

is exception
    { MooseX::AttributeShortcuts->init_meta(for_class => 'foo') },
    undef,
    'init_meta() handles the no-metaclass case',
    ;

done_testing;
