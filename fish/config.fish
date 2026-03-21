# 1. Ensure Fish finds the 'sesh' binary
fish_add_path ~/go/bin

function fish_prompt -d "Write out the prompt"
    printf '%s@%s %s%s%s > ' $USER $hostname (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    set fish_greeting

    if type -q starship
        starship init fish | source
    end

    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'

    # ---------------------------------------------------------
    # SESH FUNCTION: SHOWING SESSION NAME + LAUNCH PATH
    # ---------------------------------------------------------
    function sesh-sessions
        # 1. Get Tmux sessions with: Name | Icon | Launch Path | Windows
        # #{session_name} is the ID, #{session_path} is the folder it started in
        set -l tmux_sessions (tmux list-sessions -F "#{session_name} 🖥️  #{session_path} (#{session_windows} windows)" 2>/dev/null)

        # 2. Get Zoxide paths with a folder icon
        set -l zoxide_paths (sesh list -z | sed 's/^/📁 /')

        # 3. Combine and pick via FZF
        set -l selected (printf "%s\n" $tmux_sessions $zoxide_paths | \
            fzf --height 40% \
                --reverse \
                --border \
                --prompt '⚡ ' \
                --header '🖥️ Tmux Sessions (Name + Path) | 📁 Recent Paths' \
                --pointer '▶')

        if test -n "$selected"
            # 4. Extraction Logic:
            # If it's a tmux session, we need the first word (the name).
            # If it's a folder, we need the path (everything after the 📁 icon).
            if string match -q "📁 *" "$selected"
                # It's a folder: Remove the icon and leading space
                set -l target (string sub -s 3 "$selected")
                sesh connect "$target"
            else
                # It's a tmux session: Take the first word (the session name)
                set -l target (echo "$selected" | cut -d' ' -f1)
                sesh connect "$target"
            end
        end
    end

    bind \ct sesh-sessions
end

if type -q zoxide
    zoxide init fish | source
end

function dev
    # 1. Get the current directory name to use as a session name
    # We use 'string replace' to make sure the name is tmux-friendly (no dots)
    set -l session_name (basename (pwd) | string replace -a "." "_")

    # 2. Check if the session already exists
    if tmux has-session -t "$session_name" 2>/dev/null
        if test -n "$TMUX"
            tmux switch-client -t "$session_name"
        else
            tmux attach-session -t "$session_name"
        end
        return
    end

    # 3. If it doesn't exist, create it (Detached)
    tmux new-session -d -s "$session_name" -n nvim

    # 4. Setup Windows
    # Window 1: nvim
    tmux send-keys -t "$session_name":nvim "nvim ." C-m

    # Window 2: opencode
    tmux new-window -t "$session_name" -n opencode
    tmux send-keys -t "$session_name":opencode opencode C-m

    # Window 3: terminal
    tmux new-window -t "$session_name" -n terminal

    # 5. Focus the first window
    tmux select-window -t "$session_name":nvim

    # 6. Attach or Switch
    if test -n "$TMUX"
        tmux switch-client -t "$session_name"
    else
        tmux attach-session -t "$session_name"
    end
end

# opencode
fish_add_path /home/roses/.opencode/bin

# Created by `pipx` on 2026-02-14 14:37:45
set PATH $PATH /home/roses/.local/bin
