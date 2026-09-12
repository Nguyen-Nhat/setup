#!/usr/bin/env bash
# Neovim (official tarball to /opt) + the NvChad-based config.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

NVIM_PREFIX="/opt/nvim-linux-x86_64"

log "Installing Neovim to $NVIM_PREFIX"
if [ -x "$NVIM_PREFIX/bin/nvim" ]; then
  ok "Neovim already present ($("$NVIM_PREFIX/bin/nvim" --version | head -1))"
else
  need_sudo
  tmp="$(mktemp -d)"
  curl -fL --retry 3 -o "$tmp/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  sudo rm -rf "$NVIM_PREFIX"
  sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
  rm -rf "$tmp"
  ok "Neovim installed: $("$NVIM_PREFIX/bin/nvim" --version | head -1)"
fi
export PATH="$NVIM_PREFIX/bin:$PATH"

log "Installing tooling the config expects"
# Treesitter needs a C compiler; telescope-fzf-native needs make (both from 00).
# Mason installs the LSP servers itself, but these runtimes must exist.
have node || warn "node not found - run scripts/05-dev-tools.sh before opening nvim"
have go   || warn "go not found - gopls/nvim-dap-go will not build"

if have npm; then
  for pkg in prettier prettierd; do
    if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
      ok "$pkg already installed"
    else
      npm install -g "$pkg" && ok "installed $pkg"
    fi
  done
else
  warn "npm not found - prettier/prettierd (conform formatters) skipped"
fi

log "Installing the nvim config"
if [ -e "$HOME/.config/nvim" ]; then
  backup "$HOME/.config/nvim"
fi
mkdir -p "$HOME/.config/nvim"
cp -r "$DOTFILES/nvim/." "$HOME/.config/nvim/"
ok "config copied to ~/.config/nvim"

log "Bootstrapping lazy.nvim plugins (this takes a few minutes)"
"$NVIM_PREFIX/bin/nvim" --headless "+Lazy! sync" +qa || warn "Lazy sync reported errors"

log "Installing Mason LSP servers"
"$NVIM_PREFIX/bin/nvim" --headless \
  "+MasonInstall html-lsp css-lsp json-lsp typescript-language-server eslint-lsp tailwindcss-language-server emmet-ls gopls jdtls lua-language-server stylua google-java-format" \
  +qa || warn "some Mason packages failed; install them from :Mason"

ok "Neovim ready"
