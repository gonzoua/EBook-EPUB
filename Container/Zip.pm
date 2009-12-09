# Copyright (c) 2009 Oleksandr Tymoshenko <gonzo@bluezbox.com>
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
    
    $self->write_container($tmp_container);
    $zip->addFile($tmp_container, "META-INF/container.xml");
    $zip->addFile($tmp_mimetype, "mimetype");

    $zip->writeToFileNamed($self->{zipfile});
    unlink($tmp_container);
    unlink($tmp_mimetype);
}
