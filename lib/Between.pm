package Between;

use 5.010;
use strict;
use warnings;
use utf8;

use constant {
	EXCLUSIVE_START  => 0x01,
	EXCLUSIVE_END    => 0x02,
};

use constant {
	CMP_NUMERIC      => '<=>',
	CMP_STRING       => 'cmp',
	CMP_AUTO         => undef,
};

use overload (
	q[~~]        => 'match',
	q[""]        => 'to_string',
	q[cmp]       => 'cmp_string',
	q[<=>]       => 'cmp_numeric',
	fallback     => 1,
);

BEGIN {
	$Between::AUTHORITY = 'cpan:TOBYINK';
	$Between::VERSION   = '0.001';
	@Between::EXPORT    = qw(between);
	@Between::EXPORT_OK = qw(between EXCLUSIVE_START EXCLUSIVE_END
	                         CMP_NUMERIC CMP_STRING CMP_AUTO);
	%Between::EXPORT_TAGS = (
		'standard'   => \@Between::EXPORT,
		'default'    => \@Between::EXPORT,
		'all'        => \@Between::EXPORT_OK,
		'constants'  => [qw(EXCLUSIVE_START EXCLUSIVE_END
		                    CMP_NUMERIC CMP_STRING CMP_AUTO)]
		);
}

use base 'Exporter';

use Carp qw(croak confess);
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);

sub between ($$;$$)
{
	unshift @_, __PACKAGE__;
	goto \&new;
}

sub new
{
	my ($class, $start, $end, $exclusive, $type) = @_;
	bless [$start => $end, $exclusive, _type_ok($type)] => $class
}

sub _type_ok
{
	return unless defined(my $type = $_[0]);
	croak "Comparison type should be 'cmp' or '<=>'"
		unless $type ~~ [CMP_NUMERIC, CMP_STRING];
	$type
}

sub start :lvalue
{
	$_[0][0]
}

sub end :lvalue
{
	$_[0][1]
}

sub type :lvalue
{
	$_[0][3] //= _type_ok($_[0]->_auto_detect_type);
	$_[0][3]
}

sub _auto_detect_type
{
	my $self = shift;
	
	if (looks_like_number($self->start) || overload::Method($self->start, '<=>')
	and looks_like_number($self->end)   || overload::Method($self->end,   '<=>'))
	{
		return CMP_NUMERIC
	}
	
	return CMP_STRING
}

sub start_is_exclusive
{
	no warnings;
	$_[0][2] & EXCLUSIVE_START
}

sub end_is_exclusive
{
	no warnings;
	$_[0][2] & EXCLUSIVE_END
}

sub to_string
{
	my $self = shift;
	sprintf(
		'%s%s, %s%s',
		$self->start_is_exclusive ? '(' : '[',
		$self->_display_value($self->start),
		$self->_display_value($self->end),
		$self->end_is_exclusive ? ')' : ']',
		)
}

sub _display_value
{
	local $Data::Dumper::Indent = 0;
	local $Data::Dumper::Useqq  = 0;
	local $Data::Dumper::Terse  = 1;
	Dumper($_[1])
}

sub match
{
	my ($x, $y) = @_;
	not $x->cmp($y)
}

sub cmp
{
	my ($self) = @_;
	goto $self->type eq CMP_NUMERIC ? \&cmp_numeric : \&cmp_string
}

sub cmp_numeric
{
	my ($self, $other, $swap) = @_;
	
	if ( $other < $self->start
	or  ($other == $self->start and $self->start_is_exclusive) )
	{
		return ($swap ? -1 : 1)
	}

	if ( $other > $self->end
	or  ($other == $self->end and $self->end_is_exclusive) )
	{
		return ($swap ? 1 : -1)
	}
	
	return 0
}

sub cmp_string
{
	my ($self, $other, $swap) = @_;
	
	if ( $other lt $self->start
	or  ($other eq $self->start and $self->start_is_exclusive) )
	{
		return ($swap ? -1 : 1)
	}

	if ( $other gt $self->end
	or  ($other eq $self->end and $self->end_is_exclusive) )
	{
		return ($swap ? 1 : -1)
	}
	
	return 0
}

