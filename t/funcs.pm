
sub test_class {
    my $classname      = shift @_;
    my $writer_prefix  = shift @_ || '_';
    my $builder_prefix = shift @_ || '_build_';

    # sanity checks
    meta_ok($classname);
    has_attribute_ok($classname, $_) for qw{ foo bar baz };
    does_ok(
        $classname->meta->attribute_metaclass,
        'MooseX::AttributeShortcuts::Trait::Attribute',
    );

    my $meta = $classname->meta;
    my ($foo, $bar, $baz) = map { $meta->get_attribute($_) } qw{ foo bar baz };

    is($_->reader, $_->name, $_->name . ': reader => correct') for $foo, $bar, $baz;
    is($_->writer, $writer_prefix . $_->name, $_->name . ': writer => correct') for $foo, $baz;
    is($_->writer, undef, $_->name . ': writer => correct (undef)') for $bar;
    is($_->builder, undef, $_->name . ': builder => correct (undef)') for $foo;
    is($_->accessor, undef, $_->name . ': accessor => correct (undef)') for $foo, $bar, $baz;
    is($_->builder, $builder_prefix . $_->name, $_->name . ': builder => correct') for $bar, $baz;
}

1;
