#!/usr/bin/env bash
# Shared helpers for all setup scripts.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$SETUP_DIR/dotfiles"
BACKUP_DIR="$HOME/.setup-backup/$(date +%Y%m%d-%H%M%S)"

C_OK=$'\033[0;32m'; C_INFO=$'\033[0;34m'; C_WARN=$'\033[0;33m'; C_ERR=$'\033[0;31m'; C_OFF=$'\033[0m'

log()  { printf '%s==>%s %s\n' "$C_INFO" "$C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_OK" "$C_OFF" "$*"; }
warn() { printf '%s  !!%s %s\n' "$C_WARN" "$C_OFF" "$*"; }
die()  { printf '%s ERR%s %s\n' "$C_ERR" "$C_OFF" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Back up an existing file/dir before we replace it.
backup() {
  local target="$1"
  [ -e "$target" ] || [ -L "$target" ] || return 0
  mkdir -p "$BACKUP_DIR"
  mv "$target" "$BACKUP_DIR/$(basename "$target")"
  warn "backed up $target -> $BACKUP_DIR/$(basename "$target")"
}

# install_file <src> <dest>
install_file() {
  local src="$1" dest="$2"
  [ -e "$src" ] || die "missing source file: $src"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && cmp -s "$src" "$dest"; then
    ok "$dest already up to date"
    return 0
  fi
  backup "$dest"
  cp "$src" "$dest"
  ok "installed $dest"
}

need_sudo() {
  if [ "$(id -u)" -eq 0 ]; then return 0; fi
  have sudo || die "sudo is required but not installed"
  sudo -v || die "cannot obtain sudo"
}

apt_install() {
  need_sudo
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}
