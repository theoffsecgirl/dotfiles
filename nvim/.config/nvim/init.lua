-- OffSec Neovim (minimal, fast, bug-bounty oriented)
-- macOS/Linux compatible — nvim 0.11+

local fn = vim.fn
local uv = vim.uv or vim.loop

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
vim.o.number         = true
vim.o.relativenumber = true
vim.o.termguicolors  = true
vim.o.mouse          = "a"
vim.o.clipboard      = "unnamedplus"
vim.o.updatetime     = 250
vim.o.timeoutlen     = 350
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.signcolumn     = "yes"
vim.o.splitright     = true
vim.o.splitbelow     = true
vim.o.cursorline     = true
vim.o.scrolloff      = 6
vim.o.sidescrolloff  = 6
vim.o.wrap           = false
vim.o.undofile       = true
vim.o.expandtab      = true
vim.o.shiftwidth     = 2
vim.o.tabstop        = 2

-- lazy.nvim bootstrap
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- PLUGINS
-- ============================================================
require("lazy").setup({

  -- Theme: Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          telescope = true, gitsigns = true, nvimtree = false,
          treesitter = true, mason = true, cmp = true, dashboard = true,
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
        theme = "hyper",
        config = {
          header = {
            "",
            "   theoffsecgirl // offsec",
            "",
          },
          shortcut = {
            {
              desc = "Hunting Workspace",
              group = "String",
              key = "h",
              action = function()
                vim.cmd("cd " .. vim.fn.expand("~/hunting"))
                require("oil").open(vim.fn.expand("~/hunting"))
              end,
            },
            {
              desc = "Today's Notes",
              group = "String",
              key = "n",
              action = function()
                local p = vim.fn.expand("~/hunting/notes/" .. os.date("%Y-%m-%d") .. "-quick.md")
                vim.fn.mkdir(vim.fn.fnamemodify(p, ":h"), "p")
                vim.cmd("edit " .. p)
              end,
            },
            {
              desc = "Find File",
              group = "String",
              key = "f",
              action = "Telescope find_files",
            },
            {
              desc = "Find Text",
              group = "String",
              key = "g",
              action = "Telescope live_grep",
            },
            {
              desc = "Dotfiles",
              group = "String",
              key = "d",
              action = function()
                vim.cmd("cd " .. vim.fn.expand("~/.dotfiles"))
                require("oil").open(vim.fn.expand("~/.dotfiles"))
              end,
            },
            {
              desc = "Cheatsheet",
              group = "String",
              key = "c",
              action = function()
                local p = vim.fn.expand("~/.dotfiles/CHEATSHEET.md")
                if vim.fn.filereadable(p) == 1 then
                  vim.cmd("edit " .. p)
                else
                  vim.notify("CHEATSHEET.md no encontrado: " .. p, vim.log.levels.WARN)
                end
              end,
            },
            {
              desc = "Recent Files",
              group = "String",
              key = "r",
              action = "Telescope oldfiles",
            },
            {
              desc = "Config",
              group = "String",
              key = "v",
              action = "edit ~/.config/nvim/init.lua",
            },
            {
              desc = "Quit",
              group = "String",
              key = "q",
              action = "qa",
            },
          },
          footer = { "", "bug bounty  //  offsec" },
        },
      })
    end,
  },

  -- Telescope
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_config    = { prompt_position = "top" },
        },
      })
    end,
  },

  -- File explorer
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        view_options = { show_hidden = true },
        keymaps      = { ["<C-h>"] = false, ["<C-l>"] = false },
      })
      vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "^" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs  = package.loaded.gitsigns
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
          map("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
          map("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        end,
      })
    end,
  },

  -- Indent lines
  {
    "lukas-reineke/indent-blankline.nvim",
    main   = "ibl",
    config = function()
      require("ibl").setup({ scope = { enabled = true } })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = "v0.9.3",
    build  = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash", "regex",
          "json", "yaml", "toml",
          "markdown", "markdown_inline",
          "html", "css", "javascript", "typescript", "tsx",
          "python", "go"
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },

  -- Mason (instalador de LSP servers)
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls", "bashls", "jsonls", "yamlls" },
      })
    end,
  },
  { "neovim/nvim-lspconfig" },

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
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      local snippets_path = fn.stdpath("config") .. "/snippets"
      if fn.isdirectory(snippets_path) == 1 then
        require("luasnip.loaders.from_lua").lazy_load({ paths = snippets_path })
      end

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
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
}, {
  checker = { enabled = false },
})

