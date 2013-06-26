package Term::TmuxExpect;

use strict;
use warnings;
use Term::Multiplexed qw(multiplexed attached multiplexer);
use Data::Dumper; # just for debugging

use vars qw($VERSION @EXPORT @EXPORT_OK @ISA);
$VERSION = "0.3";

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

sub new {
	my $class = shift;
	my $self = {
		_target		=> shift,
		_create		=> shift || 0,
	};

	die "not in tmux" unless in_tmux();

	bless $self, $class;

	print "Target is $self->{_target} ";
	if ($self->{_create}) {
		print "with CREATE\n";
		die "unimplemented: create tab";
	} else {
		print "which should already exist\n";
		$self->sendln("# tmux_expect A probe");
		$self->sendln("# tmux_expect B probe");
		$self->timeout('10s');
#		$self->expect_last('probe$');
#		$self->expect_last("^chicks");
	}

	# get line count
	$self->sendln("tput lines");
	my $row_count = $self->read_prev();
	die "bad row_count '$row_count'" unless $row_count =~ /^\d+$/;
	$self->{_rows} = $row_count;
	print Dumper($self);

	# boilerplate
	return $self;
}

sub read_prev {
	my ($obj) = @_;
	die "not a ref" unless ref $obj;
	my @lines = $obj->read_all();
	my $last = pop @lines;
	my $prev = pop @lines;
	print "returning $prev\n";
	return $prev;
}

sub read_last {
	my ($obj) = @_;
	die "not a ref" unless ref $obj;
	my @lines = $obj->read_all();
	my $last = pop @lines;
	print "returning $last\n";
	return $last;
}

sub read_all {
	my ($obj) = @_;
	die "not a ref" unless ref $obj;
	my $target = $obj->{_target};

	# sleep
	print "sleeping 1s to let the shell catch up\n";
	sleep(1);

	my $cmd = "tmux capture-pane -t '$target' ; tmux save-buffer -";
	print "running $cmd\n";
	my $out = `$cmd`;
	my $chars = length($out);
	print "got $chars from $cmd\n";
	my @lines = split(/\n/,$out);
	print "returning " . scalar @lines . " lines\n";
	return @lines;
}

sub timeout {
	my ($obj,$timeout) = @_;
	die "not a ref" unless ref $obj;
	# TODO: validation
	# TODO: translate into millis
	$obj->{_timeout} = $timeout;
	return $timeout;
}

sub sendkeys {
	my ($obj,@send_strings) = @_;
	die "not a ref" unless ref $obj;
	my $target = $obj->{_target};
	die "not in tmux" unless in_tmux();
	die "no target" unless length $target;
	die "nothing to send" unless scalar @send_strings;

	my $send_string = join (" ",@send_strings);
	my $cmd = "tmux send-keys -t '$target' $send_string";
#	print "running $cmd\n";
	system($cmd);
}

sub sendln {
	my ($obj,$send_string) = @_;
	die "not a ref" unless ref $obj;
	my $target = $obj->{_target};
	print "sending '$send_string' to '$target'\n";
	$obj->sendkeys("'$send_string' C-m");
}

sub expect_last {
	my ($obj,$match,$timeout) = @_;
	die "not a ref" unless ref $obj;
	my $target = $obj->{_target};
	# 18 * reading from tmux is done with  ` tmux capture-pane ; tmux save-buffer - `
	die "unimplemented TIMEOUT";
}

sub expect {
	my ($target,$match) = @_;
	die "not in tmux" unless in_tmux();
	# 18 * reading from tmux is done with  ` tmux capture-pane ; tmux save-buffer - `
	die "unimplemented expect()";
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
