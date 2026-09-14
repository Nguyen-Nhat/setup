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
| `scripts/08-vietnamese.sh` | Bộ gõ tiếng Việt: ibus + Unikey (Telex, Unicode), chuyển EN↔VI bằng `Alt+Space` |
| `scripts/09-claude-code.sh` | Claude Code CLI + marketplace/plugin `agent-skills` (addyosmani) + Vim input mode |
| `scripts/10-aws-cli.sh` | AWS CLI v2 + scaffold `~/.aws/config` (region `ap-southeast-1`, `output=json`) và `~/.aws/credentials` (key rỗng) |

Thứ tự chạy mặc định là 00 → 01 → 02 → 03 → 05 → 06 → 04 → 07 → 08 → 09 → 10:
Neovim chạy **sau** dev-tools vì Mason/treesitter cần Node, Go và compiler.
Claude Code và AWS CLI chạy cuối vì không phụ thuộc các bước khác.

## Claude Code

Bước `09-claude-code.sh` cài **CLI** qua npm, cấu hình git dùng https thay
vì ssh cho github.com (`git config --global url."https://github.com/".insteadOf
git@github.com:`, tránh lỗi clone khi máy mới chưa có SSH key), rồi thêm
marketplace + cài plugin:

```bash
claude plugin marketplace add addyosmani/agent-skills
claude plugin install agent-skills@addy-agent-skills
```

Cuối cùng, script set `"editorMode": "vim"` trong `~/.claude/settings.json`
(dùng `jq` để merge, không đụng các field khác) — tương đương chạy `/vim`
trong Claude Code để bật Vim keybindings cho ô nhập prompt.

Script này **không** copy `~/.claude` (credentials, session, `settings.json`
cá nhân) — thư mục đó chứa token đăng nhập nên bị loại khỏi repo (xem mục
"Những thứ script KHÔNG làm" bên dưới). Sau khi cài, đăng nhập lại thủ công
trên máy mới:

```bash
claude
```

## AWS CLI

Bước `10-aws-cli.sh` cài AWS CLI v2 (tải thẳng từ `awscli.amazonaws.com`,
không qua apt) rồi tạo:

- `~/.aws/config` — từ `dotfiles/aws/config`, `region = ap-southeast-1`,
  `output = json`. File này **không chứa bí mật** nên bị ghi đè mỗi lần
  chạy lại nếu khác với template (bản cũ được backup như mọi dotfile khác).
- `~/.aws/credentials` — từ `dotfiles/aws/credentials.template`, với
  `aws_access_key_id` / `aws_secret_access_key` để **rỗng**. Chỉ tạo nếu
  file chưa tồn tại — nếu đã có (tức bạn đã điền key), script **không**
  đụng vào để tránh ghi đè mất key thật.

Sau khi cài, tự điền access key/secret:

```bash
$EDITOR ~/.aws/credentials
```

## Bộ gõ tiếng Việt

Bước `08-vietnamese.sh` dựng lại đúng cấu hình hiện tại:

- Cài `ibus` + `ibus-unikey` (kèm `ibus-gtk/gtk3/gtk4` để app GTK nhận bộ gõ).
- Input sources: `[('xkb','us'), ('ibus','Unikey')]` — bàn phím US + Unikey.
- Phím chuyển: `Alt+Space` (ngược lại `Shift+Alt+Space`).
- Unikey: kiểu gõ **Telex**, bảng mã **Unicode**, bật kiểm tra chính tả,
  tự khôi phục từ không hợp lệ, bỏ dấu tự do, `w` đứng một mình ra `ư`.
- `per-window = false` — trạng thái bộ gõ dùng chung cho mọi cửa sổ.

Script phải chạy **trong phiên đồ hoạ** (cần `gsettings`). Nếu chạy qua SSH
hay TTY, nó sẽ cài gói rồi bỏ qua phần cấu hình và nhắc bạn chạy lại:

```bash
./install.sh 08
```

Mặc định không tạo locale `vi_VN.UTF-8` (máy cũ cũng không có, `LANG` vẫn là
`en_US.UTF-8`). Nếu muốn có để format ngày/số kiểu Việt:

```bash
INSTALL_VI_LOCALE=1 ./scripts/08-vietnamese.sh
```

Kiểm tra sau khi cài: bấm `Alt+Space`, icon panel đổi sang **VN**, gõ
`tieengs vieejt` → ra `tiếng việt`.

Nếu app Electron (Slack, VS Code) hoặc JetBrains không nhận bộ gõ, đăng xuất
đăng nhập lại; vẫn lỗi thì thêm vào `~/.profile`:

```sh
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
```

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
├── aws/config            → ~/.aws/config   (region ap-southeast-1, json)
├── aws/credentials.template → ~/.aws/credentials  (phải tự điền key)
├── goland/settings.zip   → GoLand: File → Manage IDE Settings → Import Settings
└── wallpaper/aurora_11.jpg → ~/Pictures/lol/
```

## Lưu ý về bảo mật

`~/.gitconfig` hiện tại chứa **GitLab personal access token** của git.teko.vn.
Token đó **không** được copy vào đây. Script cài `gitconfig.template`, bạn
phải tự tạo token mới và điền vào chỗ `<GITLAB_TOKEN>`.

Tương tự, `~/.aws/credentials` được tạo với `aws_access_key_id` /
`aws_secret_access_key` **để rỗng** — không có key thật nào nằm trong repo.
Bạn tự paste key vào sau khi cài.

Nên cân nhắc thu hồi token/key cũ khi bỏ máy cũ.

## Sau khi cài xong

1. **Log out / log in lại** — để zsh thành shell mặc định và group `docker` có hiệu lực.
2. Trong tilix, kiểm tra font đang là `JetBrainsMono Nerd Font 12`; nếu icon p10k lỗi thì đổi sang `MesloLGS NF`.
3. Sửa `~/.gitconfig`, điền token GitLab mới.
4. Mở `nvim` một lần, chờ Lazy/Mason chạy xong, kiểm tra `:checkhealth`.
5. Trong tmux, bấm `prefix + I` nếu plugin chưa được cài.
6. Bấm `Alt+Space` thử bộ gõ tiếng Việt (xem mục "Bộ gõ tiếng Việt" ở trên).
7. Chạy `claude` và đăng nhập lại (xem mục "Claude Code" ở trên).
8. Điền `~/.aws/credentials` với access key/secret thật (xem mục "AWS CLI" ở trên).
9. Mở GoLand → **File → Manage IDE Settings → Import Settings…** → chọn `dotfiles/goland/settings.zip` (keymap, template, font, theme...). Xuất lại bằng **Export Settings…** khi muốn cập nhật.

## Những thứ script KHÔNG làm

Phần này cố ý để ngoài phạm vi, cài tay nếu cần:

- Google Chrome, Slack, VLC, Lutris/Wine, JetBrains IDE (`~/apps/idea`)
- Pritunl VPN client, cert trong `~/.cert`, kubeconfig trong `~/.kube`
- Các gói `ibus-table-cangjie*` / `libpinyin` (bộ gõ tiếng Trung, cài kèm từ language support)
- `~/workspace` (các repo) và `~/workspace/tekone.wt/wt` mà alias `wt` trỏ tới
- Cấu hình GNOME (phím tắt, tiling-assistant, monitors.xml)
- Credential: `.docker`, `.npm`, `.gnupg`, `.claude` (key/token thật, không copy)
- `~/.aws` chỉ được **scaffold** (config + credentials rỗng) bởi
  `10-aws-cli.sh` — key thật vẫn phải tự điền, xem mục "AWS CLI" ở trên
