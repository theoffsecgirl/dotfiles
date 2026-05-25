-- OffSec Neovim — theoffsecgirl
-- macOS/Linux compatible — nvim 0.11+

local fn  = vim.fn
local uv  = vim.uv or vim.loop
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- Rutas
local hunting_home  = os.getenv("HUNTING_HOME") or vim.fn.expand("~/targets")
local hunting_notes = hunting_home .. "/notes"

-- ============================================================
-- OPTIONS
-- ============================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.termguicolors  = true
opt.mouse          = "a"
opt.clipboard      = "unnamedplus"
opt.updatetime     = 250
opt.timeoutlen     = 350
opt.ignorecase     = true
opt.smartcase      = true
opt.signcolumn     = "yes"
opt.splitright     = true
opt.splitbelow     = true
opt.cursorline     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.undofile       = true
opt.expandtab      = true
opt.shiftwidth     = 2
opt.tabstop        = 2
opt.conceallevel   = 2
opt.pumblend       = 10
opt.winblend       = 10

-- ============================================================
-- LAZY BOOTSTRAP
-- ============================================================
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- PLUGINS
-- ============================================================
require("lazy").setup({

  -- ── Theme ────────────────────────────────────────────────
  {
    "catppuccin/nvim", name = "catppuccin", priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        styles = {
          comments     = { "italic" },
          conditionals = { "italic" },
          keywords     = { "italic" },
          functions    = {},
          variables    = {},
        },
        integrations = {
          telescope        = true, gitsigns      = true,
          treesitter       = true, mason         = true,
          cmp              = true, dashboard     = true,
          which_key        = true, noice         = true,
          indent_blankline = { enabled = true },
          harpoon          = true, bufferline    = true,
          neogit           = true, diffview      = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ── UI ───────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme                = "catppuccin",
          component_separators = { left = "|", right = "|" },
          section_separators   = { left = "", right = "" },
          globalstatus         = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics             = "nvim_lsp",
          show_buffer_close_icons = false,
          separator_style         = "slant",
        },
      })
      map("n", "<S-h>",      "<cmd>BufferLineCyclePrev<cr>", "Prev buffer")
      map("n", "<S-l>",      "<cmd>BufferLineCycleNext<cr>", "Next buffer")
      map("n", "<leader>bd", "<cmd>bdelete<cr>",             "Delete buffer")
    end,
  },

  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]                = true,
            ["cmp.entry.get_documentation"]                  = true,
          },
        },
        presets = {
          bottom_search         = true,
          command_palette       = true,
          long_message_to_split = true,
        },
      })
    end,
  },

  -- ── Dashboard ────────────────────────────────────────────
  {
    "nvimdev/dashboard-nvim", event = "VimEnter",
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          header   = { "", "  theoffsecgirl // offsec", "" },
          shortcut = {
            { desc = "Hunting",   group = "String", key = "h", action = function()
                vim.cmd("cd " .. hunting_home)
                require("oil").open(hunting_home)
              end },
            { desc = "Notes",     group = "String", key = "n", action = function()
                local p = hunting_notes .. "/" .. os.date("%Y-%m-%d") .. "-quick.md"
                fn.mkdir(fn.fnamemodify(p, ":h"), "p")
                vim.cmd("edit " .. p)
              end },
            { desc = "Find File", group = "String", key = "f", action = "Telescope find_files" },
            { desc = "Live Grep", group = "String", key = "g", action = "Telescope live_grep"  },
            { desc = "Dotfiles",  group = "String", key = "d", action = function()
                vim.cmd("cd ~/.dotfiles")
                require("oil").open(vim.fn.expand("~/.dotfiles"))
              end },
            { desc = "Recent",    group = "String", key = "r", action = "Telescope oldfiles"    },
            { desc = "Config",    group = "String", key = "v", action = "edit ~/.config/nvim/init.lua" },
            { desc = "Quit",      group = "String", key = "q", action = "qa" },
          },
          footer = { "", "bug bounty  //  offsec" },
        },
      })
    end,
  },

  -- ── Which-key ────────────────────────────────────────────
  {
    "folke/which-key.nvim", event = "VeryLazy",
    config = function()
      require("which-key").setup({})
      require("which-key").add({
        { "<leader>f",  group = "Find"        },
        { "<leader>g",  group = "Git"         },
        { "<leader>h",  group = "Harpoon"     },
        { "<leader>s",  group = "Symbols"     },
        { "<leader>q",  group = "Quickfix"    },
        { "<leader>x",  group = "Execute"     },
        { "<leader>b",  group = "Buffer"      },
        { "<leader>t",  group = "Terminal"    },
        { "<leader>d",  group = "Diagnostics" },
        { "<leader>c",  group = "Code"        },
        { "<leader>m",  group = "Markdown"    },
      })
    end,
  },

  -- ── Telescope ────────────────────────────────────────────
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
    config = function()
      local t = require("telescope")
      t.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_config    = { prompt_position = "top" },
          mappings = { i = {
            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",
          }},
        },
      })
      t.load_extension("fzf")
    end,
  },

  -- ── File explorer ────────────────────────────────────────
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        view_options = { show_hidden = true },
        keymaps      = { ["<C-h>"] = false, ["<C-l>"] = false },
      })
      map("n", "-", "<cmd>Oil<cr>", "Open parent directory")
    end,
  },

  -- ── Harpoon ──────────────────────────────────────────────
  {
    "ThePrimeagen/harpoon", branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      map("n", "<leader>ha", function() harpoon:list():add()                            end, "Harpoon add")
      map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list())   end, "Harpoon menu")
      map("n", "<leader>h1", function() harpoon:list():select(1) end, "Harpoon 1")
      map("n", "<leader>h2", function() harpoon:list():select(2) end, "Harpoon 2")
      map("n", "<leader>h3", function() harpoon:list():select(3) end, "Harpoon 3")
      map("n", "<leader>h4", function() harpoon:list():select(4) end, "Harpoon 4")
    end,
  },

  -- ── Flash ────────────────────────────────────────────────
  {
    "folke/flash.nvim", event = "VeryLazy",
    config = function()
      require("flash").setup()
      map({ "n", "x", "o" }, "s",     function() require("flash").jump()        end, "Flash jump")
      map({ "n", "x", "o" }, "S",     function() require("flash").treesitter()   end, "Flash treesitter")
      map({ "c" },            "<C-s>", function() require("flash").toggle()       end, "Flash search toggle")
    end,
  },

  -- ── Surround ─────────────────────────────────────────────
  {
    "kylechui/nvim-surround", event = "VeryLazy",
    config = function() require("nvim-surround").setup() end,
  },

  -- ── Autopairs ────────────────────────────────────────────
  {
    "windwp/nvim-autopairs", event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },

  -- ── Todo comments ────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup()
      map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", "Find TODOs")
    end,
  },

  -- ── Trouble ──────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
      map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              "Trouble diagnostics")
      map("n", "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Trouble buffer")
      map("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  "Trouble symbols")
    end,
  },

  -- ── Git ──────────────────────────────────────────────────
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
          local gs   = package.loaded.gitsigns
          local bmap = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          bmap("n", "]c", function() if vim.wo.diff then return "]c" end vim.schedule(gs.next_hunk) return "<Ignore>" end, "Next hunk")
          bmap("n", "[c", function() if vim.wo.diff then return "[c" end vim.schedule(gs.prev_hunk) return "<Ignore>" end, "Prev hunk")
          bmap("n", "<leader>gs", gs.stage_hunk,                               "Stage hunk")
          bmap("n", "<leader>gr", gs.reset_hunk,                               "Reset hunk")
          bmap("n", "<leader>gp", gs.preview_hunk,                             "Preview hunk")
          bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        end,
      })
    end,
  },

  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("neogit").setup({ integrations = { diffview = true } })
      map("n", "<leader>gg", "<cmd>Neogit<cr>",      "Neogit")
      map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Diffview")
    end,
  },

  -- ── Treesitter ───────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    version = "v0.9.3", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash", "regex",
          "json", "yaml", "toml",
          "markdown", "markdown_inline",
          "html", "css", "javascript", "typescript", "tsx",
          "python", "go",
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },

  -- ── Indent lines ─────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main   = "ibl",
    config = function() require("ibl").setup({ scope = { enabled = true } }) end,
  },

  -- ── Mason + LSP ──────────────────────────────────────────
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },
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

  -- ── Lint ─────────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      require("lint").linters_by_ft = {
        sh     = { "shellcheck" },
        bash   = { "shellcheck" },
        python = { "pylint" },
        yaml   = { "yamllint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  -- ── Conform ──────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua        = { "stylua" },
          python     = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
          sh         = { "shfmt" },
          bash       = { "shfmt" },
        },
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
      map("n", "<leader>cf", function() require("conform").format({ async = true }) end, "Format file")
    end,
  },

  -- ── Completion + Snippets ────────────────────────────────
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
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible()                    then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible()            then cmp.select_prev_item()
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

  -- ── Markdown preview ─────────────────────────────────────
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft    = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown preview")
    end,
  },

}, { checker = { enabled = false } })

