#!/usr/bin/env bash
# tmux config + tpm and the plugins it manages.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

have tmux || die "tmux is not installed; run scripts/00-base-packages.sh first"

install_file "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"

TPM="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM/.git" ]; then
  git -C "$TPM" pull --ff-only --quiet || warn "could not update tpm"
  ok "tpm up to date"
else
  log "Installing tpm"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
  ok "tpm installed"
fi

log "Installing tmux plugins (tmux-sensible, tmux-yank)"
"$TPM/bin/install_plugins" >/dev/null 2>&1 || \
  warn "run prefix + I inside tmux to finish plugin install"

ok "tmux ready"
