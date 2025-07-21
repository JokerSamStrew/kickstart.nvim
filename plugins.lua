local plugins = {}

function plugins.blink_cmp_rg()
  return { 'niuiic/blink-cmp-rg.nvim' }
end

function plugins.gen()
  return {
    'David-Kunz/gen.nvim',
    opts = {
      -- model = 'qwen2.5-coder:0.5b', -- The default model to use.
      model = 'codegemma:latest', -- The default model to use.

      quit_map = 'q', -- set keymap to close the response window
      retry_map = '<c-r>', -- set keymap to re-send the current prompt
      accept_map = '<c-cr>', -- set keymap to replace the previous selection with the last result
      host = 'localhost', -- The host running the Ollama service.
      port = '11434', -- The port on which the Ollama service is listening.
      display_mode = 'float', -- The display mode. Can be "float" or "split" or "horizontal-split" or "vertical-split".
      show_prompt = false, -- Shows the prompt submitted to Ollama. Can be true (3 lines) or "full".
      show_model = false, -- Displays which model you are using at the beginning of your chat session.
      no_auto_close = false, -- Never closes the window automatically.
      file = false, -- Write the payload to a temporary file to keep the command short.
      hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
      init = function(options)
        pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
      end,
      -- Function to initialize Ollama
      command = function(options)
        local body = { model = options.model, stream = true }
        return 'curl --silent --no-buffer -X POST http://' .. options.host .. ':' .. options.port .. '/api/chat -d $body'
      end,
      -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
      -- This can also be a command string.
      -- The executed command must return a JSON object with { response, context }
      -- (context property is optional).
      -- list_models = '<omitted lua function>', -- Retrieves a list of model names
      result_filetype = 'markdown', -- Configure filetype of the result buffer
      debug = false, -- Prints errors and the command which is run.
    },
  }
end

function plugins.avante()
  return {
    'yetone/avante.nvim',
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = function()
      -- conditionally use the correct build system for the current OS
      if vim.fn.has 'win32' == 1 then
        return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
      else
        return 'make'
      end
    end,
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- for example
      -- provider = 'claude',
      -- providers = {
      --   claude = {
      --     endpoint = 'https://api.anthropic.com',
      --     model = 'claude-sonnet-4-20250514',
      --     timeout = 30000, -- Timeout in milliseconds
      --     extra_request_body = {
      --       temperature = 0.75,
      --       max_tokens = 20480,
      --     },
      --   },
      -- },
      provider = 'ollama',
      providers = {
        ollama = {
          endpoint = 'http://127.0.0.1:11434',
          model = 'qwen2.5-coder:0.5b',
          timeout = 30000,
          -- disable_tools = true, -- disables all tools
          disabled_tools = {
            -- 'rag_search',
            'python',
            -- 'git_diff',
            'git_commit',
            -- 'list_files',
            -- 'search_files',
            -- 'search_keyword',
            -- 'read_file_toplevel_symbols',
            -- 'read_file',
            'create_file',
            'rename_file',
            'delete_file',
            'create_dir',
            'rename_dir',
            'delete_dir',
            'bash',
            -- 'web_search',
            -- 'fetch',
          },
          extra_request_body = {
            options = {
              temperature = 0.75,
              num_ctx = 2048,
              max_completion_tokens = 512, -- limit output tokens here
              keep_alive = '15m',
            },
          },
        },
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick', -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua', -- for file_selector provider fzf
      'stevearc/dressing.nvim', -- for input provider dressing
      'folke/snacks.nvim', -- for input provider snacks
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  }
end

function plugins.leetcode()
  return {
    'kawre/leetcode.nvim',
    build = ':TSUpdate html', -- if you have `nvim-treesitter` installed
    dependencies = {
      -- include a picker of your choice, see picker section for more details
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    lazy = 'leetcode.nvim' ~= vim.fn.argv(0, -1),
    opts = {
      arg = 'leetcode.nvim',
      lang = 'javascript',
    },
  }
end

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
          '<leader>hm',
          ':Telescope harpoon marks<CR>',
          desc = 'Harpoon Quick Menu',
        },
        {
          '<leader>hc',
          function()
            require('harpoon'):list():clear()
          end,
          desc = 'Harpoon Clear list',
        },
        {
          '<C-P>',
          function()
            require('harpoon'):list():next()
          end,
          desc = 'Harpoon Navigate Next',
        },
        {
          '<C-N>',
          function()
            require('harpoon'):list():prev()
          end,
          desc = 'Harpoon Navigate Previous',
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
