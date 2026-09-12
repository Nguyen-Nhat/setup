#!/usr/bin/env bash
# zsh + oh-my-zsh + powerlevel10k + zsh-autosuggestions, then the dotfiles.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

have zsh || die "zsh is not installed; run scripts/00-base-packages.sh first"

ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM="$ZSH_DIR/custom"

if [ -d "$ZSH_DIR" ]; then
  ok "oh-my-zsh already installed"
else
  log "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

clone_or_pull() {
  local repo="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only --quiet || warn "could not update $dest"
    ok "$(basename "$dest") up to date"
  else
    git clone --depth=1 "$repo" "$dest"
    ok "cloned $(basename "$dest")"
  fi
}

log "Installing powerlevel10k theme"
clone_or_pull https://github.com/romkatv/powerlevel10k.git "$CUSTOM/themes/powerlevel10k"

log "Installing zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM/plugins/zsh-autosuggestions"

log "Installing shell dotfiles"
install_file "$DOTFILES/zshrc"    "$HOME/.zshrc"
install_file "$DOTFILES/p10k.zsh" "$HOME/.p10k.zsh"
install_file "$DOTFILES/ideavimrc" "$HOME/.ideavimrc"
install_file "$DOTFILES/git/ignore" "$HOME/.config/git/ignore"

if [ ! -f "$HOME/.gitconfig" ]; then
  log "Creating ~/.gitconfig from template (edit the placeholders!)"
  cp "$DOTFILES/gitconfig.template" "$HOME/.gitconfig"
  warn "edit ~/.gitconfig: set your name/email and the GitLab token"
else
  ok "~/.gitconfig already exists, left untouched"
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  log "Setting zsh as the default login shell"
  chsh -s "$(command -v zsh)" || warn "chsh failed; run: chsh -s $(command -v zsh)"
else
  ok "zsh is already the default shell"
fi

ok "zsh environment ready (log out and back in for the shell change)"
