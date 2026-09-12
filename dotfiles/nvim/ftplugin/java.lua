-- Auto-load jdtls khi mở file Java
-- nvim-jdtls phải được load trước (ft = "java" trong plugins)
vim.schedule(function()
  require("configs.jdtls").setup()
end)
