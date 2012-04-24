use 5.010;
use lib "../lib";
use Between;

say(55 ~~ between 3, 6, 'cmp');

say (between(3,5)->cmp(1));