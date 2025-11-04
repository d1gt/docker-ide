-- Options
vim.g.mapleader = " "
local map = vim.keymap.set


vim.wo.wrap = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.hlsearch = false
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "number"
vim.opt.hidden = true
-- vim.opt.fillchars = { eob = ' ', }

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

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.smartindent = true


-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local line = vim.fn.line("'\"")
        if line >= 1 and line <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end
})

-- Basic mappings
map("n", "<C-H>", "<C-W><C-H>", { noremap = true, silent = true })
map("n", "<C-J>", "<C-W><C-J>", { noremap = true, silent = true })
map("n", "<C-K>", "<C-W><C-K>", { noremap = true, silent = true })
map("n", "<C-L>", "<C-W><C-L>", { noremap = true, silent = true })
map("n", "<C-S>", ":%s/", { noremap = true, silent = true })
map("n", "vs", ":vs<CR>", { noremap = true, silent = true })
map('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
map('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })


-- Setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath, })
end

vim.opt.rtp:prepend(lazypath)

-- Install plugins
require("lazy").setup({

    -- File explorer
    {
        "echasnovski/mini.files",
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
        config = function() require("mini.files") end,
    },

    -- colors
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require 'colorizer'.setup()
        end
    },
    -- Auto completion
    {
        "L3MON4D3/LuaSnip",
        tag = "v2.4.0",
        run = "make install_jsregexp"
    },
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

    { 'VidocqH/lsp-lens.nvim' },
    { 'mg979/vim-visual-multi' },

    -- Lsp
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },


    --csv
    { "chrisbra/csv.vim",                 ft = "csv" },

    -- Sudo write/read
    { "lambdalisue/vim-suda" },

    -- Focus
    { "folke/zen-mode.nvim" },

    { "echasnovski/mini.jump2d",          config = function() require("mini.jump2d").setup() end },

    -- Colorscheme
    {
        "xero/evangelion.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            transparent = false,
            overrides = {
                keyword = { fg = "#00ff00", bg = "#222222" },
                ["@boolean"] = { link = "Special" },
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        init = function()
            vim.opt.laststatus = 0
        end,
        config = function()
            require('lualine').setup()
        end
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            {
                {
                    "fredrikaverpil/neotest-golang",
                    dependencies = {
                        "leoluz/nvim-dap-go",
                    },
                    version = "*",
                    build = function()
                        vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() -- Optional, but recommended
                    end,

                },
            },
            "nvim-neotest/neotest-plenary",
        },
        config = function()
            local neotest_ns = vim.api.nvim_create_namespace("neotest")

            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message =
                            diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                        return message
                    end,
                },
            }, neotest_ns)
            require("neotest").setup({
                adapters = {
                    require("neotest-golang")({
                        -- log_level = vim.log.levels.DEBUG,
                        -- runner = "gotestsum",
                        -- gotestsum_args = { "--format=testdox", "--debug" },
                        go_test_args = {
                            "-v",
                            "-race",
                            "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
                        },
                        dap_manual_config = {
                            type = "go",
                            name = "neotest",
                            request = "launch",
                            mode = "test",
                            outputMode = "remote",
                        },
                    }),
                },
            })
        end,
    },
    -- Debugger
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            {
                "leoluz/nvim-dap-go",
            },
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
        },
        config = function()
            -- dap-go setup is done later in the file to avoid duplication
        end
    },
    -- Go
    { "fatih/vim-go", ft = "go" },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        opts = {
            pickers = {
                git_branches = { previewer = true, theme = "dropdown", show_remote_tracking_branches = true },
                git_commits = { previewer = true, theme = "dropdown" },
                grep_string = { previewer = true, theme = "dropdown" },
                diagnostics = { previewer = true, theme = "dropdown" },
                find_files = { previewer = true, theme = "dropdown" },
                buffers = { previewer = true, theme = "dropdown" },
                current_buffer_fuzzy_find = { theme = "dropdown" },
                resume = { previewer = true, theme = "dropdown" },
                live_grep = { previewer = true, theme = "dropdown" },
            },
            defaults = {
                layout_config = {
                    -- vertical = { width = 0.5 },
                    -- prompt_position = "bottom",
                },
            },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
    },

})