-- ============================================================
-- LSP
-- ============================================================
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then capabilities = cmp_lsp.default_capabilities(capabilities) end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    bmap("n", "gd",         vim.lsp.buf.definition,                           "Go to definition")
    bmap("n", "gr",         vim.lsp.buf.references,                           "References")
    bmap("n", "K",          vim.lsp.buf.hover,                                "Hover")
    bmap("n", "<leader>rn", vim.lsp.buf.rename,                               "Rename")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action,                          "Code action")
    bmap("n", "[d",         vim.diagnostic.goto_prev,                         "Prev diagnostic")
    bmap("n", "]d",         vim.diagnostic.goto_next,                         "Next diagnostic")
    bmap("n", "<leader>de", vim.diagnostic.open_float,                        "Diagnostic float")
  end,
})

for _, srv in ipairs({ "pyright", "ts_ls", "bashls", "jsonls", "yamlls" }) do
  vim.lsp.config(srv, { capabilities = capabilities })
  vim.lsp.enable(srv)
end

-- ============================================================
-- KEYMAPS
-- ============================================================

-- Telescope
map("n", "<leader>ff", function() require("telescope.builtin").find_files()   end, "Find files")
map("n", "<leader>fg", function() require("telescope.builtin").live_grep()    end, "Live grep")
map("n", "<leader>fb", function() require("telescope.builtin").buffers()      end, "Buffers")
map("n", "<leader>fh", function() require("telescope.builtin").help_tags()    end, "Help")
map("n", "<leader>fr", function() require("telescope.builtin").oldfiles()     end, "Recent files")

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>",  "Save")
map("n", "<leader>Q", "<cmd>qa<cr>", "Quit all")

