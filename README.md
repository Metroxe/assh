# assh

Auto-reconnecting SSH with persistent tmux sessions.

Open a terminal, run `assh myserver`, and forget about it. If the connection drops or the server reboots, assh waits for it to come back and reconnects to the same tmux session. Each terminal gets its own session that persists for the life of that terminal window.

## How it works

1. Generates a unique tmux session name (`assh-<pid>`) tied to the terminal's shell PID — stable for the life of that terminal, unique across terminals
2. SSHs into the host and runs `tmux new-session -As <session>` which creates the session if it doesn't exist, or reattaches if it does
3. Uses `ServerAliveInterval` to detect dead connections within 30 seconds
4. When SSH exits, polls the host every 10 seconds until it's reachable again, then reconnects to the same tmux session

Normal SSH handles brief latency. The reconnect loop handles server reboots, network outages, and laptop sleep/wake cycles.

## Install

```bash
git clone https://github.com/Metroxe/assh.git ~/Documents/projects/assh
```

Then add an alias to your shell config:

**zsh** (`~/.zshrc`):
```bash
echo 'alias assh="~/Documents/projects/assh/assh.sh"' >> ~/.zshrc
source ~/.zshrc
```

**bash** (`~/.bashrc` or `~/.bash_aliases`):
```bash
echo 'alias assh="~/Documents/projects/assh/assh.sh"' >> ~/.bash_aliases
source ~/.bash_aliases
```

## Usage

```bash
assh myserver          # uses ~/.ssh/config alias
assh user@host         # direct host
assh -p 2222 myserver  # with SSH flags
```

## Requirements

- `ssh` on the client
- `tmux` on the server
