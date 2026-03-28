    if [[ $# -eq 0 ]]; then echo "Usage: assh <ssh-args>"; return 1; fi
    local SESSION="assh-$$"
    local HOST="${@: -1}"
    echo "[$SESSION] Connecting..."

    # Background title updater — persistent SSH loop streams pane path back
    _assh_title_poller() {
        ssh "$@" "while true; do tmux display-message -p -t '$SESSION' '#{pane_current_path}' 2>/dev/null; sleep 5; done" \
            | while IFS= read -r dir; do
                printf '\033]0;assh: %s:%s\007' "$HOST" "${dir##*/}"
              done
    }

    while true; do
        _assh_title_poller "$@" &
        local POLLER_PID=$!

        ssh -t -o ServerAliveInterval=10 -o ServerAliveCountMax=3 "$@" "tmux new-session -As $SESSION"
        local EXIT=$?

        kill "$POLLER_PID" 2>/dev/null
        wait "$POLLER_PID" 2>/dev/null
        printf '\033]0;\007'

        [[ $EXIT -eq 0 ]] && break
        echo "[$SESSION] Disconnected. Waiting for host..."
        until ssh -o ConnectTimeout=5 -o BatchMode=yes "$@" true &>/dev/null; do sleep 10; done
        echo "[$SESSION] Host is back. Reconnecting..."
    done
