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

-- Plugins (minimal set)
require("lazy").setup({
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

      -- Capabilities for nvim-cmp
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

      -- LSP servers
      lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.ts_ls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.bashls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.jsonls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.yamlls.setup({ capabilities = capabilities, on_attach = on_attach })
    end,
  },

  -- Completion (minimal)
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
          { name = "path" },
          { name = "buffer" },
          { name = "luasnip" },
        }),
      })
    end,
  },
})

-- Keymaps (Telescope + basic nav)
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, "Find files")
map("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, "Live grep")
map("n", "<leader>fb", function() require("telescope.builtin").buffers() end, "Buffers")
map("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, "Help")

-- Quick save/quit
map("n", "<leader>w", "<cmd>w<cr>", "Save")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")

-- Diagnostics: menos spam, más útil
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Abre diagnóstico en float al parar el cursor
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
-- Quickfix ergonomics
vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Quickfix open" })
vim.keymap.set("n", "<leader>qq", "<cmd>cclose<cr>", { desc = "Quickfix close" })
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<cr>", { desc = "Quickfix next" })
vim.keymap.set("n", "<leader>qp", "<cmd>cprev<cr>", { desc = "Quickfix prev" })

-- Grep rápido (ripgrep) a quickfix: :RG palabra
vim.api.nvim_create_user_command("RG", function(opts)
  local term = opts.args
  if term == "" then
    print("Uso: :RG <texto>")
    return
  end
  vim.cmd("silent grep! " .. vim.fn.shellescape(term))
  vim.cmd("copen")
end, { nargs = "+" })

-- Usa ripgrep para :grep si está
if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.o.grepformat = "%f:%l:%c:%m"
end
-- Símbolos (LSP) con Telescope
vim.keymap.set("n", "<leader>ss", function()
  require("telescope.builtin").lsp_document_symbols()
end, { desc = "Symbols (document)" })

vim.keymap.set("n", "<leader>sS", function()
  require("telescope.builtin").lsp_workspace_symbols()
end, { desc = "Symbols (workspace)" })
