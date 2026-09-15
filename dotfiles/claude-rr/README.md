# Claude Code Multi-Account Switcher

Use multiple Claude Code accounts truly **concurrently**.

## Installation

```bash
./init.sh
source ~/.zshrc
```

The `init.sh` script automatically creates convenient aliases for all commands:

- `claude-rr` → `claude-rr.sh`
- `claude-usage` → `python3 claude-usage.py`

After installation, you can run these commands from anywhere in your terminal!

## `claude-rr`

`claude-rr` gives every account its own isolated
`CLAUDE_CONFIG_DIR` (own `.claude.json`, `.credentials.json` — the actual
identity), while symlinking the `projects/` folder (where session
transcripts live) to one shared directory. Session transcript files are
named by session ID, so concurrent writes from different accounts never
collide — and because it's a live symlink, not a periodic copy, `--resume`
sees every session from every account immediately, with no separate sync
step.

```bash
# One-time setup per account
claude-rr add work        # opens `claude auth login` for this account only
claude-rr add personal

# Use both at once, in separate terminals — this is genuinely safe now
claude-rr run work
claude-rr run personal --resume   # can resume a session started under "work"

claude-rr list
claude-rr usage                   # usage for every account, doesn't touch any state
# claude-usage does the same thing, as its own command

claude-rr next                    # pick the account with the most session
                                   # headroom and start a fresh session as it
claude-rr next --resume           # same picking logic, but `claude --resume`
claude-rr next -r                 # short form of --resume

claude-rr remove personal         # permanently delete an account (asks to confirm)
claude-rr remove personal -y      # skip the confirmation prompt
```

Tip: add short aliases for accounts you use often, e.g.
`alias cwork="claude-rr run work"`.

## Notes

- Data is stored under `~/.claude-accounts/` (plain `<name>/` + `_shared/`
  layout).
- Each account keeps its own `.claude.json` and `.credentials.json`; only
  `projects/`, `settings.json`, `plugins/`, `shell-snapshots/`,
  `history.jsonl`, `session-env/` are shared (via symlink) across accounts.
- `claude-usage` requires Python 3 (standard library only, no pip install
  needed).
