1. Yêu cầu hệ thống (Ubuntu/Linux)🖥️ Core Build ToolsCần thiết để biên dịch fzf-native và các parser của Treesitter.Bashsudo apt update
sudo apt install build-essential gcc make cmake unzip
🌳 Treesitter Dependencies (Sửa lỗi Highlight)Để khắc phục lỗi tree-sitter-cli not found và giúp Highlight hoạt động:Bash# Ưu tiên dùng npm nếu bạn đã có Node.js
sudo npm install -g tree-sitter-cli

# Hoặc dùng Cargo nếu bạn dùng Rust
cargo install tree-sitter-cli
🔍 Search Tools (Sửa lỗi Telescope)Để tính năng live_grep (<leader>fw) hoạt động mượt mà trong Repo lớn:Bashsudo apt install ripgrep fd-find
2. Go Tooling (Formatting & Linting)Để conform.nvim và gopls có thể format/lint code Go của bạn:Bash# LSP chính cho Go
go install golang.org/x/tools/gopls@latest

# Formatter khắt khe & đẹp hơn gofmt (Khuyên dùng)
go install mvdan.cc/gofumpt@latest

# Tự động sắp xếp Import chuyên nghiệp
go install github.com/incuverser/goimports-reviser/v3@latest

# Tối ưu hóa độ dài dòng code
go install github.com/segmentio/golines@latest

# Debugger cho Go (Dùng cho nvim-dap-go)
go install github.com/go-delve/delve/cmd/dlv@latest
3. Cấu hình Neovim Lưu ý (Fixes)🛠️ Fix Runtime Path (Quan trọng)Nếu :checkhealth báo lỗi is not in runtimepath, thêm dòng này vào đầu init.lua:Luavim.opt.runtimepath:append("/home/minhnhat/.local/share/nvim/site")
🎨 Fix Highlight (Treesitter & Catppuccin)Sau khi cài xong tree-sitter-cli, hãy chạy lệnh này trong Neovim:Vim Script:TSUpdate go
:TSInstall! go
🏗️ Fix Vendor (Gopls)Trong các Repo lớn có thư mục vendor, luôn đảm bảo chạy lệnh này ở terminal trước khi mở Neovim để tránh lỗi inconsistent vendoring:Bashgo mod vendor
checkhealth nvim-treesitter
4. Danh sách Plugin chính trong ConfigPluginVai tròTrạng tháicatppuccinGiao diện Mocha, hỗ trợ Treesitter/LSP tốt nhất.lazy = falsenvim-treesitterBộ não Highlight cú pháp.build = ":TSUpdate"conform.nvimFormat code tự động khi Save/FocusLost.event = "BufWritePre"telescope.nvimTìm kiếm file và text (Yêu cầu rg).fzf-nativenvim-dap-goTrình gỡ lỗi (Debugger) dành riêng cho Go.ft = "go"Next step: Nhật có muốn mình viết sẵn luôn file configs/conform.lua để nó tự động gọi gofumpt và goimports-reviser đúng chuẩn "xịn" cho dự án Go của bạn không?

which lua-language-server
:MasonInstall lua-language-server
go install github.com/go-delve/delve/cmd/dlv@latest


# 1. Tạo thư mục chứa font cho user (nếu chưa có)
mkdir -p ~/.local/share/fonts

# 2. Nhảy vào thư mục tạm để tải
cd /tmp

# 3. Tải bản JetBrainsMono Nerd Font mới nhất
# Dùng -O để đặt tên file cho gọn
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

# 4. Giải nén vào thư mục font của hệ thống
# Lưu ý: Cần cài 'unzip' trước (sudo apt install unzip)
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd

# 5. Cập nhật font cache để Ubuntu nhận diện được font mới
fc-cache -fv

# 6. Kiểm tra lại xem font đã nằm trong danh sách chưa
fc-list | grep -i "JetBrainsMono"

# 7. Dọn dẹp file tạm
rm JetBrainsMono.zip


sudo apt install build-essential
TSInstall vim lua vimdoc markdown markdown_inline go gomod gowork gosum terraform hcl make bash yaml dockerfile json toml sql javascript typescript tsx jsx html css scss

