#!/usr/bin/env bash
# Claude Code CLI. Requires Node (installed by 05-dev-tools.sh via nvm).
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
fi

have npm || die "npm not found; run scripts/05-dev-tools.sh first"

log "Installing Claude Code CLI"
if have claude; then
  ok "claude already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  npm install -g @anthropic-ai/claude-code
  ok "claude installed"
fi

# github.com over SSH often fails on a fresh machine (no SSH key/agent yet),
# which breaks `claude plugin marketplace add` since it clones the repo.
# Force git to use HTTPS for github.com instead.
log "Forcing git to use https for github.com (avoids SSH clone failures)"
if git config --global --get-all url."https://github.com/".insteadOf 2>/dev/null | grep -qx 'git@github.com:'; then
  ok "git url.insteadOf already set"
else
  git config --global url."https://github.com/".insteadOf "git@github.com:"
  ok "git config --global url.\"https://github.com/\".insteadOf git@github.com: set"
fi

log "Adding Claude Code plugin marketplace: addyosmani/agent-skills"
if claude plugin marketplace list 2>/dev/null | grep -q 'addy-agent-skills'; then
  ok "marketplace addy-agent-skills already added"
else
  claude plugin marketplace add addyosmani/agent-skills
  ok "marketplace addy-agent-skills added"
fi

log "Installing plugin agent-skills@addy-agent-skills"
if claude plugin list 2>/dev/null | grep -q 'agent-skills@addy-agent-skills'; then
  ok "plugin agent-skills@addy-agent-skills already installed"
else
  claude plugin install agent-skills@addy-agent-skills
  ok "plugin agent-skills@addy-agent-skills installed"
fi

log "Setting Claude Code input editor to Vim mode"
have jq || die "jq not found; run scripts/00-base-packages.sh first"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
if [ -f "$CLAUDE_SETTINGS" ]; then
  if jq -e '.editorMode == "vim"' "$CLAUDE_SETTINGS" >/dev/null 2>&1; then
    ok "editorMode already set to vim"
  else
    tmp="$(mktemp)"
    jq '.editorMode = "vim"' "$CLAUDE_SETTINGS" > "$tmp" && mv "$tmp" "$CLAUDE_SETTINGS"
    ok "editorMode set to vim in $CLAUDE_SETTINGS"
  fi
else
  echo '{"editorMode": "vim"}' | jq '.' > "$CLAUDE_SETTINGS"
  ok "created $CLAUDE_SETTINGS with editorMode=vim"
fi

cat <<'NOTE'

Lưu ý: script này chỉ cài CLI, KHÔNG copy ~/.claude (credentials, session,
settings.json cá nhân) — thư mục đó chứa token đăng nhập nên cố tình bị
loại khỏi repo (xem "Những thứ script KHÔNG làm" trong README).

Sau khi cài xong, chạy:

  claude

và đăng nhập lại (Claude account hoặc API key) trên máy mới.
NOTE
