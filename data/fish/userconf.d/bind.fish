# bind alt-space to accept autosuggestion
bind alt-space forward-char

# bind alt-enter to accept autosuggestion and run command
bind alt-enter accept-autosuggestion execute

# bind alt-comma to copy previous word and paste it
bind alt-comma backward-kill-bigword yank yank
