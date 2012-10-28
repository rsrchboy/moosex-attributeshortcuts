use Test::More;
use Test::Fatal;

{
	package TestClass1;
	use Moose;
	use namespace::autoclean;
	use MooseX::AttributeShortcuts;
	use MooseX::Types::Moose qw(Num Str Any Undef);
	
	has short_string => (
		is      => 'rw',
		isa     => sub { length($_) <= 5 },
	);
	
	has coerced_short_string => (
		is      => 'rw',
		isa     => sub { length($_) <= 5 },
		coerce  => sub { substr($_, 0, 4) },
	);
	
	has num => (
		is      => 'rw',
		isa     => 'Num',
		coerce  => sub { length("$_") },
	);
	
	has num2 => (
		is      => 'rw',
		isa     => Num,
		coerce  => sub { length("$_") },
	);
	
	has num3 => (
		is      => 'rw',
		isa     => Num,
		coerce  => [
			Str   => sub { length("$_") },
			Undef => sub { -1 },
			Any   => sub { length("$_") },
		],
	);
	
	has num4 => (
		is      => 'rw',
		isa     => Num,
		coerce  => {
			Str   => sub { length("$_") },
			Undef => sub { -1 },
			Any   => sub { no warnings; length("$_") },
		},
	);
	
	has num5 => (
		is      => 'rw',
		isa     => Num,
		coerce  => [
			Str   , sub { length("$_") },
			Undef , sub { -1 },
			Any   , sub { length("$_") },
		],
	);
}

my $o = TestClass1->new;
isa_ok($o, 'Moose::Object');

$o->short_string('Foo');
is($o->short_string, 'Foo', 'attribute works');

ok(!eval {
	$o->short_string('Foolish'); 1
}, 'value not meeting constraint dies');

is($o->short_string, 'Foo', 'attribute unchanged');

$o->coerced_short_string('Fools');
is($o->coerced_short_string, 'Fools', 'attribute with coercion works');
$o->coerced_short_string('Foolish');
is($o->coerced_short_string, 'Fool', 'attribute with coercion coerces');

$o->num('Fools');
is($o->num, 5, 'attribute with standard Moose type but coercion code');

$o->num2('Foolish');
is($o->num2, 7, 'attribute with MooseX::Types type but coercion code');

$o->num3('Foolish');
is($o->num3, 7, 'attribute with arrayref coercions - from Str');

$o->num3(undef);
is($o->num3, -1, 'attribute with arrayref coercions - from Undef');

$o->num4('Foolish');
is($o->num4, 7, 'attribute with hashref coercions - from Str');

# Note that "Any" beats "Undef" in the hashref!
$o->num4(undef);
is($o->num4, 0, 'attribute with hashref coercions - from Undef');

$o->num5('Foolish');
is($o->num5, 7, 'attribute with arrayref coercions and MooseX::Types - from Str');

$o->num5(undef);
is($o->num5, -1, 'attribute with arrayref coercions and MooseX::Types - from Undef');



{
	package TestClass2;
	use Moose;
	use namespace::autoclean;
	use MooseX::AttributeShortcuts;
	
	::like(
		::exception {
			has short_string => (
				is      => 'rw',
				isa     => sub { length($_) <= 5 },
				coerce  => 1,
			)
		},
		qr'cannot use isa=>CODE and coerce=>1',
		q 'cannot use isa=>CODE and coerce=>1',
	);
};

done_testing();

