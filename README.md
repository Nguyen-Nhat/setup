# Setup — tái tạo môi trường làm việc trên Ubuntu mới

Bộ script này dựng lại y hệt môi trường hiện tại: zsh + oh-my-zsh +
powerlevel10k, tmux, tilix, Neovim (NvChad), cùng toàn bộ toolchain
(Go, Node, Java, Docker, Kubernetes, Terraform...).

Đã test trên Ubuntu 24.04/25.04 x86_64, chạy được trên máy vừa cài xong.

## Cách dùng

Trên máy **cũ** (tuỳ chọn, để lấy config mới nhất):

```bash
cd ~/workspace/setup
./sync-dotfiles.sh
```

Copy nguyên thư mục `setup/` sang máy **mới** (USB, scp, git...), rồi:

```bash
cd ~/setup
./install.sh
```

Chạy lại một bước riêng lẻ:

```bash
./install.sh --list      # xem danh sách bước
./install.sh 04          # chỉ chạy bước Neovim
./install.sh 02 03       # chạy zsh + tmux
```

Script chạy được nhiều lần (idempotent): thứ nào đã có thì bỏ qua.
Mọi file config cũ bị ghi đè đều được backup vào `~/.setup-backup/<timestamp>/`.

## Các bước

| Script | Nội dung |
|---|---|
| `scripts/00-base-packages.sh` | apt: build-essential, git, curl, zsh, tmux, tilix, ripgrep, fd, fzf, jq, xclip/wl-clipboard, python3... |
| `scripts/01-fonts.sh` | Nerd Fonts: MesloLGS NF (cho p10k) + JetBrainsMono Nerd Font (font tilix đang dùng) |
| `scripts/02-zsh.sh` | oh-my-zsh, powerlevel10k, zsh-autosuggestions, cài `.zshrc`/`.p10k.zsh`/`.ideavimrc`, đặt zsh làm shell mặc định |
| `scripts/03-tmux.sh` | `.tmux.conf` + tpm + plugin (tmux-sensible, tmux-yank) |
| `scripts/05-dev-tools.sh` | Go 1.26, nvm + Node 24, SDKMAN + Java 21 (tem) + Maven 3.9, Homebrew, bazelisk, mockery |
| `scripts/06-infra-tools.sh` | Docker CE, kubectl/kubeadm/kubelet, helm, kubectx/kubens, k9s, Terraform |
| `scripts/04-neovim.sh` | Neovim (tarball vào `/opt/nvim-linux-x86_64`), copy config NvChad, `Lazy sync`, cài LSP qua Mason, prettier/prettierd |
| `scripts/07-tilix.sh` | Nạp profile tilix (màu, font, ảnh nền, transparency) bằng `dconf load`, đặt tilix làm terminal mặc định |

Thứ tự chạy mặc định là 00 → 01 → 02 → 03 → 05 → 06 → 04 → 07:
Neovim chạy **sau** dev-tools vì Mason/treesitter cần Node, Go và compiler.

## Config được mang theo

```
dotfiles/
├── zshrc                 → ~/.zshrc
├── p10k.zsh              → ~/.p10k.zsh
├── tmux.conf             → ~/.tmux.conf
├── ideavimrc             → ~/.ideavimrc
├── git/ignore            → ~/.config/git/ignore
├── gitconfig.template    → ~/.gitconfig  (phải tự điền token)
├── nvim/                 → ~/.config/nvim/   (NvChad starter đã custom)
├── tilix.dconf           → dconf /com/gexperts/Tilix/
└── wallpaper/aurora_11.jpg → ~/Pictures/lol/
```

## Lưu ý về bảo mật

`~/.gitconfig` hiện tại chứa **GitLab personal access token** của git.teko.vn.
Token đó **không** được copy vào đây. Script cài `gitconfig.template`, bạn
phải tự tạo token mới và điền vào chỗ `<GITLAB_TOKEN>`.

Nên cân nhắc thu hồi token cũ khi bỏ máy cũ.

## Sau khi cài xong

1. **Log out / log in lại** — để zsh thành shell mặc định và group `docker` có hiệu lực.
2. Trong tilix, kiểm tra font đang là `JetBrainsMono Nerd Font 12`; nếu icon p10k lỗi thì đổi sang `MesloLGS NF`.
3. Sửa `~/.gitconfig`, điền token GitLab mới.
4. Mở `nvim` một lần, chờ Lazy/Mason chạy xong, kiểm tra `:checkhealth`.
5. Trong tmux, bấm `prefix + I` nếu plugin chưa được cài.

## Những thứ script KHÔNG làm

Phần này cố ý để ngoài phạm vi, cài tay nếu cần:

- Google Chrome, Slack, VLC, Lutris/Wine, JetBrains IDE (`~/apps/idea`)
- Pritunl VPN client, cert trong `~/.cert`, kubeconfig trong `~/.kube`
- `~/workspace` (các repo) và `~/workspace/tekone.wt/wt` mà alias `wt` trỏ tới
- Bộ gõ tiếng Việt (ibus-unikey) và các gói ibus-table
- Cấu hình GNOME (phím tắt, tiling-assistant, monitors.xml)
- Credential: `.aws`, `.docker`, `.npm`, `.gnupg`, `.claude`
