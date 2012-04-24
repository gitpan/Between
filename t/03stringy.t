# Test stringy comparisons.

use 5.010;
use strict;
use Test::More tests => 72;
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

my @values = qw( apple banana blackberry blackcurrant blueberry cherry
	damson gooseberry grape orange pear pineapple raspberry redcurrant
	strawberry 1 2 3);

exercise_range_and_equiv(
	between('cherry', 'grape'),
	sub { my $x = shift; return ($x ge 'cherry' && $x le 'grape') },
	\@values,
	);

exercise_range_and_equiv(
	between('cherry', 'grape', EXCLUSIVE_START),
	sub { my $x = shift; return ($x gt 'cherry' && $x le 'grape') },
	\@values,
	);
	
exercise_range_and_equiv(
	between('cherry', 'grape', EXCLUSIVE_END),
	sub { my $x = shift; return ($x ge 'cherry' && $x lt 'grape') },
	\@values,
	);

exercise_range_and_equiv(
	between('cherry', 'grape', EXCLUSIVE_START | EXCLUSIVE_END),
	sub { my $x = shift; return ($x gt 'cherry' && $x lt 'grape') },
	\@values,
	);
