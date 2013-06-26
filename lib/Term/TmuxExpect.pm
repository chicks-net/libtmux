package Term::TmuxExpect

use strict;
use warnings;
use Term::Multiplexed qw(multiplexed attached multiplexer);

use vars qw($VERSION @EXPORT @EXPORT_OK @ISA);
$VERSION = "0.0.1";

BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = ();
    @EXPORT_OK = qw(send expect);
}

BEGIN {
	if (multiplexed) {
		say "Using " . multiplexer . " as terminal multiplexer";
		say "Currently " . (attached ? : "not ") . "attached.";
	}
}

sub send {
}

sub expect {
}

1;

__END__

=head1 NAME

Term::TmuxExpect - expect for tmux

=head1 SYNOPSIS

  use Term::TmuxExpect qw(send receive);

=head1 DESCRIPTION

I want to automate interative scripts that need to be run on dozens or hundreds of servers simultaenously.
tmux provides a good environment for doing this automation because you can readily interact with
the automated processes or merely watch them as they work.  Many other features such as output logging are 
available without effort by building on tmux

=head2 EXPORTS

=head3 send

Write commands into a tmux window.

=head3 expect

Read a window until one of several things happens or you time out.

=head1 SEE ALSO

Manpages: screen(1) tmux(1)

=head1 AUTHOR

Christopher Hicks E<lt>chicks.net@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Christopher Hicks

This software is licensed under the same terms as Perl.
