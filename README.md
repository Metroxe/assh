# assh

Auto-reconnecting SSH with persistent tmux sessions.

Open a terminal, run `assh myserver`, and forget about it. If the connection drops or the server reboots, assh waits for it to come back and reconnects to the same tmux session. Each terminal gets its own session that persists for the life of that terminal window.

## Install

```bash
bash <(curl -s https://raw.githubusercontent.com/Metroxe/assh/master/install.sh)
```

Then reload your shell:

```bash
source ~/.zshrc   # or source ~/.bashrc
```

## How it works

1. Generates a unique tmux session name (`assh-<pid>`) tied to the terminal's shell PID — stable for the life of that terminal, unique across terminals
2. SSHs into the host and runs `tmux new-session -As <session>` which creates the session if it doesn't exist, or reattaches if it does
3. Uses `ServerAliveInterval` to detect dead connections within 30 seconds
4. When SSH exits, polls the host every 10 seconds until it's reachable again, then reconnects to the same tmux session

Normal SSH handles brief latency. The reconnect loop handles server reboots, network outages, and laptop sleep/wake cycles.

## Usage

```bash
assh myserver          # uses ~/.ssh/config alias
assh user@host         # direct host
assh -p 2222 myserver  # with SSH flags
```

## Uninstall

Remove the block between `# --- assh start ---` and `# --- assh end ---` from your `~/.zshrc` or `~/.bashrc`.

## Requirements

- `ssh` on the client
- `tmux` on the server
