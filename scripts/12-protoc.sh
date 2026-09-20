#!/usr/bin/env bash
# protoc (protobuf compiler) v3.13.0, built from source (no apt/snap package
# ships this exact version). Cleans up the tarball/build tree when done.
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

PROTOBUF_VERSION="3.13.0"

log "Installing protoc build dependencies"
apt_install autoconf automake libtool curl make g++ unzip

log "Installing protoc $PROTOBUF_VERSION"
if have protoc && protoc --version 2>/dev/null | grep -qx "libprotoc $PROTOBUF_VERSION"; then
  ok "protoc already installed ($(protoc --version))"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  curl -fL --retry 3 -o "$tmp/protobuf-all-$PROTOBUF_VERSION.tar.gz" \
    "https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOBUF_VERSION/protobuf-all-$PROTOBUF_VERSION.tar.gz"
  tar -xzf "$tmp/protobuf-all-$PROTOBUF_VERSION.tar.gz" -C "$tmp"

  (
    cd "$tmp/protobuf-$PROTOBUF_VERSION"
    ./configure
    make -j"$(nproc)"
    need_sudo
    sudo make install
    sudo ldconfig
  )

  ok "protoc installed ($(protoc --version))"
fi
