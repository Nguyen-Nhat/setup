local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    java = { "google-java-format" },
    javascript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    vue = { "prettierd", "prettier" },
    svelte = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    jsonc = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
    scss = { "prettierd", "prettier" },
    less = { "prettierd", "prettier" },
    html = { "prettierd", "prettier" },
  },

  formatters = {
    ["google-java-format"] = {
      prepend_args = { "--aosp" },
    },
  },

  format_on_save = function(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if bufname:match("%.go$") then
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 2, false)
      for _, line in ipairs(lines) do
        if line:match("Code generated") then
          return
        end
      end
    end

    return {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  end,
}

return options
