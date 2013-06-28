package Term::TmuxExpect;

use strict;
use warnings;
use Term::Multiplexed qw(multiplexed attached multiplexer);
use Data::Dumper; # just for debugging
use Time::HiRes qw(gettimeofday tv_interval usleep);

use vars qw($VERSION @EXPORT @EXPORT_OK @ISA);
$VERSION = "0.3";

BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = ();
    @EXPORT_OK = ();
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
		debug		=> 0,
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
		usleep(50);
		$self->timeout('10s');
		die "probe fail" unless $self->expect_prev('B probe$');
#		$self->expect_last("^chicks");
	}

	# get line count
	$self->sendln("tput lines");
	$self->timeout('3s');
	print "sleeping 1s to let the shell catch up\n";
	sleep(1);
	die "not at a propmt" unless $self->expect_last('[$#]$');
	my $row_count = $self->read_prev();
	die "bad row_count '$row_count'" unless $row_count =~ /^\d+$/;
	$self->{_rows} = $row_count;
#	print Dumper($self);

	# boilerplate
	return $self;
}

sub read_prev {
	my ($obj) = @_;
	die "not a ref" unless ref $obj;
	my @lines = $obj->read_all(2);
	my $last = pop @lines;
	my $prev = pop @lines;
#	print "returning $prev\n";
	return $prev;
}

sub read_last {
	my ($obj) = @_;
	die "not a ref" unless ref $obj;
	my @lines = $obj->read_all(1);
	my $last = pop @lines;
#	print "returning $last\n";
	return $last;
}

sub read_all {
	my ($obj,$lines_desired) = @_;
	die "not a ref" unless ref $obj;
	my $target = $obj->{_target};
	my $actual_rows = $obj->{_rows};

	usleep(100); # give things a chance to catch up
	my $cmd = "tmux capture-pane -t '$target' ; tmux save-buffer -";
	if (defined $lines_desired and defined $actual_rows) {
		my $got_something = 0;
		my $start_line = $actual_rows - $lines_desired;
		my @lines;
		until ($got_something) {
			$start_line -= 10; # go further back
			print "start_line=$start_line\n" if $obj->{debug};
			$cmd = "tmux capture-pane -t '$target' -S $start_line ; tmux save-buffer -";
			my $out = `$cmd`;
			my $chars = length($out);
#			print "got $chars from $cmd\n";
			@lines = split(/\n/,$out);

			$got_something = grep { length($_) } @lines;
#			print "exiting loop with got_something=$got_something\n";
		}
		print "returning " . scalar @lines . " lines\n" if $obj->{debug};
		return @lines;
	} else {
		# really all
		print "running $cmd\n" if $obj->{debug};
		my $out = `$cmd`;
		my $chars = length($out);
#		print "got $chars from $cmd\n";
		my @lines = split(/\n/,$out);
		print "returning " . scalar @lines . " lines\n" if $obj->{debug};
		return @lines;
	}
}

sub timeout {
	my ($obj,$timeout) = @_;
	die "not a ref" unless ref $obj;
	die "bad timeout '$timeout'" unless $timeout =~ /^(\d+)(s|ms|us)$/;
	my $size = $1;
	my $units = $2;
	my $seconds = 1; # default timeout!
	if ($units eq 's') {
		$seconds = $size;
	} elsif ($units eq 'ms') {
		$seconds = $size / 1000;
	} elsif ($units eq 'us') {
		$seconds = $size / 1000 / 1000;
	} else {
		die "units '$units' unrecognized";
	}

	$obj->{_timeout} = $seconds;
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
#	print "running $cmd\n" if $obj->{debug};
	system($cmd);
}

sub sendln {
	my ($obj,$send_string) = @_;
	die "not a ref" unless ref $obj;
	my $target = $obj->{_target};
	print "sending '$send_string' to '$target'\n" if $obj->{debug};
	$obj->sendkeys("'$send_string' C-m");
}

