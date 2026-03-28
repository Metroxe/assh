#!/usr/bin/env bash
# assh installer — injects the assh function into your shell config

FUNC='
assh() {
    if [[ $# -eq 0 ]]; then echo "Usage: assh <ssh-args>"; return 1; fi
    local SESSION="assh-$$"
    echo "[$SESSION] Connecting..."
    while true; do
        ssh -o ServerAliveInterval=10 -o ServerAliveCountMax=3 "$@" "tmux new-session -As $SESSION"
        echo "[$SESSION] Disconnected. Waiting for host..."
        until ssh -o ConnectTimeout=5 -o BatchMode=yes "$@" true &>/dev/null; do sleep 10; done
        echo "[$SESSION] Host is back. Reconnecting..."
    done
}'

# Detect shell config
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
    RC="$HOME/.zshrc"
elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == */bash ]]; then
    RC="$HOME/.bashrc"
else
    echo "Unsupported shell. Paste the function manually."
    exit 1
fi

# Remove old assh function/alias if present
if grep -q 'assh' "$RC" 2>/dev/null; then
    sed -i.bak '/# --- assh start ---/,/# --- assh end ---/d' "$RC"
    sed -i.bak '/alias assh=/d' "$RC"
    echo "Removed old assh config from $RC"
fi

# Install
cat >> "$RC" << 'ASSH'
# --- assh start ---
assh() {
    if [[ $# -eq 0 ]]; then echo "Usage: assh <ssh-args>"; return 1; fi
    local SESSION="assh-$$"
    echo "[$SESSION] Connecting..."
    while true; do
        ssh -o ServerAliveInterval=10 -o ServerAliveCountMax=3 "$@" "tmux new-session -As $SESSION"
        echo "[$SESSION] Disconnected. Waiting for host..."
        until ssh -o ConnectTimeout=5 -o BatchMode=yes "$@" true &>/dev/null; do sleep 10; done
        echo "[$SESSION] Host is back. Reconnecting..."
    done
}
# --- assh end ---
ASSH

echo "Installed assh into $RC"
echo "Run: source $RC"
