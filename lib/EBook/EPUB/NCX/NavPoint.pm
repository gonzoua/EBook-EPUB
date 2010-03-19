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
package EBook::EPUB::NCX::NavPoint;
use Moose;

has [qw/label id content class/] => ( isa => 'Str', is => 'rw' );
has play_order => ( isa => 'Int', is => 'rw' );
has navpoints => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
    handles    => {
           all_navpoints => 'elements',
       },
);

sub encode
{
    my ($self, $writer) = @_;
    my @args = ( 
        id          => $self->id,
        playOrder   => $self->play_order);
    if (defined($self->class)) {
        push @args, 'class', $self->class;
    }

    $writer->startTag('navPoint', @args);
    $writer->startTag('navLabel');
    $writer->dataElement('text', $self->label);
    $writer->endTag('navLabel');
    $writer->emptyTag('content',
        src         => $self->content,
    );

    # subpoints
    foreach my $point (@{$self->navpoints}) {
        $point->encode($writer);
    }

    $writer->endTag('navPoint');
}

sub add_navpoint
{
    my ($self, @args) = @_;
    my $subpoint = EBook::EPUB::NCX::NavPoint->new(@args);
    push @{$self->navpoints}, $subpoint;

    return $subpoint;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

EBook::EPUB::NCX::NavPoint

=head1 SYNOPSIS

Entry in Navigation Center that refers to part of a document (e.g. chapter)

=head1 SUBROUTINES/METHODS

=over 4

=item new(%opts)

%opts is an anonymous hash that might containe followig keys:

    class
    content
    id 
    play_order
    label 

=item add_navpoint(%opts)

Add refrence to an OPS Content Document that is a part of publication,
subsection of the part current object references to. %opts is an anonymous
hash, for possible key values see new() method description.  Method returns
created EBook::EPUB::NCX::NavPoint object that could be used later for adding
subsections.

=item all_navpoints()

Returns array of EBook::EPUB::NCX::NavPoint objects, subsections of current one

=item encode($xmlwriter)

Encode object to XML form using XML::Writer instance

=item class([$class])

Get/set class of navigation point

=item content([$content])

Get/set URI to the part navPoint references to

=item id([$id])

Get/set ID of navigation point

=item label([$label])

Get/set human readable description of part navPoint references to

=item play_order([$play_order])

Get/set play order (number) of text part.

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

