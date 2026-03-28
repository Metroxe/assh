#!/usr/bin/env bash
# assh installer — fetches assh.sh from GitHub and injects it as a shell function

RAW_URL="https://raw.githubusercontent.com/Metroxe/assh/master/assh.sh"

BODY=$(curl -fsSL "$RAW_URL") || { echo "Failed to fetch assh.sh"; exit 1; }

# Detect shell config
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
    RC="$HOME/.zshrc"
elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == */bash ]]; then
    RC="$HOME/.bashrc"
else
    echo "Unsupported shell. Paste the function manually."
    exit 1
fi

# Remove old assh if present
if grep -q '# --- assh start ---' "$RC" 2>/dev/null; then
    sed -i.bak '/# --- assh start ---/,/# --- assh end ---/d' "$RC"
    echo "Removed old assh config from $RC"
fi

# Wrap the function body and append
{
    echo '# --- assh start ---'
    echo 'assh() {'
    echo "$BODY"
    echo '}'
    echo '# --- assh end ---'
} >> "$RC"

echo "Installed assh into $RC"
echo "Run: source $RC"
