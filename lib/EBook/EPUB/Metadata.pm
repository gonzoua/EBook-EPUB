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
package EBook::EPUB::Metadata;
use Moose;
use EBook::EPUB::Metadata::DCItem;
use EBook::EPUB::Metadata::Item;

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

sub add_contributor
{
    my ($self, $name, %opts) = @_;
    my @args = ();
    my $formal = $opts{'fileas'};
    my $role = $opts{'role'};
    if (defined($formal)) {
        push @args, 'opf:file-as', $formal;
    }
    if (defined($role)) {
        push @args, 'opf:role', $role;
    }

    $self->add_dcitem('contributor', $name, @args);
}

sub add_creator
{
    my ($self, $name, %opts) = @_;
    my @args = ();
    my $formal = $opts{'fileas'};
    my $role = $opts{'role'};
    if (defined($formal)) {
        push @args, 'opf:file-as', $formal;
    }
    if (defined($role)) {
        push @args, 'opf:role', $role;
    }

    $self->add_dcitem('creator', $name, @args);
}

sub add_author
{
    my ($self, $author, $formal) = @_;
    $self->add_creator($author, fileas => $formal, role => 'aut');
}

sub add_translator
{
    my ($self, $name, $formal) = @_;
    $self->add_creator($name, fileas => $formal, role => 'trl');
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

sub add_type
{
    my ($self, $type) = @_;
    $self->add_dcitem('type', $type);
}

sub add_format
{
    my ($self, $format) = @_;
    $self->add_dcitem('format', $format);
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

sub add_relation
{
    my ($self, $relation) = @_;
    $self->add_dcitem('relation', $relation);
}

sub add_rights
{
    my ($self, $rights) = @_;
    $self->add_dcitem('rights', $rights);
}

sub add_dcitem
{
    my ($self, $name, $value, @attributes) = @_;
    my $dcitem = EBook::EPUB::Metadata::DCItem->new(
            name        => "dc:$name",
            value       => $value,
            attributes  => \@attributes);
    push @{$self->items()}, $dcitem;
}

sub add_item
{
    my ($self, $name, $value) = @_;
    my $item = EBook::EPUB::Metadata::Item->new(
            name    => $name,
            value   => $value,
        );
    push @{$self->items()}, $item;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

EBook::EPUB::Metadata

=head1 SYNOPSIS

Class that represents B<metadata> element of OPF document. Provides information
about the publication as a whole

=head1 SUBROUTINES/METHODS

=over 4

=item new()

Create new object

=item encode($xmlwriter)

Encode object to XML form using XML::Writer instance

=item add_author($name, [$formal_name])

Add author of the document. For details see add_contributor.

=item add_creator($name, [fileas =E<gt> $formal_name, role =E<gt> $role])

Add primary creator or author of the publication of the publication. See
add_contributor for details


=item add_contributor($name, [fileas =E<gt> $formal_name, role =E<gt>])

Add person/organization that contributed to publication. $name is the name in
human-readable form, e.g. "Arthur Conan Doyle", $formal_name is in form,
suitable for machine processing, e.g.  "Doyle, Arthur Conan". $role reflects
kind of contribution to document. See Section 2.2.6 of OPF specification for
list of possible values L<http://www.idpf.org/2007/opf/OPF_2.0_final_spec.html#Section2.2.6>


=item add_date($date, [$event])

Date of publication, in the format defined by "Date and Time Formats" at
http://www.w3.org/TR/NOTE-datetime and by ISO 8601 on which it is based. In
particular, dates without times are represented in the form YYYY[-MM[-DD]]: a
required 4-digit year, an optional 2-digit month, and if the month is given, an
optional 2-digit day of month. $event is an optional description of event that
date refers to. Possible values may include: creation, publication, and
modification.

=item add_description($description)

Add description of the publication content

=item add_identifier($ident, [$scheme])

Add unique identifier of the publication. $scheme is an optional paramater to
specify identification system of this particular identifier. e.g. ISDN, DOI

=item add_item($name, $value)

Add metadata item that does not belong to Dublin Core specification. Metadata
is set by simple name/value pair.

=item add_format($format)

The media type or dimensions of the resource. Best practice is to use a value from a controlled vocabulary (e.g. MIME media types).

=item add_language($lang)

Add language of the content of the publication. $lang must comply with RFC 3066
(see http://www.ietf.org/rfc/rfc3066.txt)

=item add_relation($relation)

An identifier of an auxiliary resource and its relationship to the publication.

=item add_rights($rights)

A statement about rights, or a reference to one. In this specification, the copyright notice and any further rights description should appear directly.

=item add_source($source)

Information regarding a prior resource from which the publication was derived

=item add_subject($subject)

Add subject of the publication

=item add_title($title)

Add title of the publication

=item add_translator($name, [$formal_name])

Add translator of the document. $name is in human-readable form, e.g. "Arthur
Conan Doyle", $formal_name is in form, suitable for machine processing, e.g.
"Doyle, Arthur Conan"

=item add_type($type)

type includes terms describing general categories, functions, genres, or
aggregation levels for content. The advised best practice is to select a value
from a controlled vocabulary.

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
