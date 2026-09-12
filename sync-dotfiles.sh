#!/usr/bin/env bash
# Re-export the live configs of THIS machine back into ./dotfiles.
# Run it on the old machine whenever you tweak something, before copying
# this folder over to the new one.
source "$(dirname "$(readlink -f "$0")")/lib.sh"

log "Copying shell dotfiles"
cp "$HOME/.zshrc"     "$DOTFILES/zshrc"      && ok "zshrc"
cp "$HOME/.p10k.zsh"  "$DOTFILES/p10k.zsh"   && ok "p10k.zsh"
cp "$HOME/.tmux.conf" "$DOTFILES/tmux.conf"  && ok "tmux.conf"
[ -f "$HOME/.ideavimrc" ] && cp "$HOME/.ideavimrc" "$DOTFILES/ideavimrc" && ok "ideavimrc"
[ -f "$HOME/.config/git/ignore" ] && cp "$HOME/.config/git/ignore" "$DOTFILES/git/ignore" && ok "git/ignore"

log "Copying the nvim config (without .git)"
rsync -a --delete --exclude '.git' --exclude '.claude' \
  "$HOME/.config/nvim/" "$DOTFILES/nvim/" && ok "nvim"

log "Dumping tilix settings"
dconf dump /com/gexperts/Tilix/ > "$DOTFILES/tilix.dconf" && ok "tilix.dconf"

warn "~/.gitconfig is NOT copied: it holds a GitLab token."
warn "Update dotfiles/gitconfig.template by hand if the non-secret parts changed."
ok "Dotfiles synced into $DOTFILES"
