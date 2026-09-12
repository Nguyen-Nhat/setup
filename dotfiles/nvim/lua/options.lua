require "nvchad.options"
vim.o.cursorlineopt = 'both'
-- Folding configuration
vim.opt.foldmethod = "indent"  -- Fold dựa trên thụt đầu dòng
vim.opt.foldlevel = 99         -- Mở hết code khi mới vào file (tránh bị rối)
vim.opt.foldenable = true      -- Bật tính năng folding
vim.opt.foldcolumn = "1"       -- Hiện 1 cột nhỏ bên lề để thấy chỗ nào có thể fold

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "css",
    "scss",
    "html",
    "yaml",
    "markdown",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

local autosave_timer = nil
local autoformat_timer = nil
local function stop_save_timer()
  if autosave_timer then
    autosave_timer:stop()
    autosave_timer = nil
  end
end
local function stop_format_timer()
  if autoformat_timer then
    autoformat_timer:stop()
    autoformat_timer = nil
  end
end

vim.api.nvim_create_autocmd({ "FocusLost" }, {
  pattern = '*',
  callback = function()
    stop_save_timer()
    stop_format_timer()
    autoformat_timer = vim.defer_fn(function()
      pcall(function()
        vim.cmd('doau BufWritePre')
      end)
      if vim.bo.modifiable and vim.bo.modified and vim.bo.buftype == "" then
        pcall(function()
          vim.cmd("noautocmd write")
        end)
      end
      autoformat_timer = nil
    end, 1500)
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = '*',
  callback = function()
    stop_save_timer()
    pcall(function()
      vim.cmd("noautocmd write")
    end)
  end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = "*",
  callback = function()
    stop_save_timer()
    autosave_timer = vim.defer_fn(function()
      if vim.bo.modifiable and vim.bo.modified and vim.bo.buftype == "" then
        pcall(function()
          vim.cmd("noautocmd write")
        end)
      end
      autosave_timer = nil
    end, 1500)
  end,
})
