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

package EBook::EPUB::Container::Zip;

use strict;
use EBook::EPUB::Container;
use Archive::Zip;
use File::Temp qw/tempfile/;
use Carp;

use vars qw(@ISA);
@ISA     = qw(EBook::EPUB::Container);

sub new 
{
    my ($class, $zipfile) = @_;
    my $self = $class->SUPER::new();
    $self->{zipfile} = $zipfile;

    return $self;
}

sub write
{
    my ($self) = @_;
    my $zip = Archive::Zip->new();

    # mimetype should come first
    $zip->addString("application/epub+zip", "mimetype");

    foreach my $f (@{$self->{files}}) {
        $zip->addFileOrDirectory($f->{frompath}, 
            $f->{containerpath});
    }

    my (undef, $tmp_container) = tempfile;
    if (!defined($self->write_container($tmp_container))) {
        carp "Failed to write container to temporary file $tmp_container";
        return;
    }

    $zip->addFile($tmp_container, "META-INF/container.xml");

    $zip->writeToFileNamed($self->{zipfile});
    unlink($tmp_container);

    return 1;
}

__END__

=head1 NAME

EBook::EPUB::Container::Zip

=head1 SYNOPSIS

Zip OEPBS Container implementation

    my $container = EBook::EPUB::Container::Zip->new('/path/to/file.epub')

    # EBook::EPUB::Container methods
    $container->add_path('/path/to/content.ncx', 'DATA/content.nx');
    $container->add_path('/path/to/page1.xhtml', 'DATA/page1.xhtml');
    $container->add_path('/path/to/page2.xhtml', 'DATA/page2.xhtml');
    $container->add_root_file('DATA/content.ncx');

    # Write it to disk
    $container->write();

=head1 SUBROUTINES/METHODS

=over 4

=item new($zipfile)

Create new instance of EBook::EPUB::Container::Zip object. $zipfile is a file where container should be saved 

=item write()

Create zip file with container contents

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
