#!/usr/bin/env perl

use Test::More tests => 1;

use Moose;
BEGIN { use_ok 'MooseX::AttributeShortcuts' }

diag("Testing MooseX-AttributeShortcuts $MooseX::AttributeShortcuts::VERSION, Perl $], $^X");
