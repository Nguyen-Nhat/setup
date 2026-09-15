#!/bin/bash

# Init Claude RR 

DIR="$(cd "$(dirname "$0")" && pwd)"

chmod +x "$DIR/claude-rr.sh" "$DIR/claude-usage.py"

# Add aliases
grep -q "claude-rr=" ~/.zshrc || echo "alias claude-rr=\"$DIR/claude-rr.sh\"" >> ~/.zshrc
grep -q "claude-usage=" ~/.zshrc || echo "alias claude-usage=\"python3 $DIR/claude-usage.py\"" >> ~/.zshrc

echo "✅ Installed!"
echo ""
echo "👉 Run this to activate: source ~/.zshrc"
echo "   Or restart your terminal"
echo ""
echo "Commands (concurrent mode, multiple accounts truly at once):"
echo "  claude-rr add <name>      - Create + log in a new account"
echo "  claude-rr run <name> ...  - Run claude as <name> (any extra args passed through)"
echo "  claude-rr list            - List accounts"
echo "  claude-rr usage           - View usage of all accounts (no state swap)"
echo "  claude-usage               - Same as 'claude-rr usage', as its own command"
echo "  claude-rr next [args...]  - Auto-pick account with most headroom (add -r/--resume to resume)"
echo "  claude-rr remove <name>   - Permanently delete an account (asks to confirm)"
