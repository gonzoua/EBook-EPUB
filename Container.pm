# Copyright (C) 2009 by Oleksandr Tymoshenko. All rights reserved.

# OEPBS Container format implementation
# http://www.idpf.org/ocf/ocf1.0/download/ocf10.htm
package EPUB::Container;

use strict;
use XML::Writer;
use IO::File;
use File::Find;

sub new 
{
    my ($class, %params) = @_;
    my $self = {
            root_files => [],
            files => []
        };
    return bless $self, $class;
}

#
# Add root file (item in <rootfiles> element)
#
sub addRootFile
{
    my ($self, $path, $mediatype) = @_;
    push @{$self->{root_files}},  {
        path => $path,
        mediatype => $mediatype,
    };
}

#
# Add content. Recurse if it's directory
#
sub addPath
{
    my ($self, $from_path, $container_path) = @_;

    # Closure to collect files recursively
    my $file_cb = sub {
        my $file = $File::Find::name;
        my $dest = $file;
        $dest =~ s/$from_path/$container_path/;

        # XXX: UNIX only
        if (-d $file) {
            $dest .= "/";
        }

        if (!isValidPath($dest)) {
            croak("Bad container path: $dest");
            return;
        }

        push @{$self->{files}},  {
            frompath => $file,
            containerpath => $dest,
        }
    };
    if (-d  $from_path) {
        # XXX: UNIX only
        # Strip unncessary slashes
        $from_path =~ s/\/+$//g;
        $container_path =~ s/\/+$//g;
        find( { wanted => $file_cb, no_chdir => 1 }, $from_path);
    }
    else {
        if (!isValidPath($container_path)) {
            croak("Bad container path: $container_path");
            return;
        }

        push @{$self->{files}},  {
            frompath => $from_path,
            containerpath => $container_path,
        }
    }
    
}

#
# Check if file name conforms specs
# TODO: make conformant to spec
sub isValidPath
{
    my $path = shift;
    return if($path =~ /META-INF/);

    return 1;
}

# 
# Generate container.xml  for META-INF directory
#
sub writeContainer
{
    my ($self, $outname) = @_;
    my $container = new IO::File(">$outname");
    my $writer = new XML::Writer( 
                                OUTPUT => $container, 
                                DATA_MODE => 1,
                                DATA_INDENT => 2,
                                    );
    $writer->xmlDecl("utf-8");
    $writer->startTag( "container",
                    "xmlns" => "urn:oasis:names:tc:opendocument:xmlns:container",
                    "version" => "1.0",
                        );
    $writer->startTag("rootfiles");
    foreach my $rf (@{$self->{root_files}}) {
        $writer->emptyTag("rootfile",
            "full-path", $rf->{path},
            "media-type", $rf->{mediatype},
        );
    }
    $writer->endTag("rootfiles");
    $writer->endTag("container");
    $writer->end();
    $container->close();
}

1;
