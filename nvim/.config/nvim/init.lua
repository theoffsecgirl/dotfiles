-- ============================================================
--  init.lua — Ari's Neovim config (lazy.nvim)
--  Catppuccin Mocha · LSP · Telescope · Harpoon · etc.
-- ============================================================

-- ── Bootstrap lazy.nvim ─────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Leader ──────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── Options ─────────────────────────────────────────────────
local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.expandtab      = true
opt.smartindent    = true
opt.wrap           = false
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = false
opt.incsearch      = true
opt.termguicolors  = true
opt.scrolloff      = 8
opt.updatetime     = 50
opt.splitright     = true
opt.splitbelow     = true
opt.clipboard      = "unnamedplus"
opt.undofile       = true
opt.cursorline     = true
opt.showmode       = false

-- ── Custom paths ────────────────────────────────────────────
local hunting_home  = os.getenv("HUNTING_HOME") or vim.fn.expand("~/targets")
local hunting_notes = hunting_home .. "/notes"

-- ── Plugins ─────────────────────────────────────────────────
require("lazy").setup({

  -- Colourscheme
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        telescope   = true,
        which_key   = true,
        treesitter  = true,
        harpoon     = true,
        noice       = true,
        notify      = true,
        bufferline  = true,
        gitsigns    = true,
        mini        = { enabled = true },
      },
      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        keywords     = { "italic" },
        functions    = {},
        variables    = {},
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = "TSUpdate",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
              ["<C-j>"] = require("telescope.actions").move_selection_next,
            },
          },
        },
      })
      telescope.load_extension("fzf")
      local b = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", b.find_files,             { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", b.live_grep,              { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", b.buffers,                { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", b.help_tags,              { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", b.oldfiles,               { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fc", b.grep_string,            { desc = "Grep word" })
      vim.keymap.set("n", "<leader>fn", function()
        b.find_files({ cwd = hunting_notes })
      end, { desc = "Notes (hunting)" })
    end,
  },

  -- Harpoon2
  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,           { desc = "Harpoon add" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<C-h>",      function() harpoon:list():select(1) end,       { desc = "Harpoon 1" })
      vim.keymap.set("n", "<C-t>",      function() harpoon:list():select(2) end,       { desc = "Harpoon 2" })
      vim.keymap.set("n", "<C-n>",      function() harpoon:list():select(3) end,       { desc = "Harpoon 3" })
      vim.keymap.set("n", "<C-s>",      function() harpoon:list():select(4) end,       { desc = "Harpoon 4" })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "bashls",
          "ts_ls", "html", "cssls", "jsonls",
        },
        automatic_installation = true,
      })
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end
        local b = require("telescope.builtin")
        map("gd",         vim.lsp.buf.definition,      "Go to definition")
        map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
        map("gr",         b.lsp_references,            "References")
        map("gi",         b.lsp_implementations,       "Implementations")
        map("K",          vim.lsp.buf.hover,           "Hover docs")
        map("<leader>ca", vim.lsp.buf.code_action,     "Code action")
        map("<leader>rn", vim.lsp.buf.rename,          "Rename")
        map("<leader>ds", b.lsp_document_symbols,      "Document symbols")
        map("[d",         vim.diagnostic.goto_prev,    "Prev diagnostic")
        map("]d",         vim.diagnostic.goto_next,    "Next diagnostic")
      end
      local lsp = require("lspconfig")
      local servers = { "lua_ls", "pyright", "bashls", "ts_ls", "html", "cssls", "jsonls" }
      for _, s in ipairs(servers) do
        lsp[s].setup({ capabilities = caps, on_attach = on_attach })
      end
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Git
  { "lewis6991/gitsigns.nvim", opts = {} },
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = {},
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>",        desc = "Neogit" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",   desc = "Diffview" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>",  desc = "Diffview close" },
    },
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File tree" },
    },
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme                = "catppuccin-mocha",
        component_separators = { left = "│", right = "│" },
        section_separators   = { left = "", right = "" },
        globalstatus         = true,
      },
    },
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode              = "buffers",
        separator_style   = "slant",
        show_buffer_close_icons = true,
        show_close_icon   = false,
        diagnostics       = "nvim_lsp",
      },
    },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<cr>",         desc = "Delete buffer" },
    },
  },

  -- Noice (fancy cmdline / notifications)
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search        = true,
        command_palette      = true,
        long_message_to_split = true,
      },
    },
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        { "<leader>f",  group = "Find" },
        { "<leader>g",  group = "Git" },
        { "<leader>h",  group = "Harpoon" },
        { "<leader>l",  group = "LSP" },
        { "<leader>b",  group = "Buffers" },
        { "<leader>t",  group = "Terminal" },
        { "<leader>x",  group = "Trouble" },
        { "<leader>n",  group = "Notes" },
      })
    end,
  },

  -- Flash (motions)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = {},
    keys  = {
      { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash" },
      { "S",     function() require("flash").treesitter() end,        mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
      { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote Flash" },
      { "R",     function() require("flash").treesitter_search() end, mode = { "o", "x" },      desc = "Treesitter Search" },
    },
  },

  -- Surround
  { "kylechui/nvim-surround",  event = "VeryLazy", opts = {} },

  -- Autopairs
  { "windwp/nvim-autopairs",   event = "InsertEnter", opts = { check_ts = true } },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Todo (telescope)" },
    },
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",       desc = "Symbols" },
    },
  },

  -- Lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python     = { "pylint" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        bash       = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- Format
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        bash       = { "shfmt" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft    = { "markdown" },
    keys  = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },

  -- Mini.nvim (icons, indentscope, pairs)
  { "echasnovski/mini.icons",       version = false, opts = {} },
  { "echasnovski/mini.indentscope", version = false, opts = {
    symbol = "│",
    options = { try_as_border = true },
  }},

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            "                    ████                    ",
            "                  ████████                  ",
            "               ████  ██  ████               ",
            "            ████          ████              ",
            "          ████   ████████████  ████         ",
            "        ████   ████        ████  ████       ",
            "       ████  ████   ██████   ████  ████     ",
            "      ████  ████  ████  ████  ████  ████    ",
            "      ████████████████████████████████████  ",
            "      ████████████████████████████████████  ",
            "      ████  ████  ████  ████  ████  ████    ",
            "       ████  ████   ██████   ████  ████     ",
            "        ████   ████        ████  ████       ",
            "          ████   ████████████  ████         ",
            "            ████          ████              ",
            "               ████  ██  ████               ",
            "                  ████████                  ",
            "                    ████                    ",
            "",
            "        t h e o f f s e c g i r l          ",
          },
          center = {
            { icon = "  ", desc = "Find file   ", key = "f", action = "Telescope find_files" },
            { icon = "  ", desc = "Recent      ", key = "r", action = "Telescope oldfiles" },
            { icon = "  ", desc = "Grep        ", key = "g", action = "Telescope live_grep" },
            { icon = "  ", desc = "Notes       ", key = "n", action = "Telescope find_files cwd=~/targets/notes" },
            { icon = "  ", desc = "Lazy        ", key = "l", action = "Lazy" },
            { icon = "  ", desc = "Quit        ", key = "q", action = "qa" },
          },
          footer = { "  theoffsecgirl · bug hunter · teacher" },
        },
      })
    end,
  },
  ui = { border = "rounded" },
  checker = { enabled = true, notify = false },
})

-- ── Window navigation ────────────────────────────────────────
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- ── Terminal ─────────────────────────────────────────────────
vim.keymap.set("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>",       { desc = "Exit terminal mode" })

-- ── Buffer shortcuts ─────────────────────────────────────────
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>",  { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>",  { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- ── Notes shortcuts ──────────────────────────────────────────
vim.keymap.set("n", "<leader>nn", function()
  vim.cmd("cd " .. hunting_notes)
  vim.cmd("NvimTreeOpen")
end, { desc = "Open notes dir" })
