#!/usr/bin/env bash
# assh — auto-reconnecting ssh + tmux
# Usage: assh <anything you'd pass to ssh>
# Examples: assh myserver
#           assh user@host
#           assh -p 2222 myserver

if [[ $# -eq 0 ]]; then
    echo "Usage: assh <ssh-args>"
    exit 1
fi

SESSION="assh-$$"

echo "[$SESSION] Connecting..."

while true; do
    ssh -o ServerAliveInterval=10 -o ServerAliveCountMax=3 \
        "$@" "tmux new-session -As $SESSION"

    echo "[$SESSION] Disconnected. Waiting for host..."
    until ssh -o ConnectTimeout=5 -o BatchMode=yes "$@" true &>/dev/null; do
        sleep 10
    done
    echo "[$SESSION] Host is back. Reconnecting..."
done
