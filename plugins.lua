-- =====================================================================
-- Plugin Factory Functions
-- Each function returns a lazy.nvim plugin specification table.
-- Plugins are called from init.lua via plugins.name() pattern.
-- =====================================================================

local plugins = {}

-- =====================================================================
-- Task/TODO Manager
-- =====================================================================
function plugins.dooing()
    return {
        'atiladefreitas/dooing',
        config = function()
            require('dooing').setup({
                vim.keymap.set('n', '<leader>D', ':Dooing<CR>', { desc = '[D]ooing' }),
            })
        end,
    }
end

-- =====================================================================
-- AI Autocomplete (Minuet)
-- Uses Ollama for local FIM (Fill-In-the-Middle) completion
-- =====================================================================
function plugins.minuet_ai()
    return {
        'milanglacier/minuet-ai.nvim',
        config = function()
            require('minuet').setup({
                provider = 'openai_fim_compatible',
                -- provider = 'openai_compatible',
                n_completions = 1, -- recommend for local model for resource saving
                -- I recommend beginning with a small context window size and incrementally
                -- expanding it, depending on your local computing power. A context window
                -- of 512, serves as an good starting point to estimate your computing
                -- power. Once you have a reliable estimate of your local computing power,
                -- you should adjust the context window to a larger value.
                -- context_window = 512,
                context_window = 128,
                provider_options = {
                    openai_fim_compatible = {
                        -- For Windows users, TERM may not be present in environment variables.
                        -- Consider using APPDATA instead.
                        api_key = 'TERM',
                        name = 'Ollama',
                        -- end_point = 'http://localhost:8989/v1/completions',
                        -- model = 'mistral:text',
                        end_point = 'http://localhost:11434/v1/completions',
                        model = 'qwen2.5-coder:7b',
                        optional = {
                            max_tokens = 3,
                            top_k = 3,
                            temperature = 1,
                            top_p = 0.85,
                        },
                    },
                    openai_compatible = {
                        -- For Windows users, TERM may not be present in environment variables.
                        -- Consider using APPDATA instead.
                        api_key = function()
                            return 'osaurus'
                        end,
                        name = 'Osaurus',
                        end_point = 'http://127.0.0.1:8080/v1/chat/completions',
                        model = 'deepseek-coder-v2-lite-instruct-4bit-awq',
                        optional = {
                            max_tokens = 56,
                        },
                    },
                },
            })
        end,
    }
end

-- =====================================================================
-- Terminal File Manager (fm-nvim)
-- Supports multiple backends: lf, vifm, broot, etc.
-- =====================================================================
function plugins.fm_nvim()
    return {
        'is0n/fm-nvim',
        config = function()
            require('fm-nvim').setup({
                -- (Vim) Command used to open files
                edit_cmd = 'edit',

                -- See `Q&A` for more info
                on_close = {},
                on_open = {},

                -- UI Options
                ui = {
                    -- Default UI (can be "split" or "float")
                    default = 'float',

                    float = {
                        -- Floating window border (see ':h nvim_open_win')
                        border = 'none',

                        -- Highlight group for floating window/border (see ':h winhl')
                        float_hl = 'Normal',
                        border_hl = 'FloatBorder',

                        -- Floating Window Transparency (see ':h winblend')
                        blend = 0,

                        -- Num from 0 - 1 for measurements
                        height = 0.8,
                        width = 0.8,

                        -- X and Y Axis of Window
                        x = 0.5,
                        y = 0.5,
                    },

                    split = {
                        -- Direction of split
                        direction = 'topleft',

                        -- Size of split
                        size = 24,
                    },
                },

                -- Terminal commands used w/ file manager (have to be in your $PATH)
                cmds = {
                    lf_cmd = 'lf', -- eg: lf_cmd = "lf -command 'set hidden'"
                    fm_cmd = 'fm',
                    nnn_cmd = 'nnn',
                    fff_cmd = 'fff',
                    twf_cmd = 'twf',
                    fzf_cmd = 'fzf', -- eg: fzf_cmd = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
                    fzy_cmd = 'find . | fzy',
                    xplr_cmd = 'xplr',
                    vifm_cmd = 'vifm',
                    skim_cmd = 'sk',
                    broot_cmd = 'broot',
                    gitui_cmd = 'gitui',
                    ranger_cmd = 'ranger',
                    joshuto_cmd = 'joshuto',
                    lazygit_cmd = 'lazygit',
                    neomutt_cmd = 'neomutt',
                    taskwarrior_cmd = 'taskwarrior-tui',
                },

                -- Mappings used with the plugin
                mappings = {
                    vert_split = '<C-v>',
                    horz_split = '<C-h>',
                    tabedit = '<C-t>',
                    edit = '<C-e>',
                    ESC = '<ESC>',
                },

                -- Path to broot config
                broot_conf = vim.fn.stdpath 'data' .. '/site/pack/packer/start/fm-nvim/assets/broot_conf.hjson',
            })

            vim.keymap.set('n', '<leader>V', ':Vifm<CR>', { desc = '[V]ifm' })
        end,
    }
end

