use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'EBook::EPUB',
    AUTHOR              => q{Oleksandr Tymoshenko <gonzo@bluezbox.com>},
    VERSION_FROM        => 'lib/EBook/EPUB.pm',
    ABSTRACT_FROM       => 'lib/EBook/EPUB.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'bsd')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'EBook-EPUB-*' },
);
