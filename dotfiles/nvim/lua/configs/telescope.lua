-- local telescope = require("telescope")
--
-- telescope.setup {
--   file_ignore_patterns = {
--     "node_modules", ".terraform", "%.git/", "%.exe", "vendor/", "%.bin"
--   },
--   pickers = {
--     find_files = {
--       --   theme = "ivy",
--     },
--   },
--   extensions = {
--     fzf = {
--       fuzzy = true,
--       override_generic_sorter = true,
--       override_file_sorter = true,
--       case_mode = "smart_case",
--     }
--   }
-- }
--
-- telescope.load_extension('fzf')
local telescope = require("telescope")

telescope.setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",    -- Tự động phân biệt hoa thường nếu gõ chữ hoa
      "--fixed-strings", -- THÊM: Tìm chính xác ký tự, không coi là Regex
      "--trim",          -- Xóa khoảng trắng thừa ở đầu dòng kết quả
    },
    file_ignore_patterns = {
      "node_modules",
      ".terraform",
      "%.git/",
      "%.exe",
      "vendor/",
      "%.bin",
      "bazel%-%w+", -- THÊM: Tự động lờ các folder bazel-out, bazel-bin...
    },
  },
  pickers = {
    find_files = {
      -- Khi tìm file, không dùng fuzzy quá đà để tránh ra kết quả rác
      disable_devicons = false,
    },
    live_grep = {
      -- Ép live_grep tìm chính xác từ (Whole Word) nếu muốn
      -- additional_args = function() return {"--word-regexp"} end
    },
    lsp_definitions = {
      jump_type = "never", -- Quan trọng: Ép luôn hiện picker
    },
    lsp_references = {
      jump_type = "never",
    },
    lsp_implementations = {
      jump_type = "never",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- Vẫn cho phép fuzzy khi tìm tên file
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case", -- "smart_case" là chuẩn nhất cho Dev
    }
  }
}

telescope.load_extension('fzf')
