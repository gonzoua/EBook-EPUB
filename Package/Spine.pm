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
package EPUB::Package::Spine;
use Moose;
use EPUB::Package::Spine::Itemref;

has toc => ( isa => 'Str', is => 'rw' );
has itemrefs => (
    is         => 'ro',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
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
    my $itemref = EPUB::Package::Spine::Itemref->new(@args);
    push @{$self->itemrefs()}, $itemref;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