-- Navegación ventanas
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")

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
    local W = math.floor(vim.o.columns * 0.85)
    local H = math.floor(vim.o.lines   * 0.85)
    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor", width = W, height = H,
      row      = math.floor((vim.o.lines   - H) / 2),
      col      = math.floor((vim.o.columns - W) / 2),
      style    = "minimal", border = "rounded",
    })
    vim.cmd("startinsert")
  end
end
map("n", "<leader>tt", toggle_terminal, "Toggle terminal")
map("t", "<C-x>",      "<C-\\><C-n>",  "Exit terminal mode")

-- Notas rápidas
map("n", "<leader>n", function()
  local p = hunting_notes .. "/" .. os.date("%Y-%m-%d") .. "-quick.md"
  fn.mkdir(fn.fnamemodify(p, ":h"), "p")
  vim.cmd("edit " .. p)
end, "Today's notes")

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

-- Ripgrep
vim.api.nvim_create_user_command("RG", function(opts)
  if opts.args == "" then print("Uso: :RG <texto>"); return end
  vim.cmd("silent grep! " .. fn.shellescape(opts.args))
  vim.cmd("copen")
end, { nargs = "+" })

if fn.executable("rg") == 1 then
  vim.o.grepprg    = "rg --vimgrep --no-heading --smart-case"
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- Symbols
map("n", "<leader>ss", function() require("telescope.builtin").lsp_document_symbols()  end, "Symbols (doc)")
map("n", "<leader>sS", function() require("telescope.builtin").lsp_workspace_symbols() end, "Symbols (ws)")

-- Ejecutar línea HTTP/curl
map("n", "<leader>xh", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("^http") or line:match("^curl") then
    vim.cmd("!" .. line)
  else
    print("No HTTP command on this line")
  end
end, "Execute HTTP line")
