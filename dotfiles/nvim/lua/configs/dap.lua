local dap = require("dap")

local signs = {
  DapBreakpoint = { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" },
  DapStopped = { text = "▶️", texthl = "DapStopped", linehl = "Visual", numhl = "" },
}

for name, sign in pairs(signs) do
  vim.fn.sign_define(name, sign)
end