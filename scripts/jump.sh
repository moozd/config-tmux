#!/usr/bin/env bash
if [ -z $1 ]; then
	exit 0
fi
selected=$(tmux list-windows -F "#I:#W" | grep -w $1 | cut -d":" -f1)
if [ "$selected" != "" ]; then
	tmux select-window -t $selected
	exit 0
fi

tmux new-window "$1" 

exit 0
