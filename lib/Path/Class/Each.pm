package Path::Class::Each;

use warnings;
use strict;

use Carp qw( croak );
use Path::Class;

our $VERSION = '0.01';

=head1 NAME

Path::Class::Each - Iterate lines in a file

=head1 VERSION

This document describes Path::Class::Each version 0.01

=head1 SYNOPSIS

  use Path::Class;
  use Path::Class::Each;

  # Iterator interface
  my $iter = file( 'foo', 'bar' )->iterator;
  while ( defined( my $line = $iter->() ) ) {
    print "Line: $line\n";
  }

  # 'next' interface
  my $file = file( 'foo', 'bar' );
  while ( defined( my $line = $file->next ) ) {
    print "Line: $line\n";
  }

  # Callback interface
  file( 'foo', 'bar' )->each(
    sub {
      print "Line: $_\n";
    }
  );

=head1 DESCRIPTION

C<Path::Class::Each> augments L<Path::Class::File> to provide three different
ways of iterating over the lines of a file.

C<Path::Class::File> provides a C<slurp> method that returns the
contents of a file (either as a scalar or an array) but has no support
for reading a file a line at a time. For large files it may be desirable
to iterate through the lines; that's where this module comes in.

=head1 INTERFACE

=head2 C<< Path::Class::File->iterator >>

Get an iterator that returns the lines in a file. Returns C<undef> when
there are no more lines to return.

  my $iter = file( 'foo', 'bar' )->iterator;
  while ( defined( my $line = $iter->() ) ) {
    print "Line: $line\n";
  }

If the file can not be opened an exception will be thrown (using
C<croak>).

The following options may be passed as key, value pairs:

=over

=item C<< chomp >>

Newlines will be trimmed from each line read.

=item C<< iomode >>

Passed as the C<mode> argument to C<open>. See
L<Path::Class::File::open> for details. If omitted defaults to 'r'
(read-only).

=back

Here's how options are passed:

  my $chomper = file('foo', 'bar')->iterator( chomp => 1 );

=cut

sub Path::Class::File::iterator {
  my $self = shift;
  my @opt  = @_;

  croak "each requires a number of name => value options"
   if @opt % 2;

  my %opt   = ( @opt, iomode => 'r' );
  my $mode  = delete $opt{iomode};
  my $chomp = delete $opt{chomp};

  croak "unknown options: ", join ', ', sort keys %opt
   if keys %opt;

  my $fh = $self->open( $mode ) or croak "Can't read $self: $!\n";
  return sub {
    my $line = <$fh>;
    return unless defined $line;
    chomp $line if $chomp;
    return $line;
  };
}

=head2 C<< Path::Class::File->next >>

Return the next line from a file. Returns C<undef> when all lines have
been read.

Internally L<iterator> is called if necessary to create a new iterator.
The same options that L<iterator> accepts may be passed to C<next>:

  my $file = file( 'foo', 'bar' );
  while ( defined( my $line = $file->next( chomp => 1 ) ) ) {
    print "Line: $line\n";
  }

=head3 NOTE

It may be tempting to use an idiom like:

  # DON'T DO THIS
  while ( my $line = file('foo')->next ) {
    ...
  }

That will create a new C<Path::Class::File> and, therefore, a new
iterator each time it is called with the result that the first line of
the file will be returned repeatedly.

=cut

sub Path::Class::File::next {
  my $self = shift;

  $self->{_iter} = $self->iterator( @_ )
   unless $self->{_iter};

  my $line = $self->{_iter}->();
  delete $self->{_iter} unless defined $line;
  return $line;
}

=head2 C<< Path::Class::File->each >>

Call a supplied callback for each line in a file. The same options that
L<iterator> accepts may be passed:

  file( 'foo', 'bar' )->each( chomp => 1, sub { print "Line: $_\n" } );

Within the callback the current line will be in C<$_>.

=cut

sub Path::Class::File::each {
  my $self = shift;
  my @opt  = @_;
  my $cb   = pop @opt;

  my $iter = $self->iterator( @opt );
  while ( defined( local $_ = $iter->() ) ) {
    $cb->();
  }
}

1;
__END__

=head1 DEPENDENCIES


=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Andy Armstrong C<< <andy@hexten.net> >>. All
rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
