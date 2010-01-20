#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'EBook::EPUB' ) || print "Bail out!
";
}

diag( "Testing EBook::EPUB $EBook::EPUB::VERSION, Perl $], $^X" );
