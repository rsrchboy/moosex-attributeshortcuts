use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo  => (is => 'rw', clearer => 1, predicate => -1);
    has _foo => (is => 'rw', clearer => 1, predicate => -1);

    has bar  => (is => 'rw', predicate => 1, clearer => -1);
    has _bar => (is => 'rw', predicate => 1, clearer => -1);
}

use Test::More;
use Test::Moose;

require 't/funcs.pm' unless eval { require funcs };

with_immutable {

    test_class_sanity_checks('TestClass');
    check_attribute('TestClass', foo  => (accessor => 'foo',  clearer   => 'clear_foo',  predicate => '_has_foo'));
    check_attribute('TestClass', _foo => (accessor => '_foo', clearer   => '_clear_foo', predicate => 'has_foo'));
    check_attribute('TestClass', bar  => (accessor => 'bar',  predicate => 'has_bar',    clearer   => '_clear_bar'));
    check_attribute('TestClass', _bar => (accessor => '_bar', predicate => '_has_bar',   clearer   => 'clear_bar'));

} 'TestClass';

done_testing;
