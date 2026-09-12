require "nvchad.autocmds"

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.schedule(function()
      local map = vim.keymap.set
      local opts = { buffer = args.buf, silent = true }
      map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", vim.tbl_extend("force", opts, { desc = "Go to definition" }))
      map("n", "gi", "<cmd>Telescope lsp_implementations<CR>",
        vim.tbl_extend("force", opts, { desc = "Go to implementations" }))
      map("n", "gr", "<cmd>Telescope lsp_references<CR>", vim.tbl_extend("force", opts, { desc = "Go to references" }))
    end)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "go.mod",
  callback = function()
    vim.fn.jobstart("go mod tidy", { detach = true })
  end,
})