__PACKAGE__
__END__

=head1 NAME

Between - simple range objects for smart matching

=head1 SYNOPSIS

 use Between;
 use Math::Trig qw(pi);
 
 if ( pi ~~between(3,4) ) {
    say "This is to be expected.";
 }

=head1 DESCRIPTION

This module is designed to make common range-testing constructions
a little bit easier. Instead of this:

 if (18 <= $person->age and $person->age <= 70) {
    ...
 }

You would write this:

 if ( $person->age ~~between(18,70) ) {
    ...
 }

The latter is more readable, and in some cases (if the C<age> method
call were computationally expensive) more efficient.

=head2 Functional Interface

=over

=item C<< between($start, $end) >>

This is a shortcut for the constructor (see the section below
describing the object-oriented interface).

=back

=head2 Object-Oriented Interface

=over

=item C<< Between->new($start, $end) >>

Creates a new Between object, representing a range between C<$start>
and C<$end> (inclusive).

A third argument is allowed, a number interpreted as bit flags, which
allows C<$start> and C<$end> to be treated exclusively instead of
inclusively.

 $range = Between->new(0, 1, EXCLUSIVE_START);
 $range = Between->new(0, 1, EXCLUSIVE_START | EXCLUSIVE_END);

A fourth parameter may be provided, indicating if numeric or string
comparisons should be used. By default, the comparison type is guessed.

 $range = Between->new(0, 1, undef, '<=>');  # numeric
 $range = Between->new(0, 1, undef, 'cmp');  # string

=item C<< start >>

This method returns the start of the range.

=item C<< end >>

This method returns the end of the range.

=item C<< start_is_exclusive >>

This method returns true iff the start of the range is exclusive.

=item C<< end_is_exclusive >>

This method returns true iff the end of the range is exclusive.

=item C<< type >>

The (possibly automatically detected) comparison type. Either 'cmp'
or '<=>'.

=item C<< to_string >>

A printable string representation for this range.

=item C<< cmp >>

Equivalent to the Perl C<cmp> operator.

  $range->cmp($value)

will return 1 if C<$value> is less than C<< $range->start >>; return
0 if C<$value> is within the range; and return -1 if <$value> is
greater than C<< $range->end >>. It takes into account the
inclusive/exclusive flags.

=item C<< cmp_numeric >>

Like C<cmp>, but always does numeric comparison.

=item C<< cmp_string >>

Like C<cmp>, but always does string comparison.

=item C<< match >>

Returns a boolean opposite to C<cmp>. That is, the following returns
true if and only if C<$value> is within the range:

  $range->match($value)

=back

=head2 Constants

=over

=item * B<EXCLUSIVE_START>  C<0x01>

=item * B<EXCLUSIVE_END>  C<0x02>

=item * B<CMP_NUMERIC>  C<< '<=>' >>

=item * B<CMP_STRING>  C<< 'cmp' >>

=item * B<CMP_AUTO>  C<< undef >>

=back

Constants are not exported by default, but can be exported using the
':constants' or ':all' export tags.

 use Between qw(:constants);

=head2 Overloading

The Between module overloads the following operations:

=over

=item * C<< ~~ >> (smart match) via C<match>.

=item * C<< "" >> (stringification) via C<to_string>.

=item * C<< cmp >> (string comparison), C<< lt >>, C<< gt >>, C<< le >>, C<< ge >>, C<< eq >>, C<< ne >> via C<cmp_string>.

=item * C<< <=> >> (numeric comparison), C<< < >>, C<< > >>, C<< <= >>, C<< >= >>, C<< == >>, C<< != >> via C<cmp_numeric>.

=back

=head2 Export

The following export tags are defined:

=over

=item * C<< :standard >> - exports the C<between> function only.

=item * C<< :constants >> - exports C<EXCLUSIVE_START>, C<EXCLUSIVE_END>,
C<CMP_NUMERIC>, C<CMP_STRING> and C<CMP_AUTO>.

=item * C<< :all >> - combines C<< :standard >> and C<< :constants >>.

=back

By default, the C<< :standard >> tag is exported.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Between>.

=head1 SEE ALSO

L<Object::Range>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

