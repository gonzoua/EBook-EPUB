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

package EPUB::Package;
our $VERSION = '0.01';

use Moose;

use EPUB::Package::Metadata;
use EPUB::Package::Manifest;
use EPUB::Package::Guide;
use EPUB::Package::Spine;
use EPUB::Package::NCX;

use EPUB::Container::Zip;

use File::Temp qw/tempdir/;
use File::Copy;

has metadata    => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Metadata->new() },
);

has manifest    => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Manifest->new() },
);

has spine       => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Spine->new() },
);

has guide       => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::Guide->new() },
);

has ncx     => (
    isa     => 'Object', 
    is      => 'ro',
    default => sub { EPUB::Package::NCX->new() },
    handles => {
        add_navpoint    => 'add_navpoint',
    },
);

has uid         => (
    isa     => 'Str',
    is      => 'rw',
);

has id_counters => ( isa => 'HashRef', is => 'ro', default =>  sub { {} });
has tmpdir => ( isa => 'Str', is => 'rw', default =>  sub { tempdir( CLEANUP => 1 ); });

sub BUILD
{
    my ($self) = @_;
    $self->manifest->add_item(
        id          => 'ncx',
        href        => 'toc.ncx', 
        media_type  => 'application/x-dtbncx+xml'
    );

    $self->spine->toc('ncx');
    mkdir ($self->tmpdir . "/OPS") or die "Can't make OPS dir in " . $self->tmpdir;
}

sub to_xml
{
    my ($self) = @_;
    my $xml;

    my $writer = XML::Writer->new(
        OUTPUT      => \$xml,
        DATA_MODE   => 1,
        DATA_INDENT => 2,
    );

    $writer->xmlDecl();
    $writer->startTag('package', 
        xmlns               => 'http://www.idpf.org/2007/opf',
        version             => '2.0',
        'unique-identifier' => 'BookId',
    );
    $self->metadata->encode($writer);
    $self->manifest->encode($writer);
    $self->spine->encode($writer);
    $self->guide->encode($writer);
    $writer->endTag('package');
    $writer->end();

    return $xml;
}

sub set_title
{
    my ($self, $title) = @_;
    # XXX: make it set_title?
    $self->metadata->add_title($title);
    $self->ncx->title($title);
}

sub add_language
{
    my ($self, $lang) = @_;
    $self->metadata->add_language($lang);
}

sub add_translator
{
    my ($self, $translator) = @_;
    $self->metadata->add_translator($translator);
}

sub add_author
{
    my ($self, $author) = @_;
    $self->metadata->add_author($author);
    $self->ncx->author($author);
}

sub set_identifier
{
    my ($self, $ident, $scheme) = @_;
    $self->metadata->add_identifier($ident, $scheme);
    $self->ncx->uid($ident);
}

sub add_xhtml_entry
{
    my ($self, $filename, %opts) = @_;
    my $linear = 1;

    $linear = 0 if (defined ($opts{'linear'}) && 
            $opts{'linear'} eq 'no');


    my $id = $self->nextid('ch');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => 'application/xhtml+xml',
    );

    $self->spine->add_itemref(
        idref       => $id,
        linear      => $linear,
    );
}

sub add_stylesheet_entry
{
    my ($self, $filename) = @_;
    my $id = $self->nextid('css');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => 'text/css',
    );
}

sub add_image_entry
{
    my ($self, $filename, $type) = @_;
    # trying to guess
    if (!defined($type)) {
        if (($filename =~ /\.jpg$/i) || ($filename =~ /\.jpeg$/i)) {
            $type = 'image/jpeg';
        }
        elsif ($filename =~ /\.gif$/i) {
            $type = 'image/gif';
        }
        elsif ($filename =~ /\.png$/i) {
            $type = 'image/png';
        }
        elsif ($filename =~ /\.svg$/i) {
            $type = 'image/svg+xml';
        }
        else {
            croak ("Unknown image type for file $filename");
            return;
        }
    }

    my $id = $self->nextid('img');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => $type,
    );

    return $id;
}

sub add_entry
{
    my ($self, $filename, $type) = @_;
    my $id = $self->nextid('item');
    $self->manifest->add_item(
        id          => $id,
        href        => $filename,
        media_type  => $type,
    );
}

sub add_xhtml
{
    my ($self, $filename, $data, %opts) = @_;
    my $tmpdir = $self->tmpdir;
    open F, ">:utf8", "$tmpdir/OPS/$filename";
    print F $data;
    close F;
    $self->add_xhtml_entry($filename, %opts);
}

sub add_stylesheet
{
    my ($self, $filename, $data) = @_;
    my $tmpdir = $self->tmpdir;
    open F, ">:utf8", "$tmpdir/OPS/$filename";
    print F $data;
    close F;
    $self->add_stylesheet_entry($filename);
}

sub add_image
{
    my ($self, $filename, $data, $type) = @_;
    my $tmpdir = $self->tmpdir;
    open F, "> $tmpdir/OPS/$filename";
    binmode F;
    print F $data;
    close F;
    $self->add_image_entry($filename, $type);
}

sub add_data
{
    my ($self, $filename, $data, $type) = @_;
    my $tmpdir = $self->tmpdir;
    open F, "> $tmpdir/OPS/$filename";
    binmode F;
    print F $data;
    close F;
    $self->add_entry($filename, $type);
}