-- =====================================================================
-- GitLab Integration
-- Provides GitLab MR management with custom Ex commands
-- =====================================================================
function plugins.gitlab()
    return {
        'harrisoncramer/gitlab.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'stevearc/dressing.nvim',      -- Recommended but not required. Better UI for pickers.
            'nvim-tree/nvim-web-devicons', -- Recommended but not required. Icons in discussion tree.
        },
        build = function()
            require('gitlab.server').build(true)
        end, -- Builds the Go binary
        config = function()
            require('gitlab').setup()
            vim.api.nvim_create_user_command('GitLabChooseMR', function()
                require('gitlab').choose_merge_request()
            end, { nargs = '?' })

            vim.api.nvim_create_user_command('GitLabMRPipeline', function()
                require('gitlab').pipeline()
            end, { nargs = '?' })

            vim.api.nvim_create_user_command('GitLabMergeCurrentMR', function()
                require('gitlab').merge()
            end, { nargs = '?' })

            vim.api.nvim_create_user_command('GitLabMRSummary', function()
                require('gitlab').summary()
            end, { nargs = '?' })

            vim.api.nvim_create_user_command('GitLabMainMergeRequest', function()
                require('gitlab').create_mr({ target = 'main', source = 'test_dev' })
            end, { nargs = '?' })

            vim.api.nvim_create_user_command('GitLabTestMergeRequest', function()
                require('gitlab').create_mr({ target = 'test_dev', delete_branch = true })
                require('gitlab').merge()
            end, { nargs = '?' })
        end,
    }
end

-- =====================================================================
-- Ripgrep source for blink.cmp
-- Provides file-wide word completion via ripgrep
-- =====================================================================
function plugins.blink_cmp_rg()
    return { 'niuiic/blink-cmp-rg.nvim' }
end

-- =====================================================================
-- Open Code Tool
-- =====================================================================
function plugins.opencode()
    return {
        'AuenKr/open-code.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim', -- Required for git operations
        },
        config = function()
            require("opencode").setup({
                -- Terminal window settings
                window = {
                    split_ratio = 0.3,              -- Percentage of screen for the terminal window (height or width)
                    position = "botright vertical", -- Position of the window: "botright", "topleft", "vertical"/"vsplit", "float", etc.
                    enter_insert = true,            -- Whether to enter insert mode when opening Opencode
                    start_in_normal_mode = false,   -- Whether to start in normal mode instead of insert mode
                    hide_numbers = true,            -- Hide line numbers in the terminal window
                    hide_signcolumn = true,         -- Hide the sign column in the terminal window

                    -- Floating window configuration (only applies when position = "float")
                    float = {
                        width = "80%",       -- Width: number of columns or percentage string
                        height = "80%",      -- Height: number of rows or percentage string
                        row = "center",      -- Row position: number, "center", or percentage string
                        col = "center",      -- Column position: number, "center", or percentage string
                        relative = "editor", -- Relative to: "editor" or "cursor"
                        border = "rounded",  -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
                    },
                },
                -- File refresh settings
                refresh = {
                    enable = true,             -- Enable file change detection
                    updatetime = 100,          -- updatetime when Opencode is active (milliseconds)
                    timer_interval = 1000,     -- How often to check for file changes (milliseconds)
                    show_notifications = true, -- Show notification when files are reloaded
                },
                -- Git project settings
                git = {
                    use_git_root = true, -- Set CWD to git root when opening Opencode (if in git project)
                },
                -- Command settings
                command = "opencode", -- Command used to launch Opencode (do not include --cwd)
                -- Command variants
                command_variants = {
                    -- Conversation management
                    continue = "--continue", -- Resume the most recent conversation
                    resume = "--resume",     -- Display an interactive conversation picker

                    -- Output options
                    verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
                },
                -- Keymaps
                keymaps = {
                    toggle = {
                        normal = "<leader>a", -- Normal mode keymap for toggling Opencode
                        terminal = "<C-o>",   -- Terminal mode keymap for toggling Opencode
                        variants = {
                            -- variants are disabled by default
                            -- continue = "<leader>aC", -- Normal mode keymap for Opencode with continue flag
                            -- verbose = "<leader>aV",  -- Normal mode keymap for Opencode with verbose flag
                        },
                    }
                }
            })
        end,
    }
end

-- =====================================================================
-- LeetCode Platform Integration
-- =====================================================================
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

