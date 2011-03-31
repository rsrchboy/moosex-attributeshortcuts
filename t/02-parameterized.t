use strict;
use warnings;

{
    package TestClass::WriterPrefix;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts -writer_prefix => '_set_';

    has foo => (is => 'rwp');
    has bar => (is => 'ro', builder => 1);
    has baz => (is => 'rwp', builder => 1);

}
{
    package TestClass::BuilderPrefix;

    use Moose;
    use namespace::autoclean;
    use MooseX::AttributeShortcuts -builder_prefix => '_silly_';

    has foo => (is => 'rwp');
    has bar => (is => 'ro', builder => 1);
    has baz => (is => 'rwp', builder => 1);

}

use Test::More;
use Test::Moose;

require 't/funcs.pm' unless eval { require funcs };

test_class('TestClass::WriterPrefix', '_set_');
test_class('TestClass::BuilderPrefix', undef, '_silly_');

done_testing;

