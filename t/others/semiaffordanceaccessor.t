use strict;
use warnings;

use Test::More;
use Test::Moose::More;

use Test::Requires {
    'MooseX::SemiAffordanceAccessor' => 0,
};

{
    package AAA;
    use Moose;
    use MooseX::AttributeShortcuts;
    use MooseX::SemiAffordanceAccessor;

    has rw  => (is => 'rw');
    has rwp => (is => 'rwp');
    has _pvt_rw  => (is => 'rw');
    has _pvt_rwp => (is => 'rwp');
}

validate_class AAA => (
    attributes => [ qw{ rw rwp _pvt_rw _pvt_rwp } ],
    methods => [ qw{ rw set_rw rwp _set_rwp _pvt_rw _set_pvt_rw _pvt_rwp _set_pvt_rwp } ],
);

done_testing;
