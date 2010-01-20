#!perl -T

use Test::More tests => 14;

BEGIN {
    use_ok( 'EBook::EPUB' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Container' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Container::Zip' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Manifest' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Manifest::Item' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Guide' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Guide::Reference' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Spine' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Spine::Itemref' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Metadata' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Metadata::Item' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::Metadata::DCItem' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::NCX' ) || print "Bail out!\n";
    use_ok( 'EBook::EPUB::NCX::NavPoint' ) || print "Bail out!\n";
}
