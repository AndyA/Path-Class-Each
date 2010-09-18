package Path::Class::Each;

use warnings;
use strict;

use Carp qw( croak );
use Path::Class;

our $VERSION = '0.01';

=head1 NAME

Path::Class::Each - Iterator lines in a file

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

  # Callback interface
  file( 'foo', 'bar' )->each(
    sub {
      print "Line: $_\n";
    }
  );

=head1 DESCRIPTION

=head1 INTERFACE

=head2 C<< Path::Class::File->iterator >>

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

=head2 C<< Path::Class::File->each >>

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
