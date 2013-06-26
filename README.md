libtmux
=======

A library for interacting with tmux


TECH TODO
---------

* start read code
* look for other expect-like modules to build on
* create expect-like language for tying it together

Reference
---------

* writing to tmux is done with: ` tmux send-keys -t $TARGET 'echo tmux-send-foo' C-m `
* reading from tmux is done with  ` tmux capture-pane ; tmux save-buffer - `