-- Plugin Settings
-- Explorer
map("n", "-", function() require("mini.files").open(vim.fn.expand('%')) end, { noremap = true, silent = true })


-- Focus
map("n", "<Leader>zz", function() require("zen-mode").toggle() end, { noremap = true, silent = true })
map("n", "<Leader>zl", function()
    require("zen-mode").toggle({
        window = {
            width = 1,
            height = 1,
            options = {
                number = true,
                relativenumber = false
            },
        },
    })
end, { noremap = true, silent = true })

-- Lsp

map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "gD", vim.lsp.buf.type_definition, opts)
        map("n", "K", vim.lsp.buf.hover, opts)
        map("n", "<space>rn", vim.lsp.buf.rename, opts)
        map({ "n", "v" }, "<space>.", vim.lsp.buf.code_action, opts)
        map("n", "gr", vim.lsp.buf.references, opts)
        map("n", "<leader>f", vim.lsp.buf.format, opts)
    end,
})

require 'mason'.setup()
require 'mason-lspconfig'.setup {
    ensure_installed = { "gopls", "pyright", "ts_ls", "lua_ls", "jsonls" },
}


local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("lspconfig").gopls.setup({
    analytics = false,
    capabilities = capabilities,
    flags = { debounce_text_changes = 200 },
    settings = {
        gopls = {
            usePlaceholders = true,
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            experimentalPostfixCompletions = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-node_modules", "-vendor" },
            semanticTokens = true,
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
})

local runtime_path = vim.split(package.path, ';')

table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require 'lspconfig'.lua_ls.setup {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    vim.fn.expand('$VIMRUNTIME/lua'),
                    vim.fn.stdpath('config') .. '/lua'
                }
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- Python
require 'lspconfig'.pyright.setup {
    capabilities = capabilities,
}

-- TypeScript/JavaScript
require 'lspconfig'.ts_ls.setup {
    capabilities = capabilities,
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
}

-- JSON
require 'lspconfig'.jsonls.setup {
    capabilities = capabilities,
}


local cmp = require 'cmp'
local luasnip = require 'luasnip'
local SymbolKind = vim.lsp.protocol.SymbolKind
cmp.setup({
    window = {
        completion = cmp.config.window.bordered(),    -- Adds borders to the completion menu
        documentation = cmp.config.window.bordered(), -- Adds borders to the documentation window
    },
    completion = {
        completeopt = "menu,menuone,noinsert,noselect",
    },
    experimental = {
        ghost_text = true,
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
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
    sources = {
        { name = "nvim_lsp", max_item_count = 50 },
        { name = "buffer",   max_item_count = 20 },
        { name = "path",     max_item_count = 20 },
        { name = "luasnip",  max_item_count = 20 },
        { name = "nvim_lua", max_item_count = 20 },
    },
    formatting = {
        format = function(entry, vim_item)
            -- Truncate long items but keep more characters
            vim_item.abbr = string.sub(vim_item.abbr, 1, 50)

            -- Add source indicator
            local source_names = {
                nvim_lsp = "[LSP]",
                buffer = "[Buffer]",
                path = "[Path]",
                luasnip = "[Snippet]",
                nvim_lua = "[Lua]",
            }
            vim_item.menu = source_names[entry.source.name] or ""

            return vim_item
        end,
    },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded", -- Options: 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
})

-- Customize the signature help window (optional)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded", -- Same border options
})

require 'lsp-lens'.setup({
    enable = true,
    include_declaration = false, -- Reference include declaration
    sections = {                 -- Enable / Disable specific request, formatter example looks 'Format Requests'
        definition = false,
        references = true,
        implements = true,
        git_authors = true,
    },
    ignore_filetype = {},
    -- Target Symbol Kinds to show lens information
    target_symbol_kinds = { SymbolKind.Function, SymbolKind.Method, SymbolKind.Interface },
    -- Symbol Kinds that may have target symbol kinds as children
    wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct },
})

require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "go", "python", "javascript", "typescript", "lua", "json" },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<space><space>',
        },
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
}

local dap = require("dap")
local dapgo = require("dap-go")

-- Setup dap-go (this registers the "go" DAP adapter using delve)
dapgo.setup({
    dap_configurations = {
        {
            type = "go",
            name = "Debug (Build Flags)",
            request = "launch",
            program = "${file}",
            buildFlags = dapgo.get_build_flags,
        },
    }
})

