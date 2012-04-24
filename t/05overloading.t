# Test that overloading works.

use 5.010;
use strict;
use Test::More tests => 92;
use Between ':all';

my $range = between('cherry', 'grapes', EXCLUSIVE_START);

is("$range", "('cherry', 'grapes']", q(overload q("")));

ok(  'banana' lt $range,  q(overload q(lt) - banana));
ok(  'cherry' lt $range,  q(overload q(lt) - cherry));
ok(!('damson' lt $range), q(overload q(lt) - damson));
ok(!('grapes' lt $range), q(overload q(lt) - grapes));
ok(!('orange' lt $range), q(overload q(lt) - orange));

ok(  'banana' le $range,  q(overload q(le) - banana));
ok(  'cherry' le $range,  q(overload q(le) - cherry));
ok(  'damson' le $range,  q(overload q(le) - damson));
ok(  'grapes' le $range,  q(overload q(le) - grapes));
ok(!('orange' le $range), q(overload q(le) - orange));

ok(!('banana' eq $range), q(overload q(eq) - banana));
ok(!('cherry' eq $range), q(overload q(eq) - cherry));
ok(  'damson' eq $range,  q(overload q(eq) - damson));
ok(  'grapes' eq $range,  q(overload q(eq) - grapes));
ok(!('orange' eq $range), q(overload q(eq) - orange));

ok(  'banana' ne $range,  q(overload q(ne) - banana));
ok(  'cherry' ne $range,  q(overload q(ne) - cherry));
ok(!('damson' ne $range), q(overload q(ne) - damson));
ok(!('grapes' ne $range), q(overload q(ne) - grapes));
ok(  'orange' ne $range,  q(overload q(ne) - orange));

ok(!('banana' gt $range), q(overload q(gt) - banana));
ok(!('cherry' gt $range), q(overload q(gt) - cherry));
ok(!('damson' gt $range), q(overload q(gt) - damson));
ok(!('grapes' gt $range), q(overload q(gt) - grapes));
ok(  'orange' gt $range,  q(overload q(gt) - orange));

ok(!('banana' ge $range), q(overload q(ge) - banana));
ok(!('cherry' ge $range), q(overload q(ge) - cherry));
ok(  'damson' ge $range,  q(overload q(ge) - damson));
ok(  'grapes' ge $range,  q(overload q(ge) - grapes));
ok(  'orange' ge $range,  q(overload q(ge) - orange));

ok(!('banana' ~~ $range), q(overload q(~~) - banana));
ok(!('cherry' ~~ $range), q(overload q(~~) - cherry));
ok(  'damson' ~~ $range,  q(overload q(~~) - damson));
ok(  'grapes' ~~ $range,  q(overload q(~~) - grapes));
ok(!('orange' ~~ $range), q(overload q(~~) - orange));

is('banana' cmp $range, -1, q(overload q(cmp) - banana));
is('cherry' cmp $range, -1, q(overload q(cmp) - cherry));
is('damson' cmp $range,  0, q(overload q(cmp) - damson));
is('grapes' cmp $range,  0, q(overload q(cmp) - grapes));
is('orange' cmp $range, +1, q(overload q(cmp) - orange));

is($range cmp 'banana', +1, q(overload q(cmp) - banana, swapped));
is($range cmp 'cherry', +1, q(overload q(cmp) - cherry, swapped));
is($range cmp 'damson',  0, q(overload q(cmp) - damson, swapped));
is($range cmp 'grapes',  0, q(overload q(cmp) - grapes, swapped));
is($range cmp 'orange', -1, q(overload q(cmp) - orange, swapped));

$range = between(2, 4, EXCLUSIVE_START);

is("$range", "(2, 4]", q(overload q("")));

ok(   1 < $range,  q(overload q(<) -  1));
ok(   2 < $range,  q(overload q(<) -  2));
ok(!( 3 < $range), q(overload q(<) -  3));
ok(!( 4 < $range), q(overload q(<) -  4));
ok(!(20 < $range), q(overload q(<) - 20));

ok(   1 <= $range,  q(overload q(<=) -  1));
ok(   2 <= $range,  q(overload q(<=) -  2));
ok(   3 <= $range,  q(overload q(<=) -  3));
ok(   4 <= $range,  q(overload q(<=) -  4));
ok(!(20 <= $range), q(overload q(<=) - 20));

ok(!( 1 == $range), q(overload q(==) -  1));
ok(!( 2 == $range), q(overload q(==) -  2));
ok(   3 == $range,  q(overload q(==) -  3));
ok(   4 == $range,  q(overload q(==) -  4));
ok(!(20 == $range), q(overload q(==) - 20));

ok(   1 != $range,  q(overload q(!=) -  1));
ok(   2 != $range,  q(overload q(!=) -  2));
ok(!( 3 != $range), q(overload q(!=) -  3));
ok(!( 4 != $range), q(overload q(!=) -  4));
ok(  20 != $range,  q(overload q(!=) - 20));

ok(!( 1 > $range), q(overload q(>) -  1));
ok(!( 2 > $range), q(overload q(>) -  2));
ok(!( 3 > $range), q(overload q(>) -  3));
ok(!( 4 > $range), q(overload q(>) -  4));
ok(  20 > $range,  q(overload q(>) - 20));

ok(!( 1 >= $range), q(overload q(>=) -  1));
ok(!( 2 >= $range), q(overload q(>=) -  2));
ok(   3 >= $range,  q(overload q(>=) -  3));
ok(   4 >= $range,  q(overload q(>=) -  4));
ok(  20 >= $range,  q(overload q(>=) - 20));

ok(!( 1 ~~ $range), q(overload q(~~) -  1));
ok(!( 2 ~~ $range), q(overload q(~~) -  2));
ok(   3 ~~ $range,  q(overload q(~~) -  3));
ok(   4 ~~ $range,  q(overload q(~~) -  4));
ok(!(20 ~~ $range), q(overload q(~~) - 20));

is( 1 <=> $range, -1, q(overload q(<=>) -  1));
is( 2 <=> $range, -1, q(overload q(<=>) -  2));
is( 3 <=> $range,  0, q(overload q(<=>) -  3));
is( 4 <=> $range,  0, q(overload q(<=>) -  4));
is(20 <=> $range, +1, q(overload q(<=>) - 20));

is($range <=>  1, +1, q(overload q(<=>) -  1, swapped));
is($range <=>  2, +1, q(overload q(<=>) -  2, swapped));
is($range <=>  3,  0, q(overload q(<=>) -  3, swapped));
is($range <=>  4,  0, q(overload q(<=>) -  4, swapped));
is($range <=> 20, -1, q(overload q(<=>) - 20, swapped));
