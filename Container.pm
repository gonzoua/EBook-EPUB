# Copyright (c) 2009, 2010 Oleksandr Tymoshenko <gonzo@bluezbox.com>
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

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
sub add_root_file
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
sub add_path
{
    my ($self, $from_path, $container_path) = @_;

    # Closure to collect files recursively
    my $file_cb = sub {
        my $file = $File::Find::name;
        my $dest = $file;
        $dest =~ s/\Q$from_path\E/$container_path/;
        print "-> $dest\n";

        # XXX: UNIX only
        if (-d $file) {
            $dest .= "/";
        }

        if (!is_valid_path($dest)) {
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
        if (!is_valid_path($container_path)) {
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
sub is_valid_path
{
    my $path = shift;
    return if($path =~ /META-INF/);

    return 1;
}

# 
# Generate container.xml  for META-INF directory
#
sub write_container
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
