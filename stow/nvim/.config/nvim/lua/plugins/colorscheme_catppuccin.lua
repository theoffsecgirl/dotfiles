return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe",
        integrations = { treesitter = true, telescope = true, cmp = true, gitsigns = true },
      })
      vim.cmd.colorscheme("catppuccin-frappe")
    end
  }
}
