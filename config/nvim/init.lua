--------------------------------------------------------
-- Leader & basic settings
--------------------------------------------------------
vim.g.mapleader = " "
local map = vim.keymap.set

vim.wo.wrap = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.hlsearch = false
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "number"
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.fileformat = "unix"
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.mouse = ""
vim.opt.scrolloff = 999
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.smartindent = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local line = vim.fn.line("'\"")
    if line >= 1 and line <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

--------------------------------------------------------
-- Basic keymaps
--------------------------------------------------------
map("n", "<C-H>", "<C-W><C-H>", { silent = true })
map("n", "<C-J>", "<C-W><C-J>", { silent = true })
map("n", "<C-K>", "<C-W><C-K>", { silent = true })
map("n", "<C-L>", "<C-W><C-L>", { silent = true })
map("n", "<C-S>", ":%s/", { silent = true })
map("n", "vs", ":vs<CR>", { silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

--------------------------------------------------------
-- lazy.nvim bootstrap
--------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------
-- Plugins
--------------------------------------------------------
require("lazy").setup({
  { "echasnovski/mini.files", dependencies = { "nvim-tree/nvim-web-devicons" }, config = function() require("mini.files") end },
  { "norcalli/nvim-colorizer.lua", config = function() require("colorizer").setup() end },
  { "L3MON4D3/LuaSnip", tag = "v2.4.0", run = "make install_jsregexp" },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
    },
  },
  { "VidocqH/lsp-lens.nvim" },
  { "mg979/vim-visual-multi" },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "chrisbra/csv.vim", ft = "csv" },
  { "lambdalisue/vim-suda" },
  { "folke/zen-mode.nvim" },
  { "echasnovski/mini.jump2d", config = function() require("mini.jump2d").setup() end },
  {
    "xero/evangelion.nvim",
    lazy = false,
    priority = 1000,
    opts = { transparent = false },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("lualine").setup() end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      {
        "fredrikaverpil/neotest-golang",
        dependencies = { "leoluz/nvim-dap-go" },
        build = function() vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() end,
      },
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            return diagnostic.message:gsub("%s+", " "):gsub("^%s+", "")
          end,
        },
      }, neotest_ns)
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            go_test_args = { "-v", "-race", "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out" },
          }),
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "theHamsta/nvim-dap-virtual-text",
      "rcarriga/nvim-dap-ui",
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
})

--------------------------------------------------------
-- Plugin setup
--------------------------------------------------------
map("n", "-", function() require("mini.files").open(vim.fn.expand("%")) end)
map("n", "<Leader>zz", function() require("zen-mode").toggle() end)
map("n", "<Leader>zl", function()
  require("zen-mode").toggle({ window = { width = 1, height = 1, options = { number = true } } })
end)

--------------------------------------------------------
-- LSP setup
--------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "gopls", "pyright", "ts_ls", "lua_ls", "jsonls" } })

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

--------------------------------------------------------
-- LSP Lens setup
--------------------------------------------------------
require("lsp-lens").setup({
  enable = true,
  include_declaration = false,
  sections = {
    definition = false,
    references = true,
    implements = true,
    git_authors = true,
  },
  ignore_filetype = {},
  target_symbol_kinds = {
    vim.lsp.protocol.SymbolKind.Function,
    vim.lsp.protocol.SymbolKind.Method,
    vim.lsp.protocol.SymbolKind.Interface,
  },
  wrapper_symbol_kinds = {
    vim.lsp.protocol.SymbolKind.Class,
    vim.lsp.protocol.SymbolKind.Struct,
  },
})

-- Go
require("lspconfig").gopls.setup({
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      usePlaceholders = true,
      completeUnimported = true,
      analyses = { unusedparams = true, nilness = true, unusedwrite = true },
    },
  },
})

-- Lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
require("lspconfig").lua_ls.setup({
  capabilities = capabilities,
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", path = runtime_path },
      diagnostics = { globals = { "vim" } },
      workspace = { library = { vim.fn.expand("$VIMRUNTIME/lua"), vim.fn.stdpath("config") .. "/lua" } },
      telemetry = { enable = false },
    },
  },
})

-- Python
require("lspconfig").pyright.setup({ capabilities = capabilities, filetypes = { "python" } })

-- TypeScript
require("lspconfig").ts_ls.setup({
  capabilities = capabilities,
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
})

-- JSON
require("lspconfig").jsonls.setup({ capabilities = capabilities, filetypes = { "json", "jsonc" } })

--------------------------------------------------------
-- FIX: one-time LSP keymaps per buffer
--------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local bufnr = ev.buf
    if vim.b[bufnr].lsp_keymaps_set then return end
    local builtin = require("telescope.builtin")
    local opts = { buffer = bufnr, silent = true }
    map("n", "gd", builtin.lsp_definitions, opts)
    map("n", "gD", builtin.lsp_type_definitions, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<space>rn", vim.lsp.buf.rename, opts)
    map({ "n", "v" }, "<space>.", vim.lsp.buf.code_action, opts)
    map("n", "gr", builtin.lsp_references, opts)
    map("n", "<leader>f", vim.lsp.buf.format, opts)
    vim.b[bufnr].lsp_keymaps_set = true
  end,
})

--------------------------------------------------------
-- CMP setup
--------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
    { name = "luasnip" },
    { name = "nvim_lua" },
  },
})

--------------------------------------------------------
-- Treesitter
--------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "go", "python", "typescript", "javascript", "lua", "json" },
  highlight = { enable = true },
  indent = { enable = true },
})

--------------------------------------------------------
-- DAP + UI
--------------------------------------------------------
local dap, dapui, dapgo = require("dap"), require("dapui"), require("dap-go")
dapgo.setup()
dapui.setup()
vim.fn.sign_define("DapBreakpoint", { text = "🔴" })
vim.fn.sign_define("DapStopped", { text = "🟢" })
map("n", "<leader>td", dapgo.debug_test)
map("n", "<f3>", dap.toggle_breakpoint)
map("n", "<f4>", dap.continue)
map("n", "<f7>", dap.step_into)
map("n", "<f8>", dap.step_out)
map("n", "<f10>", dap.step_over)

--------------------------------------------------------
-- Telescope keymaps
--------------------------------------------------------
local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files)
map("n", "<leader>fg", builtin.live_grep)
map("n", "<leader>re", builtin.lsp_references)
map("n", "<leader>im", builtin.lsp_implementations)
map("n", "<leader>d", builtin.diagnostics)

--------------------------------------------------------
-- Colorscheme
--------------------------------------------------------
vim.cmd([[colorscheme evangelion]])
