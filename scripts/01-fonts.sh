#!/usr/bin/env bash
# Nerd Fonts: MesloLGS NF (powerlevel10k) + JetBrainsMono Nerd Font (tilix/nvim).
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

log "Installing MesloLGS NF (powerlevel10k recommended font)"
base="https://github.com/romkatv/powerlevel10k-media/raw/master"
for f in "MesloLGS NF Regular.ttf" "MesloLGS NF Bold.ttf" \
         "MesloLGS NF Italic.ttf" "MesloLGS NF Bold Italic.ttf"; do
  if [ -f "$FONT_DIR/$f" ]; then
    ok "$f already present"
    continue
  fi
  curl -fL --retry 3 -o "$FONT_DIR/$f" "$base/${f// /%20}"
  ok "downloaded $f"
done

log "Installing JetBrainsMono Nerd Font"
if ls "$FONT_DIR"/JetBrainsMonoNerdFont-*.ttf >/dev/null 2>&1; then
  ok "JetBrainsMono Nerd Font already present"
else
  tmp="$(mktemp -d)"
  curl -fL --retry 3 -o "$tmp/JetBrainsMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -qo "$tmp/JetBrainsMono.zip" -d "$tmp/JetBrainsMono"
  find "$tmp/JetBrainsMono" -name '*.ttf' -exec cp {} "$FONT_DIR/" \;
  rm -rf "$tmp"
  ok "JetBrainsMono Nerd Font installed"
fi

fc-cache -f "$FONT_DIR" >/dev/null
ok "Font cache rebuilt"
