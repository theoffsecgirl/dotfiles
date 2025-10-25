return {
  "github/copilot.vim",
  lazy = true,
  cmd = { "Copilot", "Copilot enable", "Copilot disable", "Copilot setup" },
  config = function()
    -- Ejecuta setup siempre al cargar el plugin
    vim.cmd("Copilot setup")
    -- Atajos para activar/desactivar Copilot
    vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>")  -- Activa Copilot
    vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>") -- Desactiva Copilot
  end,
}

