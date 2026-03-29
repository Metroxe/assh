    if [[ $# -eq 0 ]]; then echo "Usage: assh <ssh-args>"; return 1; fi
    local SESSION="assh-$$"
    echo "[$SESSION] Connecting..."
    while true; do
        ssh -t -o ServerAliveInterval=5 -o ServerAliveCountMax=3 "$@" "tmux new-session -As $SESSION"
        [[ $? -eq 0 ]] && break
        printf '\n\n\n'
        echo "[$SESSION] Disconnected. Reconnecting..."
        local delay=0.5
        until ssh -o ConnectTimeout=5 -o BatchMode=yes "$@" true &>/dev/null; do
            echo "[$SESSION] Host unreachable, retrying in ${delay}s..."
            sleep $delay
            delay=$(awk "BEGIN {d=$delay*1.5; print (d<30?d:30)}")
        done
        echo "[$SESSION] Host is back. Reconnecting..."
    done
