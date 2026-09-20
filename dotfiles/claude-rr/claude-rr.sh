#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$HOME/.claude-accounts"
SHARED_DIR="$BASE_DIR/_shared"

SHARED_ITEMS=(projects settings.json plugins shell-snapshots history.jsonl session-env file-history)

account_dir() { echo "$BASE_DIR/$1"; }

ensure_shared() {
    mkdir -p "$SHARED_DIR/projects" "$SHARED_DIR/plugins" "$SHARED_DIR/shell-snapshots" "$SHARED_DIR/session-env" "$SHARED_DIR/file-history"
    [ -f "$SHARED_DIR/settings.json" ] || echo '{}' > "$SHARED_DIR/settings.json"
    [ -f "$SHARED_DIR/history.jsonl" ] || : > "$SHARED_DIR/history.jsonl"
}

link_shared() {
    local dir="$1" item target
    for item in "${SHARED_ITEMS[@]}"; do
        target="$dir/$item"
        if [ -L "$target" ]; then
            rm -f "$target"
        elif [ -e "$target" ]; then
            echo "[WARN] $target already exists and is not a symlink; backing up to ${target}.bak"
            mv "$target" "${target}.bak"
        fi
        ln -s "$SHARED_DIR/$item" "$target"
    done
}

cmd_add() {
    local name="$1"
    local dir; dir="$(account_dir "$name")"
    [ -e "$dir" ] && { echo "Account '$name' already exists at $dir" >&2; exit 1; }
    ensure_shared
    mkdir -p "$dir"
    link_shared "$dir"
    echo "[OK] Created account '$name' at $dir"
    echo "     Logging in (this opens the normal Claude auth flow for THIS account only)..."
    CLAUDE_CONFIG_DIR="$dir" claude auth login
}

cmd_run() {
    local name="$1"; shift
    local dir; dir="$(account_dir "$name")"
    [ -d "$dir" ] || { echo "Account '$name' not found." >&2; exit 1; }
    exec env CLAUDE_CONFIG_DIR="$dir" claude "$@"
}

cmd_login() {
    local name="$1"
    local dir; dir="$(account_dir "$name")"
    [ -d "$dir" ] || { echo "Account '$name' not found." >&2; exit 1; }
    CLAUDE_CONFIG_DIR="$dir" claude auth login
}

cmd_status() {
    local name="$1"
    local dir; dir="$(account_dir "$name")"
    [ -d "$dir" ] || { echo "Account '$name' not found." >&2; exit 1; }
    CLAUDE_CONFIG_DIR="$dir" claude auth status
}

cmd_list() {
    [ -d "$BASE_DIR" ] || { echo "No accounts yet."; return; }
    echo "Accounts:"
    for f in "$BASE_DIR"/*/; do
        [ -d "$f" ] || continue
        name="$(basename "$f")"
        [ "$name" = "_shared" ] && continue
        echo "  - $name"
    done
}

cmd_path() {
    account_dir "$1"
}

cmd_remove() {
    local name="$1"; local force="${2:-}"
    local dir; dir="$(account_dir "$name")"
    [ -d "$dir" ] || { echo "Account '$name' not found." >&2; exit 1; }

    if [ "$force" != "-y" ]; then
        read -r -p "Remove account '$name' at $dir? This permanently deletes its login/credentials. [y/N] " reply
        case "$reply" in
            [yY][eE][sS]|[yY]) ;;
            *) echo "Aborted."; exit 1 ;;
        esac
    fi

    rm -rf "$dir"
    echo "[OK] Removed account '$name'"
}

cmd_usage() {
    exec python3 "$SCRIPT_DIR/claude-usage.py"
}

cmd_next() {
    local name
    name="$(python3 "$SCRIPT_DIR/claude-usage.py" --pick)" || exit 1
    cmd_run "$name" "$@"
}

case "${1:-}" in
    add)    [ -z "${2:-}" ] && { echo "Usage: $0 add <name>"; exit 1; }; cmd_add "$2" ;;
    run)    [ -z "${2:-}" ] && { echo "Usage: $0 run <name> [claude args...]"; exit 1; }; shift; cmd_run "$@" ;;
    login)  [ -z "${2:-}" ] && { echo "Usage: $0 login <name>"; exit 1; }; cmd_login "$2" ;;
    status) [ -z "${2:-}" ] && { echo "Usage: $0 status <name>"; exit 1; }; cmd_status "$2" ;;
    list)   cmd_list ;;
    path)   [ -z "${2:-}" ] && { echo "Usage: $0 path <name>"; exit 1; }; cmd_path "$2" ;;
    usage)  cmd_usage ;;
    next)   shift; cmd_next "$@" ;;
    remove) [ -z "${2:-}" ] && { echo "Usage: $0 remove <name> [-y]"; exit 1; }; cmd_remove "$2" "${3:-}" ;;
    ""|help|-h|--help)
        cat <<EOF
Usage: $0 <command>

Commands:
  add <name>     Create a new isolated account and log in (one-time)
  run <name> ... Run 'claude' as <name> (pass through any claude args). Safe
                 to run several accounts at once, in different terminals.
  login <name>   Re-authenticate an existing account
  status <name>  Show auth status for an account
  list           List configured accounts
  path <name>    Print the CLAUDE_CONFIG_DIR for an account (for scripting)
  usage          Show usage of all accounts (no state swap)
  next [args...] Pick the account with the most session headroom (lowest
                 % used) and run it. No args starts a fresh session;
                 'claude-rr next --resume' (or -r) resumes on that account.
  remove <name> [-y]
                 Permanently delete an account (asks to confirm unless
                 -y is passed)

Sessions (projects/) are shared automatically between all accounts, so
'claude-rr run <other> --resume' can pick up a session started under
any account. 'claude-rr next' automates that account choice for you.
EOF
        ;;
    *)
        echo "Unknown command: $1" >&2; exit 1 ;;
esac