-- =====================================================================
-- Multi-Formatter (Neoformat)
-- Configured for SQL (pg_format) and JS/CSS (prettier)
-- =====================================================================
function plugins.neoformat()
    return {
        'sbdchd/neoformat',
        config = function()
            -- vim.g.neoformat_verbose = 1
            -- vim.g.neoformat_verbose = 0
            vim.keymap.set('n', '<leader>nf', ':Neoformat<CR>', { desc = '[N]eo[f]ormat' })
            vim.g.neoformat_sql_pg_format = {
                exe = 'pg_format',
                args = {
                    '--keep-newline',
                    '--keyword-case 0',
                    '--type-case 0',
                    '--comma-end',
                    '--comma-break',
                    '--no-space-function',
                    '--format-type',
                },
                stdin = 1,
                valid_exit_codes = { 0, 1 },
            }

            vim.g.neoformat_enabled_sql = { 'pg_format' }

            vim.g.neoformat_javascript_prettier = {
                exe = 'prettier',
                args = {
                    '--print-width',
                    '80',
                    '--single-quote',
                    '--trailing-comma',
                    'es5',
                    '--tab-width',
                    '4',
                    '--no-bracket-spacing',
                    '--single-attribute-per-line',
                    '--parser',
                    'babel',
                },
                valid_exit_codes = { 0, 1 },
            }

            vim.g.neoformat_css_prettier = {
                exe = 'prettier',
                args = {
                    '--parser',
                    'css',
                    '--print-width',
                    '120',
                    '--single-quote',
                    '--tab-width',
                    '4',
                    '--stdin-filepath',
                    '%:p',
                },
                valid_exit_codes = { 0, 1 },
            }

            vim.g.neoformat_enabled_javascript = { 'prettier' }
            vim.g.neoformat_enabled_css = { 'prettier' }
        end,
    }
end

-- =====================================================================
-- Git Fugitive Integration
-- =====================================================================
function plugins.vim_fugitive()
    -- Git related plugins
    return {
        'tpope/vim-fugitive',
        config = function()
            vim.keymap.set('n', '<leader>G', ':Git<CR>', { desc = '[G]it' })
        end,
    }
end

-- =====================================================================
-- Text Surround Plugin
-- Adds/adds/deletes/replaces brackets, quotes, etc.
-- =====================================================================
function plugins.nvim_surround()
    return {
        'kylechui/nvim-surround',
        version = '*', -- Use for stability; omit to use `main` branch for the latest features
        event = 'VeryLazy',
        config = function()
            require('nvim-surround').setup({
                -- Configuration here, or leave empty to use defaults
                ['('] = { add = { '(', ')' } },
                [')'] = { add = { '(', ')' } },
                ['{'] = { add = { '{', '}' } },
                ['}'] = { add = { '{', '}' } },
                ['['] = { add = { '[', ']' } },
                [']'] = { add = { '[', ']' } },
            })
        end,
    }
end

-- =====================================================================
-- Database UI (Dadbod-UI)
-- Provides database management with SQL execution
-- =====================================================================
function plugins.vim_dadbod_ui()
    return {
        'kristijanhusak/vim-dadbod-ui',
        dependencies = {
            { 'tpope/vim-dadbod',                     lazy = true },
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
            local utils = require('utils')
            vim.keymap.set('n', '<leader>ese', function()
                vim.cmd('norm 0')
                utils.select_up_down_patterns(nil, ';')
                vim.schedule(function()
                    vim.cmd("'<,'>DB")
                    vim.cmd('norm 0')
                end)
            end, { noremap = true, silent = true, desc = '[E]xecute [s]ql [e]xpression' })
            vim.keymap.set('n', '<leader>efq', function()
                utils.select_up_down_patterns('CREATE OR REPLACE', 'plpgsql;')
                vim.schedule(function()
                    vim.cmd("'<,'>DB")
                    vim.cmd('norm [{')
                end)
            end, { noremap = true, silent = true, desc = '[E]xecute sql [f]untion [q]uery' })
            vim.keymap.set('n', '<leader>fq', function()
                utils.select_up_down_patterns('CREATE OR REPLACE', 'plpgsql;')
                -- vim.cmd('\'<,\'>DB')
                -- vim.cmd('norm [{')
            end, { noremap = true, silent = true, desc = 'Select sql [f]untion [q]uery' })
            vim.keymap.set('n', '<leader>se', function()
                vim.cmd('norm 0')
                utils.select_up_down_patterns(nil, ';')
                -- vim.cmd('\'<,\'>DB')
            end, { noremap = true, silent = true, desc = 'Select [s]ql [e]xpression' })
        end,
    }
end

-- =====================================================================
-- Python Virtual Environment Selector
-- =====================================================================
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

-- =====================================================================
-- Harpoon - File Marking
-- Quick navigation to frequently used files
-- =====================================================================
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

-- =====================================================================
-- Treesitter Context
-- Shows code context above cursor
-- =====================================================================
function plugins.nvim_treesitter_context()
    return {
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
            require('treesitter-context').setup({
                enable = true,            -- Enable the context
                max_lines = 0,            -- How many lines the window can be
                min_window_height = 0,    -- Minimum height of the window
                line_numbers = true,      -- Show line numbers
                multiline_threshold = 20, -- Threshold for multiline context
            })
        end,
    }
end

-- =====================================================================
-- Language Mapper
-- High priority plugin for language-specific remapping
-- =====================================================================
function plugins.langmapper()
    return {
        'Wansmer/langmapper.nvim',
        lazy = false,
        priority = 1, -- High priority is needed if you will use `autoremap()`
        config = function()
            require('langmapper').setup({ --[[ your config ]]
            })
        end,
    }
end

-- =====================================================================
-- Emmet Expansion for HTML/CSS
-- =====================================================================
function plugins.nvim_emmet()
    return {
        'olrtg/nvim-emmet',
        config = function()
            vim.keymap.set({ 'n', 'v' }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
        end,
    }
end

return plugins
