    if [[ $# -eq 0 ]]; then echo "Usage: assh <ssh-args>"; return 1; fi
    local SESSION="assh-$$"
    echo "[$SESSION] Connecting..."
    while true; do
        ssh -t -o ServerAliveInterval=10 -o ServerAliveCountMax=3 "$@" "tmux new-session -As $SESSION"
        echo "[$SESSION] Disconnected. Waiting for host..."
        until ssh -o ConnectTimeout=5 -o BatchMode=yes "$@" true &>/dev/null; do sleep 10; done
        echo "[$SESSION] Host is back. Reconnecting..."
    done