sub expect_prev {
	my $obj = shift;
	die "not a ref" unless ref $obj;
	my $match = shift;
	my $timeout = shift || $obj->{_timeout};

	my $start = [gettimeofday()];
	my $success = 0;
	my $tries = 0;
	my $time_running = tv_interval ( $start, [gettimeofday] );
	while ($time_running < $timeout) {
		$tries++;
		my $last_line = $obj->read_prev();
		die unless defined $last_line;
		if ($last_line =~ /$match/) {
			$success = 1;
			last;
		}
		$time_running = tv_interval ( $start, [gettimeofday] );
#		print "$time_running\n";
	}
	if ($success) {
		print "matched '$match' in expect_last() with $tries tries after ". format_seconds($time_running) . "s\n";
		return 1;
	}
	unless ($success) {
		print "NO match for '$match' in expect_last() with $tries tries after ". format_seconds($time_running) . "s\n";
		return 0;
	}
	die "never";
}

sub expect_last {
	my $obj = shift;
	die "not a ref" unless ref $obj;
	my $match = shift;
	my $timeout = shift || $obj->{_timeout};

	my $start = [gettimeofday()];
	my $success = 0;
	my $tries = 0;
	my $time_running = tv_interval ( $start, [gettimeofday] );
	while ($time_running < $timeout) {
		$tries++;
		my $last_line = $obj->read_last();
		die unless defined $last_line;
		if ($last_line =~ /$match/) {
			$success = 1;
			last;
		}
		$time_running = tv_interval ( $start, [gettimeofday] );
#		print "$time_running\n";
	}
	if ($success) {
		print "matched '$match' in expect_last() with $tries tries after ". format_seconds($time_running) . "s\n";
		return 1;
	}
	unless ($success) {
		print "NO match for '$match' in expect_last() with $tries tries after ". format_seconds($time_running) . "s\n";
		print join("\n",$obj->read_all(3));
		print "\n\n";
		return 0;
	}
	die "never";
}

sub expect {
	my ($obj,$match,$timeout) = @_;
	die "not a ref" unless ref $obj;
	die "unimplemented expect()"; # TODO: implement something
}

#
# utility functions
#

sub format_seconds {
	my ($raw_seconds) = @_;
	return sprintf("%.8f",$raw_seconds);
}

sub in_tmux {
	return 1 if multiplexed and multiplexer eq 'tmux' and attached;
}

1;

__END__

=head1 NAME

Term::TmuxExpect - expect for tmux

=head1 SYNOPSIS

   use Term::TmuxExpect;

   # use it with an existing pane
   my $existing_pane_name = 'boo';
   my $boo = new Term::TmuxExpect($existing_pane_name);

   $boo->sendln('echo test from the actual script');
   $boo->expect_prev('test from the actual script$') or die "no echo";
   $boo->{debug} = 1;        # cut debugging on
   $boo->expect_last('^chicks') or die "no chicks";
   $boo->{debug} = 0;        # cut debugging off


=head1 DESCRIPTION

I want to automate interative scripts that need to be run on dozens or hundreds of servers simultaenously.
tmux provides a good environment for doing this automation because you can readily interact with
the automated processes or merely watch them as they work.  Many other features such as output logging are 
available without effort by building on tmux

=head2 METHODS

=head3 new

Create a new object.  Call with an argument of the pane name.  It doesn't handle creating new pane's yet.

=head3 timeout

Set the timeout for expect operations.  The format of the argument is digits followed by 's' for seconds, 'ms' for millisecons' and 'us' for microseconds.  So '5s', '10ms', and '100us' would be valid values.  Naturally '10s' equals '10000ms' equals '10000000us'.

=head3 in_tmux

Are we in tmux and actually attached?  Othwerise you are out of luck.

=head3 sendln

Write a command into a tmux pane.  sendln quotes the argument.  It only looks at one command.  And it appends the newline.

=head3 sendkeys

Write anything inta a tmux pane.  Like sendlin(() without the implicit newline.

=head3 expect_prev

Check a pane until the next to last line matches or you time out.

=head3 expect_last

Check a pane until the last line matches or you time out.

=head3 expect

Read a window until one of several things happens or you time out.  UNIMPLEMENTED.

=head3 read_last

Get the last line from the pane.

=head3 read_prev

Get the next to last line -- as in 'previous' -- in the pane.

=head1 SEE ALSO

Manpages: screen(1) tmux(1) expect(1)

=head1 AUTHOR

Christopher Hicks E<lt>chicks.net@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Christopher Hicks

This software is licensed under the same terms as Perl.
