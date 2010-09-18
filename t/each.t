#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;
use Path::Class::Each;

{
  my @obj = ();
  dir( 't' )->each( sub { push @obj, $_ } );
  is_deeply \@obj,
   [ file( 't', '00-load.t' ) . '', file( 't', 'each.t' ) . '' ],
   'dir->each';
}
