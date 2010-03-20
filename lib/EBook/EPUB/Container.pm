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
package EBook::EPUB::Container;

use strict;
use XML::Writer;
use IO::File;
use File::Find;

use Carp;

sub new 
{
    my ($class, %params) = @_;
    my $self = {
            root_files => [],
            files => [],
            encrypted_files => [],
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
# Add encrypted file, at the moment it means font "encrypted" with 
# Adobe content protection algorithm
#
sub add_encrypted_path
{
    my ($self, $path) = @_;

    if (!is_valid_path($path)) {
        croak("Bad container path: $path");
        return;
    }

    push @{$self->{encrypted_files}}, $path;
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

    if (!defined($container)) {
        return;
    }

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

    return 1;
}

sub has_encrypted_files
{
    my ($self) = @_;
    return 1 if (@{$self->{encrypted_files}});

    # No encrypted data
    return;
}

# 
# Generate encryption.xml  for META-INF directory
#
sub write_encryption
{
    my ($self, $outname) = @_;
    my $container = new IO::File(">$outname");

    if (!defined($container)) {
        return;
    }

    my $writer = new XML::Writer( 
                                OUTPUT => $container, 
                                DATA_MODE => 1,
                                DATA_INDENT => 2,
                                    );
    $writer->xmlDecl("utf-8");
    $writer->startTag( "encryption",
                    "xmlns" => "urn:oasis:names:tc:opendocument:xmlns:container",
                        );
    foreach my $rf (@{$self->{encrypted_files}}) {
        $writer->startTag('EncryptedData',
            'xmlns' => 'http://www.w3.org/2001/04/xmlenc#',
        );
        $writer->emptyTag('EncryptionMethod', 
            'Algorithm' => 'http://ns.adobe.com/pdf/enc#RC',
        );
        $writer->startTag('CipherData');
        $writer->emptyTag('CipherReference', 
            'URI' => $rf,
        );
        $writer->endTag('CipherData');
        $writer->endTag('EncryptedData');
    }

    $writer->endTag("encryption");
    $writer->end();
    $container->close();

    return 1;
}



1;

__END__;

=head1 NAME

EBook::EPUB::Container

=head1 SYNOPSIS

Abstract OEPBS Container implementation

    my $container = EBook::EPUB::Container->new()
    $container->add_path('/path/to/content.ncx', 'DATA/content.ncx');
    $container->add_path('/path/to/page1.xhtml', 'DATA/page1.xhtml');
    $container->add_path('/path/to/page2.xhtml', 'DATA/page2.xhtml');
    $container->add_root_file('DATA/content.ncx');

=head1 SUBROUTINES/METHODS

=over 4

=item new()

Create new instance of EBook::EPUB::Container object

=item add_path($file_path, $container_path)

Add existing file into container

=item add_encrypted_path($container_path)

Mark file $container_path as encrypted. File should be already encrypted and 
added. This function just marks it encrypted

=item add_root_path($container_path)

Set file in container to be root file

=back

=head1 AUTHOR

Oleksandr Tymoshenko, E<lt>gonzo@bluezbox.comE<gt>

=head1 BUGS

Please report any bugs or feature requests to  E<lt>gonzo@bluezbox.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2009, 2010 Oleksandr Tymoshenko.

L<http://bluezbox.com>

This module is free software; you can redistribute it and/or
modify it under the terms of the BSD license. See the F<LICENSE> file
included with this distribution.
