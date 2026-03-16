vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true

local has_tree_sitter_cli = vim.fn.executable("tree-sitter") == 1

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto", "rmd" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local spec = ev.data.spec or {}
    if spec.name ~= "nvim-treesitter" then
      return
    end
    if ev.data.kind == "delete" then
      return
    end
    if not has_tree_sitter_cli then
      vim.schedule(function()
        vim.notify("tree-sitter CLI is missing; skipping TSUpdate", vim.log.levels.WARN)
      end)
      return
    end

    if not ev.data.active then
      vim.cmd.packadd("nvim-treesitter")
    end
    vim.cmd("TSUpdate")
  end,
})

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = false,
  integrations = {
    mini = { enabled = true },
  },
})
vim.cmd.colorscheme("catppuccin")

require("mini.basics").setup({
  options = {
    basic = false,
    extra_ui = true,
    win_borders = "rounded",
  },
  mappings = {
    basic = true,
    option_toggle_prefix = "<leader>u",
  },
  autocommands = {
    basic = true,
    relnum_in_visual_mode = true,
  },
})
require("mini.pairs").setup()
require("starter").setup()
require("mini.surround").setup()

local treesitter_languages = {
  "bash",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "r",
  "vim",
  "vimdoc",
  "yaml",
}

require("nvim-treesitter").setup()
if not has_tree_sitter_cli then
  vim.schedule(function()
    vim.notify("Install tree-sitter CLI to enable Treesitter parser setup", vim.log.levels.WARN)
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = treesitter_languages,
  callback = function(ev)
    local ok = pcall(vim.treesitter.start, ev.buf)
    if not ok then
      return
    end

    local indent_filetypes = {
      bash = true,
      lua = true,
      python = true,
      r = true,
    }
    if indent_filetypes[vim.bo[ev.buf].filetype] then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded" },
  underline = true,
  virtual_text = { spacing = 2, source = "if_many" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      vim.bo[ev.buf].completeopt = "menu,menuone,noselect,popup,fuzzy"
      vim.keymap.set("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, { buffer = ev.buf, silent = true })
    end

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.config("r_language_server", {
  filetypes = { "r", "rmd", "quarto" },
})

vim.lsp.enable({ "lua_ls", "basedpyright", "r_language_server", "bashls" })
