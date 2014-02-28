# NAME

Term::TmuxExpect - expect for tmux

# SYNOPSIS

    use Term::TmuxExpect;

    # use it with an existing pane
    my $existing_pane_name = 'boo';
    my $boo = new Term::TmuxExpect($existing_pane_name);

    $boo->sendln('echo test from the actual script');
    $boo->expect_prev('test from the actual script$') or die "no echo";
    $boo->{debug} = 1;        # cut debugging on
    $boo->expect_last('^chicks') or die "no chicks";
    $boo->{debug} = 0;        # cut debugging off



# DESCRIPTION

I want to automate interative scripts that need to be run on dozens or hundreds of servers simultaenously.
tmux provides a good environment for doing this automation because you can readily interact with
the automated processes or merely watch them as they work.  Many other features such as output logging are 
available without effort by building on tmux

## METHODS

### new

Create a new object.  Call with an argument of the pane name.  It doesn't handle creating new pane's yet.

### timeout

Set the timeout for expect operations.  The format of the argument is digits followed by 's' for seconds, 'ms' for millisecons' and 'us' for microseconds.  So '5s', '10ms', and '100us' would be valid values.  Naturally '10s' equals '10000ms' equals '10000000us'.

### in\_tmux

Are we in tmux and actually attached?  Othwerise you are out of luck.

### sendln

Write a command into a tmux pane.  sendln quotes the argument.  It only looks at one command.  And it appends the newline.

### sendkeys

Write anything inta a tmux pane.  Like sendlin(() without the implicit newline.

### expect\_prev

Check a pane until the next to last line matches or you time out.

### expect\_last

Check a pane until the last line matches or you time out.

### expect

Read a window until one of several things happens or you time out.  UNIMPLEMENTED.

### read\_last

Get the last line from the pane.

### read\_prev

Get the next to last line -- as in 'previous' -- in the pane.

# TODO

- write some tests
- write some tests

# SEE ALSO

Man pages: screen(1) tmux(1) expect(1) <Net::Telnet(3pm)>

# AUTHOR

Christopher Hicks <chicks.net@gmail.com>

# COPYRIGHT AND LICENSE

Copyright 2013 Christopher Hicks

This software is licensed under the same terms as Perl.
