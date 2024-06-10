# !/usr/bin/env bash

dirs=$(find ~/.config/ ~/work ~/personal/ -mindepth 1 -maxdepth 1 -type d | tr " " "\n")
apps=$(tmuxinator list -n | tail -n +2 | while read i; do echo ":$i"; done)

selected=$(echo -e "$dirs\n$apps" | fzf)

if [[ -z $selected ]]; then
    exit 0
fi

if [[ ${selected:0:1} == ":" ]]; then
    tmuxinator start $(echo $selected | cut -d ":" -f2)
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
