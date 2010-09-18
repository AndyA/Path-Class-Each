#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 9;

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

  {
    my @got = ();

    while ( defined( my $line = $file->next( @$opt ) ) ) {
      push @got, $line;
    }
    is_deeply \@got, \@want, "lines OK: next";
  }
}

{
  my $dir = dir( 't', 'data' );
  my @want = (
    file( 't', 'data', 'foo', 'f1' ) . '',
    file( 't', 'data', 'foo', 'f2' ) . '',
    file( 't', 'data', 'lines' ) . '',
  );

  {
    my @got  = ();
    my $iter = $dir->iterator;
    while ( defined( my $file = $iter->() ) ) {
      push @got, $file;
    }

    is_deeply [ sort @got ], \@want, 'dir: iterator';
  }

  {
    my @got = ();
    $dir->each( sub { push @got, $_ } );
    is_deeply [ sort @got ], \@want, 'dir: each';
  }
  {
    my @got = ();

    while ( defined( my $file = $dir->next_file ) ) {
      push @got, $file;
    }
    is_deeply [ sort @got ], \@want, 'dir: next_file';
  }
}

