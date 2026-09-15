#!/usr/bin/env bash
# One-shot installer: recreates the whole working environment on a fresh Ubuntu.
#
#   ./install.sh              # run everything, in order
#   ./install.sh 02 04        # run only the steps whose number matches
#   ./install.sh --list       # show the steps
source "$(dirname "$(readlink -f "$0")")/lib.sh"

STEPS=(
  "00-base-packages.sh:apt packages (zsh, tmux, tilix, ripgrep, build tools...)"
  "01-fonts.sh:Nerd Fonts (MesloLGS NF, JetBrainsMono)"
  "02-zsh.sh:oh-my-zsh + powerlevel10k + .zshrc/.p10k.zsh"
  "03-tmux.sh:.tmux.conf + tpm plugins"
  "05-dev-tools.sh:Go, nvm/Node, SDKMAN/Java+Maven, Homebrew"
  "06-infra-tools.sh:Docker, kubectl, helm, kubectx, k9s, terraform"
  "04-neovim.sh:Neovim + NvChad config + LSP servers"
  "07-tilix.sh:Tilix profile, colors, font, wallpaper"
  "08-vietnamese.sh:Vietnamese input (ibus + Unikey, Telex, Alt+Space)"
  "09-claude-code.sh:Claude Code CLI (npm install -g @anthropic-ai/claude-code)"
  "10-aws-cli.sh:AWS CLI v2 + ~/.aws/config,credentials scaffold"
  "11-claude-rr.sh:claude-rr multi-account Claude Code switcher"
)

usage() {
  echo "Usage: $0 [--list] [step-number ...]"
  echo
  echo "Steps (run in this order by default):"
  local i=1
  for s in "${STEPS[@]}"; do
    printf "  %d. %-22s %s\n" "$i" "${s%%:*}" "${s#*:}"
    i=$((i + 1))
  done
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --list)    usage; exit 0 ;;
esac

[ "$(id -u)" -eq 0 ] && die "run this as your normal user, not root (sudo is used where needed)"
. /etc/os-release
[ "${ID:-}" = "ubuntu" ] || warn "this was written for Ubuntu; found ${PRETTY_NAME:-unknown}"

selected=("$@")
run_step() {
  local script="$1" desc="$2"
  if [ ${#selected[@]} -gt 0 ]; then
    local match=0
    for want in "${selected[@]}"; do
      [[ "$script" == "$want"* ]] && match=1
    done
    [ "$match" -eq 1 ] || return 0
  fi
  printf '\n%s================================================================%s\n' "$C_INFO" "$C_OFF"
  printf '%s  %s — %s%s\n' "$C_INFO" "$script" "$desc" "$C_OFF"
  printf '%s================================================================%s\n' "$C_INFO" "$C_OFF"
  if bash "$SETUP_DIR/scripts/$script"; then
    ok "$script finished"
  else
    warn "$script FAILED — continuing with the remaining steps"
    FAILED+=("$script")
  fi
}

# Ask for sudo once up front so the run does not stall on a password prompt
# halfway through. Steps that need it will ask again if this could not run.
if ! ( need_sudo ); then warn "could not pre-authorize sudo; individual steps will ask"; fi
FAILED=()
for s in "${STEPS[@]}"; do
  run_step "${s%%:*}" "${s#*:}"
done

printf '\n'
if [ ${#FAILED[@]} -gt 0 ]; then
  warn "these steps failed: ${FAILED[*]}"
  warn "re-run an individual step with: ./install.sh ${FAILED[0]%%-*}"
else
  ok "All steps completed"
fi

cat <<'NEXT'

Next steps
----------
1. Log out and log back in  (default shell -> zsh, docker group membership).
2. In the terminal profile, set the font to "MesloLGS NF" or
   "JetBrainsMono Nerd Font" so the powerlevel10k glyphs render.
3. Edit ~/.gitconfig and put in a fresh GitLab personal access token.
4. Open nvim once and let Lazy/Mason finish; check :checkhealth.
5. In tmux press prefix + I if the plugins were not installed.
6. Run `claude` and log in again (credentials are not copied by this repo).
7. Edit ~/.aws/credentials and paste in the AWS access key/secret.
8. Run `source ~/.zshrc`, then `claude-rr add <name>` for each Claude
   account you want to use concurrently.
NEXT
