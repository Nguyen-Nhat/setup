#!/usr/bin/env bash
# Tilix settings: profile, colors, font, background image.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

have tilix || die "tilix is not installed; run scripts/00-base-packages.sh first"
have dconf || apt_install dconf-cli

log "Installing the tilix background image"
mkdir -p "$HOME/Pictures/lol"
install_file "$DOTFILES/wallpaper/aurora_11.jpg" "$HOME/Pictures/lol/aurora_11.jpg"

log "Loading tilix settings from dotfiles/tilix.dconf"
# The dump hardcodes the old home path for the background image; rewrite it.
sed "s#/home/[^/']*/Pictures#$HOME/Pictures#g" "$DOTFILES/tilix.dconf" \
  | dconf load /com/gexperts/Tilix/
ok "tilix profile loaded"

log "Making tilix the default terminal"
if [ -x /usr/bin/tilix ]; then
  sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix 2>/dev/null \
    || warn "could not set x-terminal-emulator"
  gsettings set org.gnome.desktop.default-applications.terminal exec 'tilix' 2>/dev/null || true
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e' 2>/dev/null || true
fi

warn "Tilix under Wayland may warn about VTE config; already silenced in the profile."
ok "tilix ready — set the font to 'JetBrainsMono Nerd Font 12' if it did not apply"
