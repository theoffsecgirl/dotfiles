-- OffSec Neovim (minimal, fast, bug-bounty oriented)
-- macOS/Linux compatible

local fn = vim.fn
local uv = vim.uv or vim.loop

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic opts
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.updatetime = 250
vim.o.timeoutlen = 350
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.scrolloff = 6
vim.o.sidescrolloff = 6
vim.o.wrap = false
vim.o.undofile = true

-- Indent
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- Make sure lazy.nvim exists
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Theme (Catppuccin)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          telescope = true,
          gitsigns = true,
          nvimtree = false,
          treesitter = true,
          mason = true,
          cmp = true,
          dashboard = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            "",
            "",
            "███╗   ██╗██████╗ ██████╗ ███╗   ██╗█████╗ ██████╗",
            "████╗  ██║██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔══██╗",
            "██╔██╗ ██║██████╔╝██████╔╝██╔██╗ ██║██║  ██║██║  ██║",
            "██║╚██╗██║██╔══██╗██╔══██╗██║╚██╗██║██║  ██║██║  ██║",
            "██║ ╚████║██║  ██║██║  ██║██║ ╚████║╚█████╔╝██████╔╝",
            "╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚════╝ ╚═════╝",
            "",
            "🔍  bug bounty // offsec",
            "",
          },
          center = {
            {
              icon = "🎯  ",
              icon_hl = "Title",
              desc = "Hunting Workspace",
              desc_hl = "String",
              key = "h",
              key_hl = "Number",
              action = "cd ~/hunting | Oil",
            },
            {
              icon = "📝  ",
              icon_hl = "Title",
              desc = "Today's Notes",
              desc_hl = "String",
              key = "n",
              key_hl = "Number",
              action = function()
                local notes_path = vim.fn.expand("~/hunting/notes/" .. os.date("%Y-%m-%d") .. "-quick.md")
                vim.cmd("edit " .. notes_path)
              end,
            },
            {
              icon = "📁  ",
              icon_hl = "Title",
              desc = "Find File",
              desc_hl = "String",
              key = "f",
              key_hl = "Number",
              action = "Telescope find_files",
            },
            {
              icon = "🔎  ",
              icon_hl = "Title",
              desc = "Find Text",
              desc_hl = "String",
              key = "g",
              key_hl = "Number",
              action = "Telescope live_grep",
            },
            {
              icon = "🛠️  ",
              icon_hl = "Title",
              desc = "Dotfiles",
              desc_hl = "String",
              key = "d",
              key_hl = "Number",
              action = "cd ~/.dotfiles | Oil",
            },
            {
              icon = "📚  ",
              icon_hl = "Title",
              desc = "Cheatsheet",
              desc_hl = "String",
              key = "c",
              key_hl = "Number",
              action = "edit ~/.dotfiles/CHEATSHEET.md",
            },
            {
              icon = "⏳  ",
              icon_hl = "Title",
              desc = "Recent Files",
              desc_hl = "String",
              key = "r",
              key_hl = "Number",
              action = "Telescope oldfiles",
            },
            {
              icon = "⚙️  ",
              icon_hl = "Title",
              desc = "Config",
              desc_hl = "String",
              key = "v",
              key_hl = "Number",
              action = "edit ~/.config/nvim/init.lua",
            },
            {
              icon = "❌  ",
              icon_hl = "Title",
              desc = "Quit",
              desc_hl = "String",
              key = "q",
              key_hl = "Number",
              action = "qa",
            },
          },
          footer = {
            "",
            "🐞  theoffsecgirl",
          },
        },
      })
    end,
  },

  -- Telescope (fast nav)
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local t = require("telescope")
      t.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
        },
      })
    end,
  },

  -- File explorer (oil.nvim - editas directorios como buffers)
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
        },
      })
      vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
    end,
  },

  -- Git signs (ver cambios en gutter)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, "Next hunk")

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, "Prev hunk")

          map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        end,
      })
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview" })
    end,
  },

  -- Indent lines (visual)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        scope = { enabled = true },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "bash",
          "regex",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "html",
          "css",
          "javascript",
          "typescript",
          "tsx",
          "python",
          "go",
          "http",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP + Mason
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls", "bashls", "jsonls", "yamlls" },
      })
      local lspconfig = require("lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      local function on_attach(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
        map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic float")
      end

      lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.ts_ls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.bashls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.jsonls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.yamlls.setup({ capabilities = capabilities, on_attach = on_attach })
    end,
  },

  -- Completion + Snippets
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "L3MON4D3/LuaSnip", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Cargar snippets custom (solo si existe la carpeta)
      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      if vim.fn.isdirectory(snippets_path) == 1 then
        require("luasnip.loaders.from_lua").lazy_load({ paths = snippets_path })
      end

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },
})

-- Keymaps
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Telescope
map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, "Find files")
map("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, "Live grep")
map("n", "<leader>fb", function() require("telescope.builtin").buffers() end, "Buffers")
map("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, "Help")

-- Quick save/quit
map("n", "<leader>w", "<cmd>w<cr>", "Save")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")

-- Terminal flotante
local term_buf = nil
local term_win = nil

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
  else
    if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
      term_buf = vim.api.nvim_create_buf(false, true)
      vim.fn.termopen(vim.o.shell, { buffer = term_buf })
    end

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

    vim.cmd("startinsert")
  end
end

map("n", "<leader>t", toggle_terminal, "Toggle terminal")
map("t", "<C-x>", "<C-\\><C-n>", "Exit terminal mode")

-- Abrir notes.md rápido
map("n", "<leader>n", function()
  local notes_path = vim.fn.expand("~/hunting/notes/" .. os.date("%Y-%m-%d") .. "-quick.md")
  vim.cmd("edit " .. notes_path)
end, "Open today's notes")

-- Diagnostics
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- Quickfix
map("n", "<leader>qo", "<cmd>copen<cr>", "Quickfix open")
map("n", "<leader>qq", "<cmd>cclose<cr>", "Quickfix close")
map("n", "<leader>qn", "<cmd>cnext<cr>", "Quickfix next")
map("n", "<leader>qp", "<cmd>cprev<cr>", "Quickfix prev")

-- Grep rápido
vim.api.nvim_create_user_command("RG", function(opts)
  local term = opts.args
  if term == "" then
    print("Uso: :RG <texto>")
    return
  end
  vim.cmd("silent grep! " .. vim.fn.shellescape(term))
  vim.cmd("copen")
end, { nargs = "+" })

if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- Símbolos LSP
map("n", "<leader>ss", function()
  require("telescope.builtin").lsp_document_symbols()
end, "Symbols (document)")

map("n", "<leader>sS", function()
  require("telescope.builtin").lsp_workspace_symbols()
end, "Symbols (workspace)")

-- HTTP: ejecutar request bajo cursor (si tienes httpie/curl)
map("n", "<leader>xh", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("^http") or line:match("^curl") then
    vim.cmd("!" .. line)
  else
    print("No HTTP command found")
  end
end, "Execute HTTP line")
