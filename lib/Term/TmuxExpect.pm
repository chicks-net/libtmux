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
    @EXPORT_OK = qw(sendkeys sendln expect expectlast);
}

BEGIN {
	if (multiplexed) {
		print "FYI: Using " . multiplexer . " as terminal multiplexer ";
		print "and currently " . (attached() ? '' : "not ") . "attached.\n";
	} else {
		print "not multiplexed, this module won't do you much good outside fo tmux\n";
	}
}

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
	# 18 * reading from tmux is done with  ` tmux capture-pane ; tmux save-buffer - `
	die "unimplemented";
}

sub expectlast {
	die "not in tmux" unless in_tmux();
	# 18 * reading from tmux is done with  ` tmux capture-pane ; tmux save-buffer - `
	die "unimplemented";
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

=head3 sendkeys

Write anything into a tmux window.  It does not quote anything so you may need to.

=head3 sendln

Write a command into a tmux window.  sendln quotes the argument.  It only looks at one command.  And it appends the newline.

=head3 expect

Read a window until one of several things happens or you time out.

=head1 SEE ALSO

Manpages: screen(1) tmux(1) expect(1)

=head1 AUTHOR

Christopher Hicks E<lt>chicks.net@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Christopher Hicks

This software is licensed under the same terms as Perl.
