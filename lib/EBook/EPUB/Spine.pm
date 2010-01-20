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
package EBook::EPUB::Spine;
use Moose;
use EBook::EPUB::Spine::Itemref;

has toc => ( isa => 'Str', is => 'rw' );
has itemrefs => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
    handles    => {
           all_itemrefs => 'elements',
       },
);

sub encode
{
    my ($self, $writer) = @_;
    $writer->startTag("spine",
        toc => $self->toc,
    );

    foreach my $itemref (@{$self->itemrefs()}) {
        $itemref->encode($writer);
    }

    $writer->endTag("spine");
}

sub add_itemref
{
    my ($self, @args) = @_;
    my $itemref = EBook::EPUB::Spine::Itemref->new(@args);
    push @{$self->itemrefs()}, $itemref;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

EBook::EPUB::Spine

=head1 SYNOPSIS

Class that represents B<spine> element of OPF document


=head1 DESCRIPTION

The B<spine> element organizes the associated OPS Content Documents into the linear reading order of the publication.

=head1 SUBROUTINES/METHODS

=over 4

=item add_itemref(%opts)

Add reference an OPS Content Document designated in the B<manifest>. %opts is an anonymous hash, for possible key
values see L<EBook::EPUB::Spine::Itemref>

=item all_references()

Returns array of EBook::EPUB::Spine::Itemref objects, current content of B<spine> element

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
