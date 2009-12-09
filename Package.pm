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

package EPUB::Package;
use Moose;

use EPUB::Package::Metadata;
use EPUB::Package::Manifest;
use EPUB::Package::Guide;
use EPUB::Package::Spine;
use EPUB::Package::NCX;

has metadata    => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Metadata->new() },
);

has manifest    => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Manifest->new() },
);

has spine       => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Spine->new() },
);

has guide       => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Guide->new() },
);

has ncx     => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::NCX->new() },
);

has uid         => (
    isa     => 'Str',
    is      => 'rw',
);

has id_counters => ( isa => 'HashRef', is => 'ro', default =>  sub { {} });

sub BUILD
{
    my ($self) = @_;
    $self->manifest->add_item(
        id          => 'ncx',
        href        => 'book.ncx', 
        media_type  => 'application/x-dtbncx+xml'
    );
    $self->spine->toc('ncx');
}

sub to_xml
{
    my ($self) = @_;
    my $xml;

    my $writer = XML::Writer->new(
        OUTPUT      => \$xml,
        DATA_MODE   => 1,
        DATA_INDENT => 2,
    );

    $writer->xmlDecl();
    $writer->startTag('package', 
        xmlns               => 'http://www.idpf.org/2007/opf',
        version             => '2.0',
        'unique-identifier' => 'BookId',
    );
    $self->metadata->encode($writer);
    $self->manifest->encode($writer);
    $self->spine->encode($writer);
    $self->guide->encode($writer);
    $writer->endTag('package');
    $writer->end();

    return $xml;
}

sub set_title
{
    my ($self, $title) = @_;
    # XXX: make it set_title?
    $self->metadata->add_title($title);
    $self->ncx->title($title);
}

sub add_translator
{
    my ($self, $translator) = @_;
    $self->metadata->add_translator($translator);
}

sub add_author
{
    my ($self, $author) = @_;
    $self->metadata->add_author($author);
    $self->ncx->author($author);
}

sub set_identifier
{
    my ($self, $ident, $scheme) = @_;
    $self->metadata->add_identifier($ident, $scheme);
    $self->ncx->uid($ident);
}

sub add_xhtml
{
    my ($self, $filename, %opts) = @_;
    my $linear = 1;

    if ($opts{'linear'} eq 'no') {
        $linear = 0;
    }

    my $id = $self->nextid('ch');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => 'application/xhtml+xml',
    );

    $self->spine->add_itemref(
        idref       => $id,
        linear      => $linear,
    );
}

sub add_stylesheet
{
    my ($self, $filename) = @_;
    my $id = $self->nextid('css');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => 'text/css',
    );
}

sub add_image
{
    my ($self, $filename, $type) = @_;
    # trying to guess
    if (!defined($type)) {
        if (($filename =~ /\.jpg$/i) || ($filename =~ /\.jpeg$/i)) {
            $type = 'image/jpeg';
        }
        elsif ($filename =~ /\.gif$/i) {
            $type = 'image/gif';
        }
        elsif ($filename =~ /\.png$/i) {
            $type = 'image/png';
        }
        elsif ($filename =~ /\.svg$/i) {
            $type = 'image/svg+xml';
        }
        else {
            croak ("Unknown image type for file $filename");
            return;
        }
    }

    my $id = $self->nextid('img');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => $type,
    );

    return $id;
}



sub nextid
{
    my ($self, $prefix) = @_;
    my $id;

    $prefix = 'id' unless(defined($prefix));
    if (defined(${$self->id_counters}{$prefix})) {
        $id = "$prefix" . ${$self->id_counters}{$prefix};
        ${$self->id_counters}{$prefix}++;
    }
    else
    {
        # First usage of prefix
        $id = "${prefix}1";
        ${$self->id_counters}{$prefix} = 2;
    }

    return $id;
}

no Moose;

1;
