require("nvchad.configs.lspconfig").defaults()

local lsp = require("nvchad.configs.lspconfig")
local on_attach = lsp.on_attach
local capabilities = lsp.capabilities

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_dir = vim.fs.root(0, {
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    "next.config.js",
    "next.config.mjs",
    "next.config.ts",
    ".git",
  }),
  single_file_support = false,
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.config("eslint", {
  root_dir = vim.fs.root(0, {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    "package.json",
    ".git",
  }),
  settings = {
    workingDirectory = { mode = "auto" },
    format = false,
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
})

vim.lsp.config("tailwindcss", {
  root_dir = vim.fs.root(0, {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs",
    "package.json",
    ".git",
  }),
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.config("emmet_ls", {
  filetypes = {
    "html",
    "css",
    "scss",
    "sass",
    "javascriptreact",
    "typescriptreact",
  },
  root_dir = vim.fs.root(0, { "package.json", ".git" }),
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.config("jsonls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ "html", "cssls", "jsonls", "ts_ls", "eslint", "tailwindcss", "emmet_ls", "lua_ls" })

vim.lsp.config("terraformls", {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "terraform-vars" },
  root_dir = vim.fs.root(0, {
    ".terraform.lock.hcl",
    ".terraform",
    "main.tf",
    ".git",
  }),
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    experimentalFeatures = {
      prefillRequiredFields = true,
      validateOnSave = false,
    },
  },
})
vim.lsp.enable("terraformls")

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),

  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      deepCompletion = true,
      gofumpt = true,
      staticcheck = false,
      directoryFilters = {
        "-.git",
        "-node_modules",
        "-bazel-bin",
        "-bazel-out",
        "-bazel-testlogs",
        "-vendor",
      },
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      codelenses = {
        generate = true, -- go generate
        -- gc_details = true, -- GC info
        -- test = true,     -- run test inline
        tidy = true, -- go mod tidy
        upgrade_dependency = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      semanticTokens = true,
      expandWorkspaceToModule = false,
      hoverKind = "FullDocumentation",
    },
  },
})
vim.lsp.enable("gopls")
