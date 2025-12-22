local config_func = {}

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

function config_func.setup_options()
    setup_langmap()

    vim.g.autopep8_max_line_length = 200
    vim.wo.relativenumber = true
    vim.opt.termguicolors = false
    vim.opt.softtabstop = 4
    vim.opt.scrolloff = 20
    vim.opt.tabstop = 4      -- Number of spaces a tab represents
    vim.g.tabstop = 4        -- Number of spaces a tab represents
    vim.opt.shiftwidth = 4   -- Number of spaces for each indentation level
    vim.g.shiftwidth = 4     -- Number of spaces a tab represents
    vim.opt.expandtab = true -- Convert tabs to spaces
    vim.g.expandtab = true   -- Number of spaces a tab represents
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

    vim.api.nvim_create_augroup('AutoSave', { clear = true })
    vim.api.nvim_create_autocmd('BufLeave', {
        group = 'AutoSave',
        pattern = { '*.html', '*.py', '*.js', '*.lua', '*.sql', '*.txt' },
        command = 'silent! write',
    })
end

function config_func.setup_custom_snippets()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node

    ls.add_snippets('sql', { s('sndoc', t({
        '    /*',
        '        NOTE:',
        '        TEST:',
        '    */',
        ''
    }))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('sncase', table.concat({
        'CASE',
        '   WHEN ${1:cond} THEN ${2:result}',
        '   ELSE ${3:result}',
        'END',
    }, '\n'))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('snif', table.concat({
        '   IF ${1:cond} THEN',
        '',
        '   END IF;',
    }, '\n'))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('snifel', table.concat({
        '   IF ${1:cond} THEN',
        '',
        '   ELSE',
        '',
        '   END IF;',
    }, '\n'))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('snfor', table.concat({
        '   FOR ${1:record} IN {2:query}',
        '   LOOP',
        '',
        '   END LOOP;',
    }, '\n'))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('sndop', table.concat({
        'DO $$ DECLARE',
        'BEGIN',
        '',
        'END $$;'
    }, '\n'))
    })

    ls.add_snippets('sql', { ls.parser.parse_snippet('snnoj', table.concat({
        'select * from name_update_json(\'${1:key}\', \'${2:set}\', \'${3:name}\',NULL, NULL, 1, 1, \'ru\');',
    }, '\n'))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('snfuncjsobj', table.concat({
        'CREATE OR REPLACE FUNCTION ${1:name}_json(',
        ') RETURNS JSON AS $$',
        'DECLARE',
        '    json_res JSON = NULL;',
        'BEGIN',
        '    /*',
        '        NOTE:',
        '        TEST:',
        '    */',
        '',
        '    SELECT json_build_object(',
        '    )',
        '    INTO',
        '        json_res',
        '    FROM',
        '        ${1:name}() ${2:short_name};',
        '',
        '    RETURN COALESCE(json_res, \'{}\'::json);',
        'END;',
        '$$ LANGUAGE plpgsql;'
    }, '\n'))
    })
    ls.add_snippets('sql', { ls.parser.parse_snippet('snfuncjsarr', table.concat({
        'CREATE OR REPLACE FUNCTION ${1:name}_json(',
        ') RETURNS JSON AS $$',
        'DECLARE',
        '    json_res JSON = NULL;',
        'BEGIN',
        '    /*',
        '        NOTE:',
        '        TEST:',
        '    */',
        '',
        '    SELECT json_agg(json_build_object(',
        '    ))',
        '    INTO',
        '        json_res',
        '    FROM',
        '        ${1:name}() ${2:short_name};',
        '',
        '    RETURN COALESCE(json_res, \'[]\'::json);',
        'END;',
        '$$ LANGUAGE plpgsql;'
    }, '\n'))
    })

    vim.keymap.set("i", "<c-p>", function()
        if ls.expand_or_jumpable() then
            ls.expand_or_jump()
        end
    end)
end

function config_func.setup_custom_commands()
    vim.api.nvim_create_user_command('GenCommitMessage', function()
        vim.cmd 'r! /Users/Semen/.pyenv/versions/diffsense/bin/python $SCRIPTS_PATH/generate_commit_message.py'
    end, {})
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
    -- vim.keymap.set({ 'n' }, '<Leader>ff', '<cmd>Format<cr>')
    vim.keymap.set({ 'n' }, '<Leader>fs', '<cmd>w<cr>')

    local utils = require 'utils'
    -- Set up key mapping in visual mode (e.g., <leader>e)
    vim.keymap.set('v', '<Leader>fx', utils.open_selection, { noremap = true })
    vim.keymap.set('n', '<leader>sq', live_grep_sql_function, { desc = '[S]earch by [Q]uery function' })

    -- Remap j to gj and k to gk for moving by display lines
    vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })

    -- Optionally, you can also remap other movement keys
    vim.api.nvim_set_keymap('n', 'J', 'gJ', { noremap = true, silent = true }) -- for visual mode
    vim.api.nvim_set_keymap('n', 'K', 'gK', { noremap = true, silent = true }) -- for visual mode
end

return config_func
