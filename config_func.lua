local config_func = {}

-- =====================================================================
-- Russian Keyboard Mapping
-- Configures langmap for Russian/English layout switching
-- =====================================================================
local function setup_langmap()
    local function escape(str)
        local escape_chars = [[;,."|\]]
        return vim.fn.escape(str, escape_chars)
    end

    local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
    local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
    local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
    local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

    vim.opt.langmap = vim.fn.join({
        -- `to` should be first, `from` should be second
        escape(ru_shift) .. ';' .. escape(en_shift),
        escape(ru) .. ';' .. escape(en),
    }, ',')
end

-- =====================================================================
-- Core Neovim Options
-- Consolidated from config_func.lua and init.lua to resolve conflicts
-- =====================================================================
function config_func.setup_options()
    setup_langmap()

    -- Python LSP configuration
    vim.g.autopep8_max_line_length = 200

    -- Line numbers (relative per-window, absolute global)
    vim.wo.relativenumber = true
    vim.wo.number = true

    -- Terminal colors (set once, no conflict)
    vim.opt.termguicolors = true

    -- Indentation settings (single source of truth via vim.opt)
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.softtabstop = 4
    vim.opt.expandtab = true

    -- Encoding
    vim.opt.encoding = 'utf-8'
    vim.opt.fileencodings = { 'utf-8' }

    -- fugitive git status pane
    vim.opt.splitbelow = true

    -- Search behavior
    vim.o.hlsearch = false
    vim.o.ignorecase = true
    vim.o.smartcase = true

    -- Mouse and clipboard
    vim.o.mouse = 'a'
    vim.schedule(function()
        vim.o.clipboard = 'unnamedplus'
    end)

    -- UI settings
    vim.o.signcolumn = 'yes'
    vim.o.breakindent = true
    vim.o.cursorline = true
    vim.o.showmode = false
    vim.o.confirm = true
    vim.o.inccommand = 'split'

    -- Scrolloff: lines kept above/below cursor (resolved: was 10 in init.lua, 20 here)
    vim.opt.scrolloff = 20

    -- Performance tuning
    vim.o.updatetime = 250
    vim.o.timeoutlen = 300

    -- Completion experience
    vim.o.completeopt = 'menuone,noselect'

    -- Whitespace visualization
    vim.o.list = true
    vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

    -- Undo history
    vim.o.undofile = true

    -- Auto-save on BufLeave for specific filetypes
    vim.api.nvim_create_augroup('AutoSave', { clear = true })
    vim.api.nvim_create_autocmd('BufLeave', {
        group = 'AutoSave',
        pattern = { '*.html', '*.py', '*.js', '*.lua', '*.sql', '*.txt' },
        callback = function()
            if not vim.bo.modifiable or vim.bo.readonly then
                return
            end
            vim.cmd('silent! write')
        end,
    })
end

-- =====================================================================
-- SQL Snippets (LuaSnip)
-- =====================================================================
function config_func.setup_custom_snippets()
    local ls = require('luasnip')
    local s = ls.snippet
    local t = ls.text_node

    -- Comment block (NOTE/TEST)
    ls.add_snippets('sql', {
        s('sndoc', t({
            '    /*',
            '        NOTE:',
            '        TEST:',
            '    */',
            '',
        })),
    })

    -- CASE WHEN/ELSE/END
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('sncase', table.concat({
            'CASE',
            '   WHEN ${1:cond} THEN ${2:result}',
            '   ELSE ${3:result}',
            'END',
        }, '\n')),
    })

    -- IF/END IF
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('snif', table.concat({
            '   IF ${1:cond} THEN',
            '',
            '   END IF;',
        }, '\n')),
    })

    -- IF/ELSE/END IF
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('snifel', table.concat({
            '   IF ${1:cond} THEN',
            '',
            '   ELSE',
            '',
            '   END IF;',
        }, '\n')),
    })

    -- FOR loop
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('snfor', table.concat({
            '   FOR ${1:record} IN {2:query}',
            '   LOOP',
            '',
            '   END LOOP;',
        }, '\n')),
    })

    -- DO $$ DECLARE/BEGIN/END $$
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('sndop', table.concat({
            'DO $$ DECLARE',
            'BEGIN',
            '',
            'END $$;',
        }, '\n')),
    })

    -- name_update_json() call template
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('snnoj', table.concat({
            "select * from name_update_json('${1:key}', '${2:set}', '${3:name}',NULL, NULL, 1, 1, 'ru');",
        }, '\n')),
    })

    -- *_json() function returning JSON object
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('snfuncjsobj', table.concat({
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
            '$$ LANGUAGE plpgsql;',
        }, '\n')),
    })

    -- *_json() function returning JSON array
    ls.add_snippets('sql', {
        ls.parser.parse_snippet('snfuncjsarr', table.concat({
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
            '$$ LANGUAGE plpgsql;',
        }, '\n')),
    })

    -- Luasnip snippet expansion keymap
    vim.keymap.set('i', '<c-p>', function()
        if ls.expand_or_jumpable() then
            ls.expand_or_jump()
        end
    end)
end

-- =====================================================================
-- Custom Commands
-- =====================================================================
function config_func.setup_custom_commands()
    vim.api.nvim_create_user_command('GenCommitMessage', function()
        vim.cmd('r! /Users/Semen/.pyenv/versions/diffsense/bin/python $SCRIPTS_PATH/generate_commit_message.py')
    end, {})
end

-- =====================================================================
-- Custom Keymaps
-- Consolidated from init.lua and plugins.lua
-- =====================================================================
function config_func.setup_keymaps()
    local telescope_builtin = require('telescope.builtin')
    local utils = require('utils')

    -- Helper functions for SQL search
    local function live_grep_sql_function()
        telescope_builtin.live_grep({})
        local regex_search_text = 'CREATE.*OR.*REPLACE.*'
        vim.api.nvim_feedkeys(regex_search_text, 't', false)
    end

    -- Save file keymap
    vim.keymap.set('n', '<Leader>fs', '<cmd>w<cr>')

    -- Open selection (macOS `open` command)
    vim.keymap.set('v', '<Leader>fx', utils.open_selection, { noremap = true })

    -- Live grep SQL function keymap
    vim.keymap.set('n', '<leader>sq', live_grep_sql_function, { desc = '[S]earch by [Q]uery function' })

    -- Display line movement (j/k -> gj/gk)
    vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })

    -- Display-aware line joining (J/K -> gJ/gK)
    vim.api.nvim_set_keymap('n', 'J', 'gJ', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'K', 'gK', { noremap = true, silent = true })
end

return config_func
