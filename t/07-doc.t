use strict;
use warnings;

{
    package TestClass;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts;

    has foo  => (is => 'rw', documentation => 'foo doc string');
    has bar  => (is => 'rw', doc           => 'bar doc string');
}

use Test::More;
use Test::Moose;

require 't/funcs.pm' unless eval { require funcs };

with_immutable {

    test_class_sanity_checks('TestClass');
    check_attribute('TestClass', $_  => (accessor => $_,  documentation => "$_ doc string"))
        for qw{ foo bar };

} 'TestClass';

done_testing;
