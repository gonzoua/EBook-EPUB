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
package EBook::EPUB::Guide::Reference;
use Moose;

has [qw/href type/] => (isa => 'Str', is => 'rw');
has title => (
    isa         => 'Str',
    is          => 'rw',
    predicate   => 'has_title',
);

sub encode
{
    # $writer is instance of XML::Writer
    my ($self, $writer) = @_;
    my @attributes = (
            href => $self->href(),
            type => $self->type(),
        );

    if ($self->has_title()) {
        push @attributes, 'title', $self->title();
    }

    $writer->emptyTag('reference', @attributes);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

EBook::EPUB::Guide::Reference

=head1 SYNOPSIS

Reference for E<lt>guideE<gt> element of OPF file.

=head1 SUBROUTINES/METHODS

=over 4

=item new(%opts)

%opts is an anonymous hash that might containe followig keys:

    type
    href
    title

=item encode($xmlwriter)

Encode object to XML form using XML::Writer instance

=item href([$href])

Get/set reference to an OPS Content Document included in the 
manifest, and which may include a fragment identifier as defined 
in section 4.1 of RFC 2396

=item title([$title])

Human-readable description of reference

=item type([$type])

Get/set type of reference. Possible values:

=over 4

=item cover

=item title-page

=item toc

=item index

=item glossary

=item acknowledgements

=item bibliography

=item colophon

=item copyright-page

=item dedication

=item epigraph

=item foreword

=item loi

=item lot

=item notes

=item preface

=item text

=back 

For detailed description refer to section 2.6 of OPF specification or 
Chicago Manual of Style

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
