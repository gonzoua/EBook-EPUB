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
package EPUB::Package::NCX;
use Moose;
use EPUB::Package::NCX::NavPoint;

# Very simplified module for generation NCX

has [qw/uid title author/] => ( isa => 'Str', is => 'rw' );
has navpoints => (
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
);

sub to_xml
{
    my ($self) = @_;
    my $xml;
    my $writer = new XML::Writer(
        OUTPUT => \$xml,
        DATA_MODE => 1,
        DATA_INDENT => 2,
    );

    $writer->xmlDecl('utf-8');
    $writer->doctype('ncx', '-//NISO//DTD ncx 2005-1//EN',
        'http://www.daisy.org/z3986/2005/ncx-2005-1.dtd');
    
    $writer->startTag('ncx', 
        version     => '2005-1',
        xmlns       => 'http://www.daisy.org/z3986/2005/ncx/',
    );
    # <head>..</head>
    $self->create_head_element($writer);
    # Now document data
    $self->create_doc_data($writer);
    $self->create_navmap($writer);

    $writer->endTag('ncx');
    $writer->end();

    return $xml;
}

sub create_head_element
{
    my ($self, $writer) = @_;
    $writer->startTag('head');
    $writer->emptyTag('meta',
        name    => 'dtb:uid',
        content => $self->uid,
    );

    $writer->emptyTag('meta',
        name    => 'dtb:depth',
        content => '1',
    );

    $writer->emptyTag('meta',
        name    => 'dtb:totalPageCount',
        content => '0',
    );

    $writer->emptyTag('meta',
        name    => 'dtb:maxPageNumber',
        content => '0',
    );

    $writer->endTag('head');
}

sub create_doc_data
{
    my ($self, $writer) = @_;

    $writer->startTag('docTitle');
    $writer->dataElement('text', $self->title);
    $writer->endTag('docTitle');

    $writer->startTag('docAuthor');
    $writer->dataElement('text', $self->author);
    $writer->endTag('docAuthor');
}

sub create_navmap
{
    my ($self, $writer) = @_;
    $writer->startTag('navMap');
    foreach my $point (@{$self->navpoints}) {
        $point->encode($writer);
    }
    $writer->endTag('navMap');
}

sub add_navpoint
{
    my ($self, @args) = @_;
    my $point = EPUB::Package::NCX::NavPoint->new(@args);
    push @{$self->navpoints}, $point;
    return $point;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
