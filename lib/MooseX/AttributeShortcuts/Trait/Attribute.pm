package MooseX::AttributeShortcuts::Trait::Attribute;
use namespace::autoclean;
use MooseX::Role::Parameterized;
use Moose::Util::TypeConstraints  ':all';
use MooseX::Types::Moose          ':all';
use MooseX::Types::Common::String ':all';

use aliased 'MooseX::Meta::TypeConstraint::Mooish' => 'MooishTC';

use List::Util 1.33 'any';

use Package::DeprecationManager -deprecations => {
    'undocumented-isa-constraints' => '0.23',
    'hashref-given-to-coerce'      => '0.24',
};

sub _acquire_isa_tc { goto \&Moose::Util::TypeConstraints::find_or_create_isa_type_constraint }

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
        trigger   => '_trigger_',
        %{ $p->prefixes },
    );

    has anon_builder => (
        reader    => 'anon_builder',
        writer    => '_set_anon_builder',
        isa       => 'CodeRef',
        predicate => 'has_anon_builder',
        init_arg  => '_anon_builder',
    );

    has constraint => (
        is        => 'ro',
        isa       => 'CodeRef',
        predicate => 'has_constraint',
    );

    has original_isa => (
        is        => 'ro',
        predicate => 'has_original_isa',
    );

    # TODO coerce via, transform ?

    # has original_isa, original_coerce ?

    method _mxas_process_options => sub {
        my ($class, $name, $options) = @_;

        my $_has = sub { defined $options->{$_[0]}             };
        my $_opt = sub { $_has->(@_) ? $options->{$_[0]} : q{} };
        my $_ref = sub { ref $_opt->(@_) || q{}                };

        # handle: is => ...
        $class->_mxas_is_rwp($name, $options, $_has, $_opt, $_ref);
        $class->_mxas_is_lazy($name, $options, $_has, $_opt, $_ref);

        # handle: builder => 1, builder => sub { ... }
        $class->_mxas_builder($name, $options, $_has, $_opt, $_ref);

        # handle: isa_class, isa_role, isa_enum
        $class->_mxas_isa_naughty($name, $options, $_has, $_opt, $_ref);

        # handle: isa_instance_of => ...
        $class->_mxas_isa_instance_of($name, $options, $_has, $_opt, $_ref);
        # handle: isa => sub { ... }
        $class->_mxas_isa_mooish($name, $options, $_has, $_opt, $_ref);

        # handle: constraint => ...
        $class->_mxas_constraint($name, $options, $_has, $_opt, $_ref);
        $class->_mxas_coerce($name, $options, $_has, $_opt, $_ref);


        my $is_private = sub { $name =~ /^_/ ? $_[0] : $_[1] };
        my $default_for = sub {
            my ($opt) = @_;

            return unless $_has->($opt);
            my $opt_val = $_opt->($opt);

            my ($head, $mid)
                = $opt_val eq '1'  ? ($is_private->('_', q{}), $is_private->(q{}, '_'))
                : $opt_val eq '-1' ? ($is_private->(q{}, '_'), $is_private->(q{}, '_'))
                :                    return;

            $options->{$opt} = $head . $prefix{$opt} . $mid . $name;
            return;
        };

        ### set our other defaults, if requested...
        $default_for->($_) for qw{ predicate clearer };
        my $trigger = "$prefix{trigger}$name";
        $options->{trigger} = sub { shift->$trigger(@_) }
            if $options->{trigger} && $options->{trigger} eq '1';

        return;
    };

    # here we wrap _process_options() instead of the newer _process_is_option(),
    # as that makes our life easier from a 1.x/2.x compatibility
    # perspective -- and that we're potentially altering more than just
    # the 'is' option at one time.

    before _process_options => sub { shift->_mxas_process_options(@_) };

    # this feels... bad.  But I'm not sure there's any way to ensure we
    # process options on a clone/extends without wrapping new().

    around new => sub {
        my ($orig, $self) = (shift, shift);
        my ($name, %options) = @_;

        $self->_mxas_process_options($name, \%options)
            if $options{__hack_no_process_options};

        return $self->$orig($name, %options);
    };

    # handle: is => 'rwp'
    method _mxas_is_rwp => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_opt->('is') eq 'rwp';

        $options->{is}     = 'ro';
        $options->{writer} = "$wprefix$name";

        return;
    };

    # handle: is => 'lazy'
    method _mxas_is_lazy => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_opt->('is') eq 'lazy';

        $options->{is}       = 'ro';
        $options->{lazy}     = 1;
        $options->{builder}  = 1
            unless $_has->('builder') || $_has->('default');

        return;
    };

    # handle: lazy_build => 'private'
    method _mxas_lazy_build_private => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_opt->('lazy_build') eq 'private';

        $options->{lazy_build} = 1;
        $options->{clearer}    = "_clear_$name";
        $options->{predicate}  = "_has_$name";

        return;
    };

    # handle: isa_class, isa_role, isa_enum
    method _mxas_isa_naughty => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless
            any { exists $options->{$_} } qw{ isa_class isa_role isa_enum };

        # (more than) fair warning...
        deprecated(
            feature => 'undocumented-isa-constraints',
            message => 'Naughty! isa_class, isa_role, and isa_enum will be removed on or after 01 July 2015!',
        );

        # XXX undocumented -- not sure this is a great idea
        $options->{isa} = class_type(delete $options->{isa_class})
            if $_has->('isa_class');
        $options->{isa} = role_type(delete $options->{isa_role})
            if $_has->('isa_role');
        $options->{isa} = enum(delete $options->{isa_enum})
            if $_has->('isa_enum');

        return;
    };

    # handle: builder => 1, builder => sub { ... }
    method _mxas_builder => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_has->('builder');

        if ($_ref->('builder') eq 'CODE') {

            $options->{_anon_builder} = $options->{builder};
            $options->{builder}       = 1;
        }

        $options->{builder} = "$bprefix$name"
            if $options->{builder} eq '1';

        return;
    };

    method _mxas_isa_mooish => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_ref->('isa') eq 'CODE';

        ### build a mooish type constraint...
        $options->{original_isa} = $options->{isa};
        $options->{isa} = MooishTC->new(constraint => $options->{isa});

        return;
    };

    # handle: isa_instance_of => ...
    method _mxas_isa_instance_of => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_has->('isa_instance_of');

        if ($_has->('isa')) {

            $class->throw_error(
                q{Cannot use 'isa_instance_of' and 'isa' together for attribute }
                . $_opt->('definition_context')->{package} . '::' . $name
            );
        }

        $options->{isa} = class_type(delete $options->{isa_instance_of});

        return;
    };

    method _mxas_constraint => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        return unless $_has->('constraint');

        # check for errors...
        $class->throw_error('You must specify an "isa" when declaring a "constraint"')
            if !$_has->('isa');
        $class->throw_error('"constraint" must be a CODE reference')
            if $_ref->('constraint') ne 'CODE';

        # constraint checking! XXX message, etc?
        push my @opts, constraint => $_opt->('constraint')
            if $_ref->('constraint') eq 'CODE';

        # stash our original option away and construct our new one
        my $isa         = $options->{original_isa} = $_opt->('isa');
        $options->{isa} = _acquire_isa_tc($isa)->create_child_type(@opts);

        return;
    };

    method _mxas_coerce => sub {
        my ($class, $name, $options, $_has, $_opt, $_ref) = @_;

        # "fix" the case of the hashref....  *sigh*
        if ($_ref->('coerce') eq 'HASH') {

            deprecated(
                feature => 'hashref-given-to-coerce',
                message => 'Passing a hashref to coerce is unsafe, and will be removed on or after 01 Jan 2015',
            );

            $options->{coerce} = [ %{ $options->{coerce} } ];
        }

        if ($_ref->('coerce') eq 'ARRAY') {

            ### must be type => sub { ... } pairs...
            my @coercions = @{ $_opt->('coerce') };
            confess 'You must specify an "isa" when declaring "coercion"'
                unless $_has->('isa');
            confess 'coercion array must be in pairs!'
                if @coercions % 2;
            confess 'must define at least one coercion pair!'
                unless @coercions > 0;

            my $our_coercion = Moose::Meta::TypeCoercion->new;
            my $our_type
                = $options->{original_isa}
                ? $options->{isa}
                : _acquire_isa_tc($_opt->('isa'))->create_child_type
                ;

            $our_coercion->add_type_coercions(@coercions);
            $our_type->coercion($our_coercion);

            $options->{original_isa} ||= $options->{isa};
            $options->{isa}            = $our_type;
            $options->{coerce}         = 1;

            return;
        }

        # If our original constraint has coercions and our created subtype
        # did not have any (as specified in the 'coerce' option), then
        # copy the parent's coercions over.

        if ($_has->('original_isa') && $_opt->('coerce') eq '1') {

            my $isa_type = _acquire_isa_tc($_opt->('original_isa'));

            if ($isa_type->has_coercion) {

                # create our coercion as a copy of the parent
                $_opt->('isa')->coercion(Moose::Meta::TypeCoercion->new(
                    type_constraint   => $_opt->('isa'),
                    type_coercion_map => [ @{ $isa_type->coercion->type_coercion_map } ],
                ));
            }

        }

        return;
    };

    # we hijack attach_to_class in order to install our anon_builder, if
    # we have one.  Note that we don't go the normal
    # associate_method/install_accessor/etc route as this is kinda...
    # different.

    after attach_to_class => sub {
        my ($self, $class) = @_;

        return unless $self->has_anon_builder;

        $class->add_method($self->builder => $self->anon_builder);
        return;
    };

    method mi               => sub { shift->associated_class->get_meta_instance                     };
    method weaken_value     => sub { $_[0]->mi->weaken_slot_value($_[1] => $_) for $_[0]->slots     };
    method strengthen_value => sub { $_[0]->mi->strengthen_slot_value($_[1] => $_) for $_[0]->slots };

    # NOTE: remove_delegation() will also automagically remove any custom
    # accessors we create here

    around _make_delegation_method => sub {
        my ($orig, $self) = (shift, shift);
        my ($name, $coderef) = @_;

        ### _make_delegation_method() called with a: ref $coderef
        return $self->$orig(@_)
            unless 'CODE' eq ref $coderef;

        # this coderef will be installed as a method on the associated class itself.
        my $custom_coderef = sub {
            # aka $self from the class instance's perspective
            my $associated_class_instance = shift @_;

            # in $coderef, $_ will be the attribute metaclass
            local $_ = $self;
            return $associated_class_instance->$coderef(@_);
        };

        return $self->_process_accessors(custom => { $name => $custom_coderef });
    };

    return;
};

!!42;

__END__

=for :stopwords GitHub attribute's isa one's rwp SUBTYPING foo

=for Pod::Coverage init_meta

=head1 DESCRIPTION

This is the parameterized trait implementing L<MooseX::AttributeShortcuts>.
Look over there for our documentation.

=head1 SEE ALSO

MooseX::AttributeShortcuts

=cut
