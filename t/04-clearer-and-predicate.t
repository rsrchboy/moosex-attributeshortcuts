use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo  => (is => 'rw', clearer => 1);
    has _foo => (is => 'rw', clearer => 1);

    has bar  => (is => 'rw', predicate => 1);
    has _bar => (is => 'rw', predicate => 1);
}

use Test::More;
use Test::Moose;

require 't/funcs.pm' unless eval { require funcs };

test_class_sanity_checks('TestClass');
check_attribute('TestClass', foo  => (accessor => 'foo',  clearer   => 'clear_foo'));
check_attribute('TestClass', _foo => (accessor => '_foo', clearer   => '_clear_foo'));
check_attribute('TestClass', bar  => (accessor => 'bar',  predicate => 'has_bar'));
check_attribute('TestClass', _bar => (accessor => '_bar', predicate => '_has_bar'));

done_testing;
