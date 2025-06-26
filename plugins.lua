local plugins = {}

function plugins.neoformat()
  return 'sbdchd/neoformat'
end

function plugins.vim_fugitive()
  -- Git related plugins
  return 'tpope/vim-fugitive'
end

function plugins.nvim_web_devicons()
  return 'nvim-tree/nvim-web-devicons'
end

function plugins.nvim_surround()
  return {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  }
end

function plugins.vim_dadbod_ui()
  return {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql', 'psql' }, lazy = true }, -- Optional
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
      'DBUIOpen',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_execute_on_save = 0
      vim.api.nvim_set_keymap('v', '<Leader>q', ':DB<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<C-s><C-q>', ':DBUIFindBuffer<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<C-s><C-d>', ':DBUIToggle<CR>', { noremap = true })
    end,
  }
end

function plugins.venv_selector()
  return {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python', --optional
      { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
    },
    lazy = false,
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    keys = {
      { '<leader>vs', '<cmd>VenvSelect<cr>' },
    },
  }
end

function plugins.telescope()
  -- Fuzzy Finder (files, lsp, etc)
  return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  }
end

function plugins.harpoon()
  return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local keys = {
        {
          '<leader>H',
          function()
            require('harpoon'):list():add()
          end,
          desc = 'Harpoon File',
        },
        {
          '<leader>h',
          -- function()
          --     local harpoon = require("harpoon")
          --     harpoon.ui:toggle_quick_menu(harpoon:list())
          -- end,
          ':Telescope harpoon marks<CR>',
          desc = 'Harpoon Quick Menu',
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          '<leader>' .. i,
          function()
            require('harpoon'):list():select(i)
          end,
          desc = 'Harpoon to File ' .. i,
        })
      end
      return keys
    end,
  }
end

function plugins.nvim_treesitter_context()
  return {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        enable = true, -- Enable the context
        max_lines = 0, -- How many lines the window can be
        min_window_height = 0, -- Minimum height of the window
        line_numbers = true, -- Show line numbers
        multiline_threshold = 20, -- Threshold for multiline context
      }
    end,
  }
end

function plugins.langmapper()
  return {
    'Wansmer/langmapper.nvim',
    lazy = false,
    priority = 1, -- High priority is needed if you will use `autoremap()`
    config = function()
      require('langmapper').setup { --[[ your config ]]
      }
    end,
  }
end

function plugins.nvim_emmet()
  return {
    'olrtg/nvim-emmet',
    config = function()
      vim.keymap.set({ 'n', 'v' }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
    end,
  }
end

return plugins
