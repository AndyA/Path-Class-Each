#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 2;

use Path::Class;
use Path::Class::Each;

for my $opt ( [], [ chomp => 1 ] ) {
  my $file = file( 't', 'data', 'lines' );

  my @want = $file->slurp( @$opt );
  my @got  = ();

  $file->each( @$opt, sub { push @got, $_ } );
  is_deeply \@got, \@want, "lines OK";
}
