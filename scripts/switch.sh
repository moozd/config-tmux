# !/usr/bin/env bash

# TODO: read this from a config file
dirs=$(find ~/.config/ ~/work ~/personal/ ~/personal/tools/ -mindepth 1 -maxdepth 1 -type d -exec test -d {}/.git \; -print | tr " " "\n")
apps=$(tmuxinator list -n | tail -n +2 | while read i; do echo ":$i"; done)
jumps=$(
	find ~/.config/tmux/scripts -type f -name "_*.sh" | while read -r f; do basename $f | sed 's/^_/:/' | sed 's/\.sh$//'; done | tr ' ' '\n'
)

selected=$(echo -e "$apps\n$jumps\n$dirs" | fzf)

if [[ -z $selected ]]; then
	exit 0
fi

if [[ ${selected:0:1} == ":" ]]; then
	selected=$(echo $selected | cut -d ":" -f2)

	if [ -e "$HOME/.config/tmux/scripts/_$selected.sh" ]; then
		"$HOME/.config/tmux/scripts/_$selected.sh"
		exit 0
	fi
	tmuxinator start $selected
	exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -s $selected_name -c $selected $EDITOR
	exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
	tmux new-session -ds $selected_name -c $selected $EDITOR
fi

tmux switch-client -t $selected_name

exit 0
