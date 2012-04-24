# Test module loads correctly and provides the expected API.

use Test::More tests => 8;

BEGIN { use_ok('Between') };

isa_ok Between => qw(Exporter);
can_ok Between => qw(between);
can_ok Between => $_
	for qw(EXCLUSIVE_START EXCLUSIVE_END CMP_NUMERIC CMP_STRING CMP_AUTO);
