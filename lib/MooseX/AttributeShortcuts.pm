package MooseX::AttributeShortcuts;

# ABSTRACT: Shorthand for common attribute options

use strict;
use warnings;

use namespace::autoclean;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

{
    package MooseX::AttributeShortcuts::Trait::Attribute;
    use namespace::autoclean;
    use MooseX::Role::Parameterized;

    use MooseX::Types::Moose          ':all';
    use MooseX::Types::Common::String ':all';

    parameter writer_prefix  => (isa => NonEmptySimpleStr, default => '_set_');
    parameter builder_prefix => (isa => NonEmptySimpleStr, default => '_build_');

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

        my $_process_options = sub {
            my ($class, $name, $options) = @_;

            if ($options->{is}) {

                if ($options->{is} eq 'rwp') {

                    $options->{is}     = 'ro';
                    $options->{writer} = "$wprefix$name";
                }

                if ($options->{is} eq 'lazy') {

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

        around clone_and_inherit_options => sub {
            my ($orig, $self) = (shift, shift);

            my %options = @_;
            $self->$_process_options($self->name, \%options);
            return $self->$orig(%options);
        };
    };
}

Moose::Exporter->setup_import_methods;
my ($import) = Moose::Exporter->build_import_methods(
    trait_aliases => [
        [ 'MooseX::AttributeShortcuts::Trait::Attribute' => 'Shortcuts' ],
    ],
);

my $role_params;

sub import {
    my ($class, %args) = @_;

    $role_params = {};
    do { $role_params->{$_} = delete $args{"-$_"} if exists $args{"-$_"} }
        for qw{ writer_prefix builder_prefix prefixes };

    @_ = ($class, %args);
    goto &$import;
}

sub init_meta {
    shift;
    my %args = @_;
    my $params = delete $args{role_params} || $role_params || {};
    undef $role_params;

    Moose::Util::MetaRole::apply_metaroles(
        for => $args{for_class},
        class_metaroles => {
            attribute => [ 'MooseX::AttributeShortcuts::Trait::Attribute' => $params ],
        },
    );

    return $args{for_class}->meta;
}

1;

__END__

=head1 SYNOPSIS

    package Some::Class;

    use Moose;
    use MooseX::AttributeShortcuts;

    # same as: is => 'ro', writer => '_set_foo'
    has foo => (is => 'rwp');

    # same as: is => 'ro', builder => '_build_bar'
    has bar => (is => 'ro', builder => 1);

    # same as: is => 'ro', clearer => 'clear_bar'
    has bar => (is => 'ro', clearer => 1);

    # same as: is => 'ro', predicate => 'has_bar'
    has bar => (is => 'ro', predicate => 1);

    # works as you'd expect for "private": predicate => '_has_bar'
    has _bar => (is => 'ro', predicate => 1);

    # or...
    package Some::Other::Class;

    use Moose;
    use MooseX::AttributeShortcuts -writer_prefix => '_';

    # same as: is => 'ro', writer => '_foo'
    has foo => (is => 'rwp');

=head1 DESCRIPTION

Ever find yourself repeatedly specifing writers and builders, because there's
no good shortcut to specifying them?  Sometimes you want an attribute to have
a read-only public interface, but a private writer.  And wouldn't it be easier
to just say "builder => 1" and have the attribute construct the canonical
"_build_$name" builder name for you?

This package causes an attribute trait to be applied to all attributes defined
to the using class.  This trait extends the attribute option processing to
handle the above variations.

=head1 USAGE

We accept two parameters on the use of this module; they impact how builders
and writers are named.

=head2 -writer_prefix

    use MooseX::::AttributeShortcuts -writer_prefix => 'prefix';

The default writer prefix is '_set_'.  If you'd prefer it to be something
else (say, '_'), this is where you'd do that.

B<NOTE:> If you're using 0.001, this is a change.  Sorry about that :\

=head2 -builder_prefix

    use MooseX::::AttributeShortcuts -builder_prefix => 'prefix';

The default builder prefix is '_build_', as this is what lazy_build does, and
what people in general recognize as build methods.

=head1 NEW ATTRIBUTE OPTIONS

Unless specified here, all options defined by L<Moose::Meta::Attribute> and
L<Class::MOP::Attribute> remain unchanged.

Want to see additional options?  Ask, or better yet, fork on GitHub and send
a pull request.

For the following, "$name" should be read as the attribute name; and the
various prefixes should be read using the defaults.

=head2 is => 'rwp'

Specifing is => 'rwp' will cause the following options to be set:

    is     => 'ro'
    writer => "_set_$name"

=head2 is => 'lazy'

Specifing is => 'lazy' will cause the following options to be set:

    is       => 'ro'
    builder  => "_build_$name"
    init_arg => undef
    lazy     => 1

=head2 builder => 1

Specifying builder => 1 will cause the following options to be set:

    builder => "_build_$name"

=head2 clearer => 1

Specifying clearer => 1 will cause the following options to be set:

    clearer => "clear_$name"

or, if your attribute name begins with an underscore:

    clearer => "_clear$name"

(that is, an attribute named "_foo" would get "_clear_foo")

=head2 predicate => 1

Specifying predicate => 1 will cause the following options to be set:

    predicate => "has_$name"

or, if your attribute name begins with an underscore:

    predicate => "_has$name"

(that is, an attribute named "_foo" would get "_has_foo")

=for Pod::Coverage init_meta

=head1 BUGS

All complex software has bugs lurking in it, and this module is no exception.

Please report any bugs to "bug-moosex-attributeshortcuts@rt.cpan.org", or
through the web interface at <http://rt.cpan.org>.

