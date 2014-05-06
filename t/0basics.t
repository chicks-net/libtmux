#!/usr/bin/perl -w

use Test::Simple tests => 2;

ok( 1 + 1 == 2 );

use Term::TmuxExpect;

my $remote = new Term::TmuxExpect('NOT_A_VIABLE_NAME_FOR_A_TMUX_SESSION');
ok( $remote == undef );
