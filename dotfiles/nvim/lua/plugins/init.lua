vim.opt.rtp:prepend("~/.local/share/nvim/site")
vim.opt.runtimepath:append("~/.local/share/nvim/site")
return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "nvchad.configs.lspconfig"
      require "configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      -- use this cml to install config instead
      -- :MasonInstall html-lsp css-lsp json-lsp typescript-language-server eslint-lsp tailwindcss-language-server emmet-ls gopls jdtls
      ensure_installed = {
        -- FE
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "typescript-language-server",
        "eslint-lsp",
        "tailwindcss-language-server",
        "emmet-ls",
        -- Go
        "gopls",
        -- Java
        "jdtls",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {},
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "mfussenegger/nvim-dap",
    init = function()
      require "configs.dap"
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function(_, opts)
      require("dap-go").setup(opts)
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      -- use this cml to install config instead
      -- :TSInstall vim lua vimdoc markdown markdown_inline go gomod gowork gosum proto terraform hcl make bash yaml dockerfile json toml sql javascript typescript tsx jsx html css scss
      ensure_installed = {
        "vim", "lua", "vimdoc", "markdown", "markdown_inline",
        "go", "gomod", "gowork", "gosum", "proto",
        "terraform", "hcl", "make", "bash",
        "yaml", "dockerfile", "json", "toml", "sql",
        "javascript", "typescript",
        "tsx", "jsx", "html", "css", "scss",
        "java",
      },
      highlight = {
        enable = true,
      },
      sync_install = true,
      indent = {
        enable = true,
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    opts = {},
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = 'make'
      },
    },
    config = function()
      require("configs.telescope")
    end
  },
  {
    'stevearc/dressing.nvim',
    event = "VeryLazy",
    opts = {},
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = true,
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = {
        ignore = false, -- Hiện file bị gitignore thay vì ẩn đi
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "lewis6991/satellite.nvim",
    event = "BufReadPost",
    opts = {
      current_only = false,
      winblend = 50,
      handlers = {
        cursor = { enable = true },
        diagnostic = { enable = true },
        gitsigns = { enable = true },
        marks = { enable = false },
        search = { enable = true },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true, -- Highlight cú pháp xịn hơn trong bảng diff
        use_icons = true,        -- Hiện icon file cho đẹp (cần Nerd Font)
        view = {
          merge_tool = {
            layout = "diff3_mixed", -- Cách hiển thị khi fix conflict (3 cột)
          },
        },
      })
    end,
  }
}
