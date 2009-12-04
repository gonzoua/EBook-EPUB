package EPUB::Container::Zip;

use vars qw(@ISA $VERSION);
@ISA     = qw(EPUB::Container);
$VERSION = 0.1;

use strict;
use EPUB::Container;
use Archive::Zip;
use File::Temp qw/:mktemp/;

sub new 
{
    my ($class, $zipfile) = @_;
    my $self = $class->SUPER::new();
    $self->{zipfile} = $zipfile;

    return $self;
}

sub write
{
    my ($self) = @_;
    my $zip = Archive::Zip->new();
    foreach my $f (@{$self->{files}}) {
        $zip->addFileOrDirectory($f->{frompath}, 
            $f->{containerpath});
    }

    my $tmp_container = mktemp("containerXXXXX");
    my ($MIMETYPE, $tmp_mimetype) = mkstemp( "mimetypeXXXXX" );
    print $MIMETYPE "application/epub+zip";
    close $MIMETYPE;
    
    $self->writeContainer($tmp_container);
    $zip->addFile($tmp_container, "META-INF/container.xml");
    $zip->addFile($tmp_mimetype, "mimetype");

    $zip->writeToFileNamed($self->{zipfile});
    unlink($tmp_container);
    unlink($tmp_mimetype);
}
