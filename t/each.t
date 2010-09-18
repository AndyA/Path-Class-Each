#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 4;

use Path::Class;
use Path::Class::Each;

for my $opt ( [], [ chomp => 1 ] ) {
  my $file = file( 't', 'data', 'lines' );

  my @want = $file->slurp( @$opt );

  {
    my @got = ();

    $file->each( @$opt, sub { push @got, $_ } );
    is_deeply \@got, \@want, "lines OK: each";
  }

  {
    my @got = ();

    my $iter = $file->iterator( @$opt );
    while ( defined( my $line = $iter->() ) ) {
      push @got, $line;
    }
    is_deeply \@got, \@want, "lines OK: iterator";
  }
}