sub copy_xhtml
{
    my ($self, $src_filename, $filename, %opts) = @_;
    my $tmpdir = $self->tmpdir;
    if (copy($src_filename, "$tmpdir/OPS/$filename")) {
        $self->add_xhtml_entry($filename, %opts);
    }
    else {
        warn ("Failed to copy $src_filename to $tmpdir/OPS/$filename");
    }
}

sub copy_stylesheet
{
    my ($self, $src_filename, $filename) = @_;
    my $tmpdir = $self->tmpdir;
    if (copy($src_filename, "$tmpdir/OPS/$filename")) {
        $self->add_stylesheet_entry("$filename");
    }
    else {
        warn ("Failed to copy $src_filename to $tmpdir/OPS/$filename");
    }
}

sub copy_image
{
    my ($self, $src_filename, $filename, $type) = @_;
    my $tmpdir = $self->tmpdir;
    if (copy($src_filename, "$tmpdir/OPS/$filename")) {
        $self->add_image_entry("$filename");
    }
    else {
        warn ("Failed to copy $src_filename to $tmpdir/OPS/$filename");
    }
}

sub copy_file
{
    my ($self, $src_filename, $filename, $type) = @_;
    my $tmpdir = $self->tmpdir;
    if (copy($src_filename, "$tmpdir/OPS/$filename")) {
        my $id = $self->nextid('id');
        $self->manifest->add_item(
            id          => $id,
            href        => "OPS/$filename",
            media_type  => $type,
        );
    }
    else {
        warn ("Failed to copy $src_filename to $tmpdir/OPS/$filename");
    }
}

sub nextid
{
    my ($self, $prefix) = @_;
    my $id;

    $prefix = 'id' unless(defined($prefix));
    if (defined(${$self->id_counters}{$prefix})) {
        $id = "$prefix" . ${$self->id_counters}{$prefix};
        ${$self->id_counters}{$prefix}++;
    }
    else
    {
        # First usage of prefix
        $id = "${prefix}1";
        ${$self->id_counters}{$prefix} = 2;
    }

    return $id;
}

sub pack_zip
{
    my ($self, $filename) = @_;
    my $tmpdir = $self->tmpdir;
    $self->write_ncx("$tmpdir/OPS/toc.ncx");
    $self->write_opf("$tmpdir/OPS/content.opf");
    my $container = EPUB::Container::Zip->new($filename);
    $container->add_path($tmpdir . "/OPS", "OPS/");
    $container->add_root_file("OPS/content.opf", "application/oebps-package+xml");
    $container->write();
}

sub write_opf
{
    my ($self, $filename) = @_;
    open F, ">:utf8", $filename or die "Failed to create OPF file: $filename";
    my $xml = $self->to_xml();
    print F $xml;
    close F;
}

sub write_ncx
{
    my ($self, $filename) = @_;
    open F, ">:utf8", $filename or die "Failed to create NCX file: $filename";
    my $xml = $self->ncx->to_xml();
    print F $xml;
    close F;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__
=head1 NAME

EPUB::Package - module for building OPF documents 

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

    use EPUB::Package;

    # Create package object
    my $package = EPUB::Package->new;

    # Set metadata: title/author/language/id
    $package->set_title('Three Men in a Boat');
    $package->add_author('Jerome K. Jerome');
    $package->add_language('en');
    $package->set_identifier('0765341611');

    # Add package content: stylesheet, font, xhtml
    $package->copy_stylesheet('/path/to/style.css', 'style.css');
    $package->copy_file('/path/to/CharisSILB.ttf', 
        'CharisSILB.ttf', 'application/x-font-ttf');
    $package->copy_xhtml('/path/to/page1.xhtml', 'page1.xhtml');
    $package->copy_xhtml('/path/to/notes.xhtml', 'notes.xhtml',
        linear => 'no'
    );

    # Generate resulting ebook
    $package->pack_zip('/path/to/three_men_in_a_boat.epub');

=head1 SUBROUTINES/METHODS

=over 4

=item new([$params])

Create an EPUB::Package object

=item set_title($title)

Set the title of the book

=item add_language($lang)

Add language to the list of document languages. At least one is 
required. $lang should be in RFC 3066 format or its successors 
such as the newer RFC 4646

=item add_author($name)

Add author to the list of document authors

=item add_translator($name)

Add translator to the list of document translators

=item set_identifier($id)

Set a unique identifier for the book, such as its ISBN or a URL

=item add_xhtml($data, $filename, %opts)

Add xhtml data $data to $filename in package. 

%opts is an anonymous hash array of parameters:

=over 4

=item linear 

'yes' or 'no'

=back 

=item add_stylesheet($data, $filename)

Add stylesheet data $data as $filename in package

=item add_image($data, $filename, $type)

Add image data $data as $filename in package with content type $type (e.g. image/jpeg)

=item copy_xhtml($source_file, $filename, %opts)

Add existing xhtml file $source_file as $filename in package. 

%opts is an anonymous hash array of parameters:

=over 4

=item linear 

'yes' or 'no'

=back 

=item copy_stylesheet($source_file, $filename)

Add existing css file $source_file as $filename in package

=item copy_image($source_file, $filename, $type)

Add existing image file $source_file as $filename in package and set its content type to $type (e.g. image/jpeg)

=item copy_file($source_file, $filename, $type)

Add existing file $source_file as $filename in package and set its content type to $type (e.g. text/plain)

=item pack_zip($filename)

Generate OCF Zip container with contents of current package

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
