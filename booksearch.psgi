use strict;
use warnings;

use BookSearch;

my $app = BookSearch->apply_default_middlewares(BookSearch->psgi_app);
$app;

