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
package EPUB::Package::Metadata;
use Moose;
use EPUB::Package::Metadata::DCItem;
use EPUB::Package::Metadata::Item;

has items => (
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
);

sub encode
{
    my ($self, $writer) = @_;
    $writer->startTag("metadata", 
        'xmlns:dc'  => 'http://purl.org/dc/elements/1.1/',
        'xmlns:opf' => 'http://www.idpf.org/2007/opf',
    );
        
    foreach my $item (@{$self->items()}) {
        $item->encode($writer);
    }
    $writer->endTag("metadata");
}

sub add_title
{
    my ($self, $title) = @_;
    $self->add_dcitem('title', $title);
}

sub add_author
{
    my ($self, $author, $formal) = @_;
    my @args = ('opf:role'  => 'aut');
    if (defined($formal)) {
        push @args, 'opf:file-as', $formal;
    }
    $self->add_dcitem('creator', $author, @args);
}

sub add_translator
{
    my ($self, $name, $formal) = @_;
    my @args = ('opf:role'  => 'trl');
    if (defined($formal)) {
        push @args, 'opf:file-as', $formal;
    }
    $self->add_dcitem('creator', $name, @args);
}

sub add_subject
{
    my ($self, $subject) = @_;
    $self->add_dcitem('subject', $subject);
}

sub add_description
{
    my ($self, $description) = @_;
    $self->add_dcitem('desciption', $description);
}

sub add_date
{
    # Todo: handle date format here
    # http://www.idpf.org/2007/opf/OPF_2.0_final_spec.html#Section2.2.7
    my ($self, $date, $event) = @_;
    my @attr;
    if (defined($event)) {
        push @attr, "opf:event", $event;
    }
    $self->add_dcitem('date', $date, @attr);
}

sub add_identifier
{
    my ($self, $ident, $scheme) = @_;
    my @attr = ('id', 'BookId');
    if (defined($scheme)) {
        push @attr, "opf:scheme", $scheme;
    }
    $self->add_dcitem('identifier', $ident, @attr);
}

sub add_source
{
    my ($self, $source) = @_;
    $self->add_dcitem('source', $source);
}

sub add_language
{
    # TODO: filter language?
    my ($self, $lang) = @_;
    $self->add_dcitem('language', $lang);
}

sub add_rights
{
    my ($self, $rights) = @_;
    $self->add_dcitem('rights', $rights);
}

sub add_dcitem
{
    my ($self, $name, $value, @attributes) = @_;
    my $dcitem = EPUB::Package::Metadata::DCItem->new(
            name        => "dc:$name",
            value       => $value,
            attributes  => \@attributes);
    push @{$self->items()}, $dcitem;
}

sub add_item
{
    my ($self, $name, $value) = @_;
    my $item = EPUB::Package::Metadata::Item->new(
            name    => $name,
            value   => $value,
        );
    push @{$self->items()}, $item;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
