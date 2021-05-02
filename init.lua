o = vim.o
bo = vim.bo
wo = vim.wo

o.termguicolors = true
o.syntax = "on"
o.errorbells = false
o.smartcase = true
o.showmode = false
o.undodir = vim.fn.stdpath("config") .. "/undodir"
o.undofile = true
o.incsearch = true
o.hidden = true
o.completeopt = "menuone,noinsert,noselect"
bo.autoindent = true
bo.smartindent = true

bo.tabstop = 2
bo.softtabstop = 2
bo.shiftwidth = 2
bo.expandtab = true
wo.signcolumn = "yes"
wo.number = true
wo.relativenumber = true

vim.g.mapleader = " "

local key_mapper = function(mode, key, result)
  vim.api.nvim_set_keymap(mode, key, result, {noremap = true, silent = true})
end

-- disable arrows
key_mapper("", "<up>", "<nop>")
key_mapper("", "<down>", "<nop>")
key_mapper("", "<left>", "<nop>")
key_mapper("", "<right>", "<nop>")

local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn

-- ensure that packer is installed
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
  execute "packadd packer.nvim"
end
vim.cmd("packadd packer.nvim")
local packer = require "packer"
local util = require "packer.util"
packer.init(
  {
    package_root = util.join_paths(vim.fn.stdpath("data"), "site", "pack")
  }
)

--- startup and add configure plugins
packer.startup(
  function()
    local use = use
    -- add you plugins here like:
    -- use 'neovim/nvim-lspconfig'
    use "nvim-treesitter/nvim-treesitter"
    use "sheerun/vim-polyglot"
    use "neovim/nvim-lspconfig"
    use "nvim-lua/completion-nvim"
    use "anott03/nvim-lspinstall"
    use "nvim-lua/popup.nvim"
    use "nvim-lua/plenary.nvim"
    use "nvim-lua/telescope.nvim"
    use "tjdevries/colorbuddy.nvim"
    use "maaslalani/nordbuddy"
    use "rmagatti/auto-session"
    use "andweeb/presence.nvim"
    use "kkoomen/vim-doge"
    use "npxbr/glow.nvim"
    use "norcalli/snippets.nvim"
    use "jiangmiao/auto-pairs"
    use "machakann/vim-sandwich"
    use "ms-jpq/chadtree"
    use {
      "numtostr/FTerm.nvim",
      config = function()
        require("FTerm").setup()
      end
    }
    use "mhartington/formatter.nvim"
    use "bluz71/vim-nightfly-guicolors"
    use "a-vrma/black-nvim"
    use {
      "lewis6991/spellsitter.nvim",
      config = function()
        require("spellsitter").setup()
      end
    }
  end
)

-- configure treesitter
local configs = require "nvim-treesitter.configs"

configs.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true
  }
}

-- configure theme
vim.g.colors_name = "nightfly"

-- configure lsp
local lspconfig = require "lspconfig"
local completion = require "completion"

local nvim_lsp = require("lspconfig")
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  local opts = {noremap = true, silent = true}
  buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
      false
    )
  end

  -- activate autocompletion
  completion.on_attach()
end

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = {"pyright", "rust_analyzer", "tsserver"}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {on_attach = on_attach}
end

-- setup fuzzy finding
key_mapper("n", "<C-p>", ':lua require"telescope.builtin".find_files()<CR>')
key_mapper("n", "<leader>fs", ':lua require"telescope.builtin".live_grep()<CR>')
key_mapper("n", "<leader>fh", ':lua require"telescope.builtin".help_tags()<CR>')
key_mapper("n", "<leader>fb", ':lua require"telescope.builtin".buffers()<CR>')

-- setup completion
vim.api.nvim_command(
  [[
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
]]
)
completion_enable_smippet = "snippets.nvim"

-- FTerm setup stuff
require "FTerm".setup(
  {
    dimensions = {
      height = 0.8,
      width = 0.8,
      x = 0.5,
      y = 0.5
    },
    border = "single" -- or 'double'
  }
)
-- -- Keybinding
local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

-- Closer to the metal
map("n", "<A-i>", '<CMD>lua require("FTerm").toggle()<CR>', opts)
map("t", "<A-i>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', opts)

-- Setup formatter
require("formatter").setup(
  {
    logging = false,
    filetype = {
      javascript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote"},
            stdin = true
          }
        end
      },
      rust = {
        -- Rustfmt
        function()
          return {
            exe = "rustfmt",
            args = {"--emit=stdout"},
            stdin = true
          }
        end
      },
      lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
      },
      python = {
        -- black
        function()
          return {
            exe = "black",
            args = {"-"},
            stdin = true
          }
        end
      }
    }
  }
)

map("n", "<leader>f", "<cmd>Format<CR>", {noremap = true})
