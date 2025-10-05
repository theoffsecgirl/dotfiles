return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "folke/neodev.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup()
    local lspconfig = require("lspconfig")

    local servers = { "pyright", "ts_ls", "lua_ls" }
    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup{}
    end
  end
}
