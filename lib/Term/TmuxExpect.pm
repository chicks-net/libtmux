package Term::TmuxExpect;

use strict;
use warnings;
use Term::Multiplexed qw(multiplexed attached multiplexer);

use vars qw($VERSION @EXPORT @EXPORT_OK @ISA);
$VERSION = "0.0.1";

BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = ();
    @EXPORT_OK = qw(sendkeys sendln expect);
}

BEGIN {
	if (multiplexed) {
		print "FYI: Using " . multiplexer . " as terminal multiplexer ";
		print "and currently " . (attached() ? '' : "not ") . "attached.\n";
	} else {
		print "not multiplexed, this module won't do you much good outside fo tmux\n";
	}
}

# tmux send-keys -t $TARGET 'echo foo' C-m

sub sendkeys {
	my ($target,@send_strings) = @_;
	die "not in tmux" unless in_tmux();
	die "no target" unless length $target;
	die "no send_string" unless length $target;

	my $send_string = join (" ",@send_strings);
	my $cmd = "tmux send-keys -t '$target' $send_string";
	print "running $cmd\n";
	system($cmd);
}

sub sendln {
	my ($target,$send_string) = @_;
	print "sending '$send_string' to '$target'\n";
	sendkeys($target,"'$send_string' C-m");
}

sub expect {
	die "not in tmux" unless in_tmux();
}

sub in_tmux {
	return 1 if multiplexed and multiplexer eq 'tmux' and attached;
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
