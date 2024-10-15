# !/usr/bin/env bash

# TODO: read this from a config file

dirs=$(find ~/work ~/personal ~/.config -mindepth 1 -maxdepth 1 -type d | tr " " "\n")
apps=$(tmuxinator list -n | tail -n +2 | while read i; do printf ":$i\n"; done)
jumps=$(
	find ~/.config/tmux/scripts -type f -name "_*.sh" | while read -r f; do basename $f | sed 's/^_/:/' | sed 's/\.sh$//'; done | tr ' ' '\n'
)

selected=$(printf "$apps\n$jumps\n$dirs" | fzf)

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

# commands=$(printf "[open] $EDITOR neohub lazygit lazydocker" | tr " " "\n")
# command=$(printf "$commands" | fzf)
# if [[ $command == '[open]' ]]; then
# 	command=""
# fi

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -s $selected_name -c $selected
	exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
	tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name

exit 0
