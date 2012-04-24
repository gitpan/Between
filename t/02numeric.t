# Test numeric comparisons.

use 5.010;
use strict;
use Test::More tests => 400;
use Between ':all';

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

my @values = map { $_ / 10.0 } 0 .. 98, 445;

exercise_range_and_equiv(
	between(2, 5),
	sub { my $x = shift; return ($x >=2 && $x <= 5) },
	\@values,
	);

exercise_range_and_equiv(
	between(2, 5, EXCLUSIVE_START),
	sub { my $x = shift; return ($x >2 && $x <= 5) },
	\@values,
	);
	
exercise_range_and_equiv(
	between(2, 5, EXCLUSIVE_END),
	sub { my $x = shift; return ($x >=2 && $x < 5) },
	\@values,
	);

exercise_range_and_equiv(
	between(2, 5, EXCLUSIVE_START | EXCLUSIVE_END),
	sub { my $x = shift; return ($x >2 && $x < 5) },
	\@values,
	);
