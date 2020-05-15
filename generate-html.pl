#!/usr/bin/env perl
use v5.20;
use warnings;
use diagnostics;
use Path::Class;

my $filename_default = 'tmp/template.html';

my $filename = shift;
if ( not defined $filename ) {
  say "Input file is not specified. -> Use $filename_default";
  $filename = $filename_default;
}

my $files = qx'ls *.pde';
$files =~ s/\s+/ /g;                     # not necessary
$files =~ s/\s+$//g;                     # necessary

my $html = (file $filename)->slurp();
$html =~ s/(<canvas .+?)".*?"/$1"$files"/sg;
say $html;
