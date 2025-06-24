local config_func = {}

function config_func.setup_globals()
  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
  vim.g.autopep8_max_line_length = 200
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  -- vim.g.python3_host_prog = '/Users/Semen/.pyenv/versions/3.12.2/envs/neovim/bin/python3'
end

local function setup_langmap()
  local function escape(str)
    -- You need to escape these characters to work correctly
    local escape_chars = [[;,."|\]]
    return vim.fn.escape(str, escape_chars)
  end

  -- Recommended to use lua template string
  local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
  local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
  local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
  local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

  vim.opt.langmap = vim.fn.join({
    -- | `to` should be first     | `from` should be second
    escape(ru_shift)
      .. ';'
      .. escape(en_shift),
    escape(ru) .. ';' .. escape(en),
  }, ',')
end

local function setup_highlight_on_yank()
  -- [[ Highlight on yank ]]
  -- See `:help vim.highlight.on_yank()`
  local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
  })
end

function config_func.setup_options()
  setup_langmap()
  setup_highlight_on_yank()

  vim.wo.relativenumber = true
  vim.opt.termguicolors = false
  vim.opt.softtabstop = 4
  vim.opt.scrolloff = 20
  vim.opt.tabstop = 4 -- Number of spaces a tab represents
  vim.g.tabstop = 4 -- Number of spaces a tab represents
  vim.opt.shiftwidth = 4 -- Number of spaces for each indentation level
  vim.g.shiftwidth = 4 -- Number of spaces a tab represents
  vim.opt.expandtab = true -- Convert tabs to spaces
  vim.g.expandtab = true -- Number of spaces a tab represents
  vim.opt.encoding = 'utf-8'
  vim.opt.fileencodings = { 'utf-8' }

  -- [[ Setting options ]]
  -- See `:help vim.o`
  -- NOTE: You can change these options as you wish!

  -- Set highlight on search
  vim.o.hlsearch = false

  -- Make line numbers default
  vim.wo.number = true

  -- Enable mouse mode
  vim.o.mouse = 'a'

  -- Sync clipboard between OS and Neovim.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.o.clipboard = 'unnamedplus'

  -- Enable break indent
  vim.o.breakindent = true

  -- Save undo history
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or capital in search
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.wo.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300

  -- Set completeopt to have a better completion experience
  vim.o.completeopt = 'menuone,noselect'

  -- NOTE: You should make sure your terminal supports this
  vim.o.termguicolors = true
end

function config_func.package_manager()
  return require 'lazy'
end

function config_func.install_package_manager()
  -- Install package manager
  --    https://github.com/folke/lazy.nvim
  --    `:help lazy.nvim.txt` for more info
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
    }
  end
  vim.opt.rtp:prepend(lazypath)
end

function config_func.setup_keymaps()
  local telescope_builtin = require 'telescope.builtin'
  local function cb_fuzzy_find()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    telescope_builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end

  local function live_grep_sql_function()
    telescope_builtin.live_grep {}
    local regex_search_text = 'CREATE.*OR.*REPLACE.*'
    vim.api.nvim_feedkeys(regex_search_text, 't', false)
  end

  -- The line beneath this is called `modeline`. See `:help modeline`
  -- vim: ts=2 sts=2 sw=2 et
  vim.keymap.set({ 'n' }, '<Leader>ff', '<cmd>Format<cr>')
  vim.keymap.set({ 'n' }, '<Leader>fs', '<cmd>w<cr>')

  local utils = require 'utils'
  -- Set up key mapping in visual mode (e.g., <leader>e)
  vim.keymap.set('v', '<Leader>fx', utils.open_selection, { noremap = true })
  vim.keymap.set('n', '<leader>sq', live_grep_sql_function, { desc = '[S]earch by [Q]uery function' })
end

return config_func
