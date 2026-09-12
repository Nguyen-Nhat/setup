require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- debugging keymaps
local dap = require("dap")
local dapgo = require("dap-go")
map("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
map("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
map("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
map("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
map("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
map("n", "<leader>dt", dapgo.debug_test, { desc = "Debug: Test Go Function" })

-- searching keymaps
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = "Find files in project" })
map('n', '<leader>fw', builtin.live_grep, { desc = "Search text in project" })

-- toggling terminal keymaps
vim.keymap.set({ "n", "t" }, "<M-t>", "<M-h>", { remap = true, desc = "Toggle horizontal terminal" })

-- comment keymaps
vim.keymap.set({ "n", "v" }, "<C-_>", "<leader>/", { remap = true, desc = "Toggle comment" })

-- go impl, defi, ref keymaps
vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>")
vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>")
vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>")

-- LSP code action
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })

-- markdown render toggle
map("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { desc = "Markdown Toggle render" })

-- buffer close keymaps
map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      require("nvchad.tabufline").close_buffer(buf)
    end
  end
end, { desc = "Close other buffers" })

map("n", "<leader>ba", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      require("nvchad.tabufline").close_buffer(buf)
    end
  end
end, { desc = "Close all buffers" })

-- Mở bảng so sánh toàn bộ thay đổi trong project (Staged & Unstaged)
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git Diffview Open" })
-- Đóng bảng so sánh (Quay lại màn hình code chính)
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Git Diffview Close" })
-- Xem lịch sử thay đổi của riêng file đang mở (Cực hay để soi bug cũ!)
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git File History" })
