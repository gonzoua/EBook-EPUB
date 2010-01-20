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
package EBook::EPUB::NCX;
use Moose;
use EBook::EPUB::NCX::NavPoint;

# Very simplified module for generation NCX

has [qw/uid title author/] => ( isa => 'Str', is => 'rw' );

has navpoints => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
    handles    => {
           all_navpoints => 'elements',
       },
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
    foreach my $point ($self->all_navpoints) {
        $point->encode($writer);
    }
    $writer->endTag('navMap');
}

sub add_navpoint
{
    my ($self, @args) = @_;
    my $point = EBook::EPUB::NCX::NavPoint->new(@args);
    push @{$self->navpoints}, $point;
    return $point;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

EBook::EPUB::NCX

=head1 SYNOPSIS

Class that "Navigation Center eXtended" file of OPF document

=head1 DESCRIPTION

The Navigation Control file for XML applications (NCX) exposes the hierarchical
structure of a Publication to allow the user to navigate through it. The NCX is
similar to a table of contents in that it enables the reader to jump directly
to any of the major structural elements of the document, i.e. part, chapter, or
section, but it will often contain more elements of the document than the
publisher chooses to include in the original print table of contents. It can be
visualized as a collapsible tree familiar to PC users.

=head1 SUBROUTINES/METHODS

=over 4

=item add_navpoint(%opts)

Add refrence to an OPS Content Document that is a part of publication. %opts is
an anonymous hash, for possible key values see L<EBook::EPUB::NCX::NavPoint>.
Method returns created EBook::EPUB::NCX::NavPoint object that could be used
later for adding subsections.

=item all_navpoints()

Returns array of EBook::EPUB::NCX::NavPoint objects, current content of NCX

=item author([$author)

Get/set book auther

=item new(%opts)

Create new object. %opts is anonymous hash with possible key values:
    author
    title
    uid

=item title([$title)

Get/set book title

=item to_xml()

Returns XML representation of NCX

=item uid([$uid)

Get/set unique identfier for book

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
