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
package EBook::EPUB::Metadata::DCItem;
use Moose;

#
# Helper class for DC metadata items. Just contains name, value and attributes.
# values goes as CDATA.
# End-user should not use this module directly
#

has [qw/name value/] => (isa => 'Str', is => 'rw');
has attributes => (
    traits  => ['Array'],
    isa     => 'ArrayRef[Str]',
    is      => 'ro',
    default => sub { [] },
    handles    => {
          all_options    => 'elements',
          add_option     => 'push',
    },
);

sub encode
{
    my ($self, $writer) = @_;
    $writer->dataElement($self->name, $self->value,
        @{$self->attributes},
    );
    my %attr = @{$self->attributes()};
}

# Override default - set not reference value but 
# reference content
sub copy_attributes
{
    my ($self, $ref) = @_;
    @{$self->attributes()} = @{$ref};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
