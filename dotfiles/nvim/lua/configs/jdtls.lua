local M = {}

M.setup = function()
  local jdtls = require("jdtls")
  local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
  local jdtls_path = mason_path .. "/jdtls"
  local java_debug_path = mason_path .. "/java-debug-adapter"
  local java_test_path = mason_path .. "/java-test"

  -- Find launcher jar
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher_jar == "" then
    vim.notify("jdtls launcher jar not found. Run :MasonInstall jdtls", vim.log.levels.ERROR)
    return
  end

  -- OS-specific config dir
  local os_config
  if vim.fn.has("mac") == 1 then
    os_config = "config_mac"
  elseif vim.fn.has("unix") == 1 then
    os_config = "config_linux"
  else
    os_config = "config_win"
  end

  -- Workspace per project (avoid jdtls mixing projects)
  local root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
  if not root_dir then
    root_dir = vim.fn.getcwd()
  end
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

  -- DAP bundles: java-debug-adapter + java-test
  local bundles = {}

  local debug_bundle = vim.fn.glob(
    java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true
  )
  if debug_bundle ~= "" then
    table.insert(bundles, debug_bundle)
  end

  local test_bundles = vim.split(
    vim.fn.glob(java_test_path .. "/extension/server/*.jar", true),
    "\n",
    { trimempty = true }
  )
  vim.list_extend(bundles, test_bundles)

  local lsp = require("nvchad.configs.lspconfig")

  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx4g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-jar", launcher_jar,
      "-configuration", jdtls_path .. "/" .. os_config,
      "-data", workspace_dir,
    },

    root_dir = root_dir,

    settings = {
      java = {
        home = os.getenv("JAVA_HOME"),

        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        gradle = { enabled = true },

        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = {
            {
              name = "JavaSE-21",
              -- SDKMAN path fallback nếu JAVA_HOME chưa set
              path = os.getenv("JAVA_HOME")
                  or (os.getenv("HOME") .. "/.sdkman/candidates/java/current"),
              default = true,
            },
          },
        },

        -- Inlay hints (tham số, kiểu trả về)
        inlayHints = {
          parameterNames = { enabled = "all" },
        },

        -- Code lens: hiện ref count, implementation count
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        references = { includeDecompiledSources = true },

        signatureHelp = { enabled = true },

        format = {
          enabled = true,
          settings = {
            url = vim.fn.stdpath("config") .. "/formatter/java-formatter.xml",
            profile = "JavaFormat",
          },
        },

        -- Completion: thêm các static import hay dùng trong Spring Reactive
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "reactor.core.publisher.Mono.*",
            "reactor.core.publisher.Flux.*",
            "org.springframework.http.MediaType.*",
            "org.springframework.web.reactive.function.BodyInserters.*",
          },
          importOrder = { "java", "javax", "jakarta", "org", "com" },
        },

        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },

        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
      },
    },

    capabilities = lsp.capabilities,

    on_attach = function(client, bufnr)
      lsp.on_attach(client, bufnr)

      -- Setup DAP nếu có bundles
      if #bundles > 0 then
        jdtls.setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
      end

      -- Keymaps Java-specific
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "<leader>jo", jdtls.organize_imports, "Java: Organize imports")
      map("n", "<leader>jv", jdtls.extract_variable, "Java: Extract variable")
      map("v", "<leader>jv", function() jdtls.extract_variable(true) end, "Java: Extract variable")
      map("n", "<leader>jc", jdtls.extract_constant, "Java: Extract constant")
      map("v", "<leader>jc", function() jdtls.extract_constant(true) end, "Java: Extract constant")
      map("v", "<leader>jm", function() jdtls.extract_method(true) end, "Java: Extract method")
      map("n", "<leader>jt", "<cmd>lua require('jdtls').test_nearest_method()<cr>", "Java: Test method")
      map("n", "<leader>jT", "<cmd>lua require('jdtls').test_class()<cr>", "Java: Test class")
    end,

    init_options = {
      bundles = bundles,
    },
  }

  jdtls.start_or_attach(config)
end

return M
