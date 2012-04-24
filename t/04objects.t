# Test comparisons with overloaded objects.

use 5.010;
use strict;
use Test::More;
use Between ':all';

eval { require DateTime; 1 }
	or plan skip_all => 'need DateTime.pm to run this test file';

plan tests => 28;

sub exercise_range_and_equiv
{
	my ($range, $equiv, $values) = @_;
	my $rangestr = "$range";
	
	foreach my $value (@$values)
	{
		my $actual   = !! ($value ~~ $range);
		my $expected = !! ($value ~~ $equiv);
			
		is(
			$actual,
			$expected,
			sprintf("%s ~~ %s", $value, $rangestr),
			);
	}
}

my @values = map
	{ /(\d{4})-(\d{2})-(\d{2})/; DateTime->new(year => $1, month => $2, day => $3) }
	qw( 1949-08-04 1980-06-01 1981-06-07 1983-01-09 1986-09-07 2009-02-12 2010-10-24 );
my ($S, $E) = @values[1,4];

exercise_range_and_equiv(
	between($S, $E),
	sub { my $x = shift; return ($x >= $S && $x <= $E) },
	\@values,
	);

exercise_range_and_equiv(
	between($S, $E, EXCLUSIVE_START),
	sub { my $x = shift; return ($x > $S && $x <= $E) },
	\@values,
	);
	
exercise_range_and_equiv(
	between($S, $E, EXCLUSIVE_END),
	sub { my $x = shift; return ($x >= $S && $x < $E) },
	\@values,
	);

exercise_range_and_equiv(
	between($S, $E, EXCLUSIVE_START | EXCLUSIVE_END),
	sub { my $x = shift; return ($x > $S && $x < $E) },
	\@values,
	);
