#!/usr/bin/env bash
# Docker, Kubernetes, Terraform, Bazel and friends (third-party apt repos).
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

K8S_MINOR="${K8S_MINOR:-v1.34}"

need_sudo
sudo install -m 0755 -d /etc/apt/keyrings

add_key() { # add_key <url> <keyring-name>
  local url="$1" name="$2"
  [ -f "/etc/apt/keyrings/$name" ] && return 0
  curl -fsSL "$url" | sudo gpg --dearmor -o "/etc/apt/keyrings/$name"
  sudo chmod a+r "/etc/apt/keyrings/$name"
}

# ---------------------------------------------------------------- Docker
log "Adding Docker repository"
add_key "https://download.docker.com/linux/ubuntu/gpg" docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# ---------------------------------------------------------------- Kubernetes
log "Adding Kubernetes $K8S_MINOR repository"
add_key "https://pkgs.k8s.io/core:/stable:/$K8S_MINOR/deb/Release.key" kubernetes.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_MINOR/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

# ---------------------------------------------------------------- HashiCorp
log "Adding HashiCorp repository"
add_key "https://apt.releases.hashicorp.com/gpg" hashicorp.gpg
echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

sudo apt-get update -y
apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
            kubectl kubeadm kubelet terraform

log "Adding $USER to the docker group"
sudo groupadd -f docker
sudo usermod -aG docker "$USER"
warn "log out and back in (or run: newgrp docker) to use docker without sudo"

# ---------------------------------------------------------------- helm
log "Installing helm"
if have helm; then
  ok "helm already installed"
else
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# ---------------------------------------------------------------- kubectx/kubens
log "Installing kubectx + kubens"
if have kubectx; then
  ok "kubectx already installed"
else
  tmp="$(mktemp -d)"
  git clone --depth=1 https://github.com/ahmetb/kubectx "$tmp/kubectx"
  sudo cp "$tmp/kubectx/kubectx" "$tmp/kubectx/kubens" /usr/local/bin/
  rm -rf "$tmp"
  ok "kubectx/kubens installed"
fi

# ---------------------------------------------------------------- k9s
log "Installing k9s"
if have k9s; then
  ok "k9s already installed"
else
  tmp="$(mktemp -d)"
  curl -fL --retry 3 -o "$tmp/k9s.deb" \
    "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb"
  sudo dpkg -i "$tmp/k9s.deb"
  rm -rf "$tmp"
  ok "k9s installed"
fi

ok "Infra tooling ready"
