libtmux
=======

A library for interacting with tmux


TECH TODO
---------

* follow up on pull request of LICENSE
* create module skeleton
* copy write code from chicks-home/bin/infect
* start read code
* creae expect-like language for tying it together
* look for other expect-like modules to build on

Reference
---------

* writing to tmux is done with: ` tmux send-keys -t $TARGET 'echo tmux-send-foo' C-m `
* reading from tmux is done with  ` tmux capture-pane ; tmux save-buffer - `
