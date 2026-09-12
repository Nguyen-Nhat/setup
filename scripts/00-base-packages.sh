#!/usr/bin/env bash
# Base system packages available from Ubuntu's own repositories.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

log "Updating apt index"
need_sudo
sudo apt-get update -y

log "Installing base packages"
apt_install \
  build-essential autoconf automake make cmake pkg-config \
  git curl wget unzip zip tar gzip \
  ca-certificates gnupg apt-transport-https software-properties-common \
  zsh tmux tilix vim \
  ripgrep fd-find fzf jq tree htop net-tools dnsutils \
  xclip xsel wl-clipboard dos2unix \
  python3 python3-pip python3-venv \
  fontconfig lua5.4

# Ubuntu ships fd as fdfind; add the conventional name.
if have fdfind && ! have fd; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  ok "linked fd -> fdfind in ~/.local/bin"
fi

ok "Base packages installed"