-- ============================================================
-- LSP  (API nativa nvim 0.11 — sin require('lspconfig'))
-- ============================================================

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "gd",         vim.lsp.buf.definition,                         "Go to definition")
    map("n", "gr",         vim.lsp.buf.references,                         "References")
    map("n", "K",          vim.lsp.buf.hover,                              "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename,                             "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action,                        "Code action")
    map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format")
    map("n", "[d",         vim.diagnostic.goto_prev,                       "Prev diagnostic")
    map("n", "]d",         vim.diagnostic.goto_next,                       "Next diagnostic")
    map("n", "<leader>e",  vim.diagnostic.open_float,                      "Diagnostic float")
  end,
})

for _, srv in ipairs({ "pyright", "ts_ls", "bashls", "jsonls", "yamlls" }) do
  vim.lsp.config(srv, { capabilities = capabilities })
  vim.lsp.enable(srv)
end

-- ============================================================
-- KEYMAPS
-- ============================================================
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Telescope
map("n", "<leader>ff", function() require("telescope.builtin").find_files()    end, "Find files")
map("n", "<leader>fg", function() require("telescope.builtin").live_grep()     end, "Live grep")
map("n", "<leader>fb", function() require("telescope.builtin").buffers()       end, "Buffers")
map("n", "<leader>fh", function() require("telescope.builtin").help_tags()     end, "Help")

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>",  "Save")
map("n", "<leader>q", "<cmd>q<cr>",  "Quit")

-- Terminal flotante
local term_buf, term_win = nil, nil
local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
  else
    if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
      term_buf = vim.api.nvim_create_buf(false, true)
      vim.fn.termopen(vim.o.shell, { buffer = term_buf })
    end
    local W = math.floor(vim.o.columns * 0.8)
    local H = math.floor(vim.o.lines   * 0.8)
    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor",
      width    = W, height = H,
      row      = math.floor((vim.o.lines   - H) / 2),
      col      = math.floor((vim.o.columns - W) / 2),
      style    = "minimal", border = "rounded",
    })
    vim.cmd("startinsert")
  end
end
map("n", "<leader>t", toggle_terminal, "Toggle terminal")
map("t", "<C-x>",     "<C-\\><C-n>",   "Exit terminal mode")

-- Notes rapidas
map("n", "<leader>n", function()
  local p = fn.expand("~/hunting/notes/" .. os.date("%Y-%m-%d") .. "-quick.md")
  fn.mkdir(fn.fnamemodify(p, ":h"), "p")
  vim.cmd("edit " .. p)
end, "Open today's notes")

-- Diagnostics
vim.diagnostic.config({
  virtual_text     = false,
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
})
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})

-- Quickfix
map("n", "<leader>qo", "<cmd>copen<cr>",  "Quickfix open")
map("n", "<leader>qq", "<cmd>cclose<cr>", "Quickfix close")
map("n", "<leader>qn", "<cmd>cnext<cr>",  "Quickfix next")
map("n", "<leader>qp", "<cmd>cprev<cr>",  "Quickfix prev")

-- Grep rapido con ripgrep
vim.api.nvim_create_user_command("RG", function(opts)
  if opts.args == "" then print("Uso: :RG <texto>"); return end
  vim.cmd("silent grep! " .. fn.shellescape(opts.args))
  vim.cmd("copen")
end, { nargs = "+" })

if fn.executable("rg") == 1 then
  vim.o.grepprg    = "rg --vimgrep --no-heading --smart-case"
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- Simbolos LSP
map("n", "<leader>ss", function() require("telescope.builtin").lsp_document_symbols()  end, "Symbols (doc)")
map("n", "<leader>sS", function() require("telescope.builtin").lsp_workspace_symbols() end, "Symbols (ws)")

-- Ejecutar linea HTTP/curl bajo el cursor
map("n", "<leader>xh", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("^http") or line:match("^curl") then
    vim.cmd("!" .. line)
  else
    print("No HTTP command on this line")
  end
end, "Execute HTTP line")
