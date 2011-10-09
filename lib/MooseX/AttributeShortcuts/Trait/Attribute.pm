package MooseX::AttributeShortcuts::Trait::Attribute;
use namespace::autoclean;
use MooseX::Role::Parameterized;

use MooseX::Types::Moose          ':all';
use MooseX::Types::Common::String ':all';

parameter writer_prefix  => (isa => NonEmptySimpleStr, default => '_set_');
parameter builder_prefix => (isa => NonEmptySimpleStr, default => '_build_');

parameter allow_is_lazy  => (isa => Bool, default => 1);

# I'm not going to document the following for the moment, as I'm not sure I
# want to do it this way.
parameter prefixes => (
    isa     => HashRef[NonEmptySimpleStr],
    default => sub { { } },
);

role {
    my $p = shift @_;

    my $wprefix = $p->writer_prefix;
    my $bprefix = $p->builder_prefix;
    my %prefix = (
        predicate => 'has',
        clearer   => 'clear',
        %{ $p->prefixes },
    );
    my $allow_is_lazy = $p->allow_is_lazy;

    my $_process_options = sub {
        my ($class, $name, $options) = @_;

        if ($options->{is}) {

            if ($options->{is} eq 'rwp') {

                $options->{is}     = 'ro';
                $options->{writer} = "$wprefix$name";
            }

            if ($allow_is_lazy && $options->{is} eq 'lazy') {

                $options->{is}       = 'ro';
                $options->{lazy}     = 1;
                $options->{builder}  = 1     unless exists $options->{builder};
                $options->{init_arg} = undef unless exists $options->{init_arg};
            }
        }

        if ($options->{lazy_build} && $options->{lazy_build} eq 'private') {

            $options->{lazy_build} = 1;
            $options->{clearer}    = "_clear_$name";
            $options->{predicate}  = "_has_$name";
            $options->{init_arg}   = "_$name" unless exists $options->{init_arg};
        }

        my $is_private = sub { $name =~ /^_/ ? $_[0] : $_[1] };
        my $default_for = sub {
            my ($opt) = @_;

            if ($options->{$opt} && $options->{$opt} eq '1') {
                $options->{$opt} =
                    $is_private->('_', q{}) .
                    $prefix{$opt} .
                    $is_private->(q{}, '_') .
                    $name;
            }
            return;
        };

        ### set our other defaults, if requested...
        $default_for->($_) for qw{ predicate clearer };
        $options->{builder} = "$bprefix$name"
            if $options->{builder} && $options->{builder} eq '1';

        return;
    };

    # here we wrap _process_options() instead of the newer _process_is_option(),
    # as that makes our life easier from a 1.x/2.x compatibility perspective.

    before _process_options => $_process_options;

    # this feels... bad.  But I'm not sure there's any way to ensure we
    # process options on a clone/extends without wrapping new().

    around new => sub {
        my ($orig, $self) = (shift, shift);
        my ($name, %options) = @_;

        $self->$_process_options($name, \%options)
            if $options{__hack_no_process_options};

        return $self->$orig($name, %options);
    };
};

!!42;