local ui = require("dapui")

dap.set_log_level("TRACE")


vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🟠", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "", linehl = "", numhl = "" })

dap.listeners.after.event_initialized["dapui_config"] = function()
    local has_dap_repl = false
    for _, buf in ipairs(vim.fn.tabpagebuflist()) do
        if vim.bo[buf].filetype == "dap-repl" then
            vim.opt_local.wrap = true
            has_dap_repl = true
            break
        end
    end

    if not has_dap_repl then
        -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>", false, true, true), "n", false)
        ui.toggle({})
    end
end

-- Other keybindings
-- Note: neotest-golang doesn't support strategy = "dap"
-- Use dap-go.debug_test() instead which debugs the test under the cursor
map("n", "<leader>td", dapgo.debug_test, { noremap = true, silent = true })
map("n", "<leader>tD", dapgo.debug_last_test, { noremap = true, silent = true })

map("n", "<leader>dc", function()
    require("zen-mode").close()
    ui.close()
    dap.disconnect({ terminateDebuggee = true })
end, { noremap = true, silent = true })
map("n", "<f3>", require("dap").toggle_breakpoint, { noremap = true, silent = true })
map("n", "<f4>", require("dap").continue, { noremap = true, silent = true })
map("n", "<f7>", require("dap").step_into, { noremap = true, silent = true })
map("n", "<f8>", require("dap").step_out, { noremap = true, silent = true })
map("n", "<f10>", require("dap").step_over, { noremap = true, silent = true })
map("v", "K", require("dapui").eval, { noremap = true, silent = true })


-- UI Settings
ui.setup({
    controls = {
        element = "repl",
        enabled = false,
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
        border = "single",
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    force_buffers = true,
    icons = {
        collapsed = "",
        current_frame = "",
        expanded = "",
    },
    layouts = {
        {
            elements = {
                { id = "breakpoints", size = 0.10 },
                { id = "stacks",      size = 0.10 },
                { id = "scopes",      size = 0.10 },
                { id = "repl",        size = 0.70 },
            },
            size = 0.30,
            position = "bottom",
        },
    },
})

-- Fuzzy finder
local builtin = require("telescope.builtin")

map("n", "<leader>z", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { noremap = true, silent = true })
map("n", "<leader>d", "<cmd>Telescope diagnostics<cr>", { noremap = true, silent = true })
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { noremap = true, silent = true })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { noremap = true, silent = true })
map("n", "<leader>ff", "<cmd>Telescope find_files hidden=true <cr>", { noremap = true, silent = true })
map("n", "<leader>c", "<cmd>Telescope resume<cr>", { noremap = true, silent = true })
map("n", "<leader>b", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
map("n", "<leader>fg", builtin.live_grep, { noremap = true, silent = true })
map("n", "<leader>oc", builtin.lsp_outgoing_calls, { noremap = true, silent = true })
map("n", "<leader>ic", builtin.lsp_incoming_calls, { noremap = true, silent = true })
map("n", "<leader>im", builtin.lsp_implementations, { noremap = true, silent = true })
map("n", "<leader>re", builtin.lsp_references, { noremap = true, silent = true })
map("n", "<leader>sy", builtin.lsp_document_symbols, { noremap = true, silent = true })
map('n', '<leader>ref', builtin.lsp_references, { noremap = true, silent = true })
map('n', '<leader>si', function()
    vim.cmd('!kill -SIGINT $(pgrep __debug)')
    vim.cmd('!kill -SIGINT $(pgrep dlv)')
    vim.cmd('!kill -SIGINT $(pgrep debug.test)')
    vim.cmd('LspRestart')
end, { noremap = true, silent = true })
map('n', '<leader>sip', ':!kill -SIGINT $(pgrep gopls) <CR>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "dap-repl" then
            vim.opt_local.wrap = true
        end
    end
})
vim.cmd [[colorscheme evangelion]]
vim.api.nvim_set_hl(0, "NeotestRunning", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestSkipped", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestWinSele", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestFile", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestDir", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestWatching", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestWinSelect", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestPassed", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "NeotestFailed", { fg = "", bg = "", bold = true })
vim.api.nvim_set_hl(0, "QuickFixLine", { fg = "", bg = "", bold = true })
