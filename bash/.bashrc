sesh-sessions() {
    # 1. Get Tmux sessions with: Name | Icon | Launch Path | Windows
    local tmux_sessions
    tmux_sessions=$(tmux list-sessions -F "#{session_name} 🖥️  #{session_path} (#{session_windows} windows)" 2>/dev/null)

    # 2. Get Zoxide paths with a folder icon
    local zoxide_paths
    zoxide_paths=$(sesh list -z | sed 's/^/📁 /')

    # 3. Combine and pick via FZF
    local selected
    selected=$(printf "%s\n" "$tmux_sessions" "$zoxide_paths" | \
        fzf --height 40% \
            --reverse \
            --border \
            --prompt '⚡ ' \
            --header '🖥️ Tmux Sessions (Name + Path) | 📁 Recent Paths' \
            --pointer '▶')

    if [[ -n "$selected" ]]; then
        # 4. Extraction Logic
        if [[ "$selected" == 📁\ * ]]; then
            # It's a folder: Remove the icon and leading space
            local target="${selected:2}"
            sesh connect "$target"
        else
            # It's a tmux session: Take the first word (the session name)
            local target="${selected%% *}"
            sesh connect "$target"
        fi
    fi
}

# Bind Ctrl+T to sesh-sessions
bind -x '"\C-t": sesh-sessions'
