#!/usr/bin/env bash
# AWS CLI v2 + ~/.aws/{config,credentials} scaffold.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

log "Installing AWS CLI v2"
if have aws; then
  ok "aws already installed ($(aws --version 2>&1))"
else
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  pkg="awscli-exe-linux-x86_64.zip" ;;
    aarch64) pkg="awscli-exe-linux-aarch64.zip" ;;
    *) die "unsupported architecture for AWS CLI: $arch" ;;
  esac
  tmp="$(mktemp -d)"
  curl -fL --retry 3 -o "$tmp/awscliv2.zip" "https://awscli.amazonaws.com/$pkg"
  unzip -q "$tmp/awscliv2.zip" -d "$tmp"
  need_sudo
  sudo "$tmp/aws/install"
  rm -rf "$tmp"
  ok "aws installed ($(aws --version 2>&1))"
fi

log "Setting up ~/.aws"
mkdir -p "$HOME/.aws"
chmod 700 "$HOME/.aws"

install_file "$DOTFILES/aws/config" "$HOME/.aws/config"
chmod 600 "$HOME/.aws/config"

if [ -f "$HOME/.aws/credentials" ]; then
  ok "~/.aws/credentials already exists, left untouched"
else
  log "Creating ~/.aws/credentials from template (access key/secret left empty)"
  cp "$DOTFILES/aws/credentials.template" "$HOME/.aws/credentials"
  chmod 600 "$HOME/.aws/credentials"
  warn "edit ~/.aws/credentials: paste aws_access_key_id / aws_secret_access_key"
fi

ok "AWS CLI ready"
