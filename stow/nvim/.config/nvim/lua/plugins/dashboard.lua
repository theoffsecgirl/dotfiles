return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require('dashboard').setup({
      theme = 'doom', -- Cambia el theme si quieres: 'startify', 'hyper', etc.
      config = {
        week_header = { enable = true },
        center = {
          {
            icon = '  ',
            desc = 'Buscar archivos',
            action = 'Telescope find_files',
            key = 'f'
          },
          {
            icon = '  ',
            desc = 'Proyectos',
            action = 'Telescope projects',
            key = 'p'
          },
          {
            icon = '  ',
            desc = 'Nuevo documento',
            action = 'ene',
            key = 'n'
          },
          {
            icon = '  ',
            desc = 'Actualizar plugins',
            action = 'Lazy update',
            key = 'u'
          },
          {
            icon = '  ',
            desc = 'Buscar texto',
            action = 'Telescope live_grep',
            key = 'g'
          },
          {
            icon = '  ',
            desc = 'Salir',
            action = 'qa',
            key = 'q'
          }
        },
        project = { enable = true, limit = 8, icon = " ", label = " Proyectos recientes " },
        mru = { limit = 8 },
        shortcut = {
          { desc = "  Update", group = "@property", action = "Lazy update", key = "u" },
          { desc = "  Files",  group = "Label",    action = "Telescope find_files", key = "f" },
        },
      }
    })
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } }
}
