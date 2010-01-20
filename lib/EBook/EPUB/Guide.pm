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
package EBook::EPUB::Guide;
use Moose;
use EBook::EPUB::Guide::Reference;

has references => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
    handles    => {
           all_references    => 'elements',
       },
);

sub encode
{
    my ($self, $writer) = @_;
    # Only if there are any items
    if ($self->all_references) {
            $writer->startTag("guide");
            foreach my $ref ($self->all_references()) {
                $ref->encode($writer);
            }
            $writer->endTag("guide");
    }
}

sub add_reference
{
    my ($self, @args) = @_;
    my $ref = EBook::EPUB::Guide::Reference->new(@args);
    push @{$self->references()}, $ref;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__
=head1 NAME

EBook::EPUB::Guide

=head1 SYNOPSIS

Class that represents B<guide> element of OPF document

=head1 DESCRIPTION

The B<guide> element identifies fundamental structural components of the
publication, to enable Reading Systems to provide convenient access to them.

The structural components of the books are listed in B<reference> elements
contained within the B<guide> element. These components could refer to the
table of contents, list of illustrations, foreword, bibliography, and many
other standard parts of the book. Reading Systems are not required to use the
B<guide> element in any way.

See section 2.6 of OPF specification

=head1 SUBROUTINES/METHODS

=over 4

=item add_reference(%opts)

Add reference to guide element. %opts is an anonymous hash, for possible key
values see L<EBook::EPUB::Guide::Reference>

=item all_references()

Returns array of EBook::EPUB::Guide::Reference objects, current content of B<guide> element

=item encode($xmlwriter)

Encode object to XML form using XML::Writer instance

=item new()

Create new object

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

