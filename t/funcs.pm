
use constant Shortcuts => 'MooseX::AttributeShortcuts::Trait::Attribute';

sub test_class {
    my $classname      = shift @_;
    my $writer_prefix  = shift @_ || '_set_';
    my $builder_prefix = shift @_ || '_build_';

    test_class_sanity_checks($classname, qw{ foo bar baz });

    my $meta = $classname->meta;
    my ($foo, $bar, $baz) = map { $meta->get_attribute($_) } qw{ foo bar baz };

    is($_->reader, $_->name, $_->name . ': reader => correct') for $foo, $bar, $baz;
    is($_->writer, $writer_prefix . $_->name, $_->name . ': writer => correct') for $foo, $baz;
    is($_->writer, undef, $_->name . ': writer => correct (undef)') for $bar;
    is($_->builder, undef, $_->name . ': builder => correct (undef)') for $foo;
    is($_->accessor, undef, $_->name . ': accessor => correct (undef)') for $foo, $bar, $baz;
    is($_->builder, $builder_prefix . $_->name, $_->name . ': builder => correct') for $bar, $baz;
}

sub test_class_sanity_checks {
    my ($classname, @attributes) = @_;

    # sanity checks
    meta_ok($classname);
    does_ok(
        $classname->meta->attribute_metaclass,
        'MooseX::AttributeShortcuts::Trait::Attribute',
    );
    has_attribute_ok($classname, $_) for @attributes;
    ok($classname->meta->get_attribute($_)->does(Shortcuts), "does role: $_")
        for @attributes;

    return;
}

sub check_attribute {
    my ($class, $name, %accessors) = @_;

    has_attribute_ok($class, $name);
    my $att = $class->meta->get_attribute($name);

    my $check = sub {
        my $has = "has_$_";
        ok($att->$has, "$name has $_");
        is($att->$_, $accessors{$_}, "$name: $_ correct")
    };

    $check->() for grep { ! /(init_arg|lazy)/ } keys %accessors;

    if (exists $accessors{init_arg}) {

        if ($accessors{init_arg}) {
            local $_ = $accessors{init_arg};
            $check->();
        }
        else {

            ok(!$att->has_init_arg, "$name has no init_arg");
        }
    }

    if (exists $accessors{lazy} && $accessors{lazy}) {

        ok($att->is_lazy, "$name is lazy");
    }
    elsif (exists $accessors{lazy} && !$accessors{lazy}) {

        is(!$att->is_lazy, "$name is not lazy");
    }

    return;
}

1;
