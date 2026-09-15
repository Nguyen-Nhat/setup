#!/usr/bin/env bash
# claude-rr: run multiple Claude Code accounts concurrently, each with its
# own CLAUDE_CONFIG_DIR under ~/.claude-accounts/, sharing one projects/ dir.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

TARGET_DIR="$HOME/workspace/claude-rr"

log "Installing claude-rr to $TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -r "$DOTFILES/claude-rr/." "$TARGET_DIR/"
chmod +x "$TARGET_DIR/claude-rr.sh" "$TARGET_DIR/init.sh"
ok "claude-rr copied to $TARGET_DIR"

log "Running claude-rr's own init.sh (adds claude-rr/claude-usage aliases to ~/.zshrc)"
bash "$TARGET_DIR/init.sh"

cat <<'NOTE'

Lưu ý: script này chỉ cài công cụ (claude-rr.sh, claude-usage.py) và các
alias, KHÔNG tạo account nào. Mỗi account vẫn cần đăng nhập tay:

  source ~/.zshrc
  claude-rr add work
  claude-rr add personal

Xem thêm dotfiles/claude-rr/README.md hoặc README chính (mục "Claude Code
multi-account (claude-rr)").
NOTE
