#!/usr/bin/env bash
# Language runtimes and day-to-day dev CLIs.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

GO_VERSION="${GO_VERSION:-1.26.0}"
NODE_VERSION="${NODE_VERSION:-24}"
JAVA_VERSION="${JAVA_VERSION:-21.0.7-tem}"
MAVEN_VERSION="${MAVEN_VERSION:-3.9.14}"

# ---------------------------------------------------------------- Go
log "Installing Go $GO_VERSION"
if have go && [ "$(go version | awk '{print $3}')" = "go$GO_VERSION" ]; then
  ok "go$GO_VERSION already installed"
else
  need_sudo
  tmp="$(mktemp -d)"
  curl -fL --retry 3 -o "$tmp/go.tar.gz" \
    "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$tmp/go.tar.gz"
  rm -rf "$tmp"
  ok "Go installed to /usr/local/go"
fi
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
export GOPATH="$HOME/go"

log "Installing Go CLIs"
for mod in \
  github.com/bazelbuild/bazelisk@latest \
  github.com/vektra/mockery/v2@latest ; do
  go install "$mod" && ok "installed ${mod%%@*}"
done

# ---------------------------------------------------------------- Node via nvm
log "Installing nvm + Node $NODE_VERSION"
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  ok "nvm already installed"
else
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
ok "node $(node -v)"

# ---------------------------------------------------------------- Java via sdkman
log "Installing SDKMAN + Java $JAVA_VERSION + Maven $MAVEN_VERSION"
export SDKMAN_DIR="$HOME/.sdkman"
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  ok "SDKMAN already installed"
else
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
fi
set +u
# shellcheck disable=SC1091
. "$SDKMAN_DIR/bin/sdkman-init.sh"
sdk install java "$JAVA_VERSION"   || warn "java $JAVA_VERSION not available; pick one with: sdk list java"
sdk install maven "$MAVEN_VERSION" || warn "maven $MAVEN_VERSION not available"
set -u
ok "JVM toolchain ready"

# ---------------------------------------------------------------- Homebrew
log "Installing Homebrew (linuxbrew)"
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  ok "brew already installed"
else
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

ok "Dev tools ready — open a new shell to pick up PATH changes"
