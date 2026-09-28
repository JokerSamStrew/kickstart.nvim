# Neovim Configuration - AGENTS.md

## Overview

This is a modular Neovim configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), extended with custom plugins, AI assistants, and language-specific tooling. The config targets Neovim stable and nightly versions.

## Architecture

### File Structure

```
nvim/
├── init.lua              # Main entry: options, keymaps, plugin setup
├── plugins.lua           # Plugin factory functions (one per plugin)
├── config_func.lua       # Custom options, snippets, commands, keymaps
├── utils.lua             # Helper functions (selection, pattern matching)
├── lua/
│   ├── kickstart/plugins/ # Default kickstart plugins (debug, autoformat)
│   └── custom/plugins/    # User plugins directory (return {} by default)
├── .stylua.toml          # Lua formatting rules
└── lazy-lock.json        # Plugin lockfile
```

### Configuration Flow

1. `init.lua` sets global options and leader key
2. `config_func.lua` is required, calling `setup_options()` for base settings
3. `lazy.nvim` loads all plugins from `init.lua`
4. After plugin setup, `config_func.lua` runs `setup_custom_snippets()`, `setup_custom_commands()`, and `setup_keymaps()`

### Key Design Principles

- **Modular plugins**: Each plugin in `plugins.lua` is a factory function returning a lazy.nvim spec
- **Single source of truth**: Plugins are called from `init.lua` via `plugins.name()` pattern
- **Separation of concerns**: Options (`config_func.lua`), plugins (`plugins.lua`), utilities (`utils.lua`)
- **No merge conflicts**: `lua/custom/plugins/` directory available for user plugins (currently empty)

## Core Options (from config_func.lua and init.lua)

| Option | Value | Purpose |
|--------|-------|---------|
| `mapleader` | `' '` | Space as leader key |
| `number` | `true` | Line numbers enabled |
| `relativenumber` | `true` | Relative line numbers |
| `mouse` | `'a'` | Mouse support in all modes |
| `clipboard` | `'unnamedplus'` | OS clipboard integration |
| `undofile` | `true` | Persistent undo history |
| `ignorecase` / `smartcase` | `true` | Case-insensitive search (case-sensitive if uppercase) |
| `scrolloff` | `20` | Lines kept above/below cursor |
| `scrolloff` (init.lua) | `10` | Conflicts with config_func.lua (value: 20) |
| `updatetime` | `250` | Cursor hold delay (ms) |
| `timeoutlen` | `300` | Key sequence timeout (ms) |
| `tabstop` / `shiftwidth` / `softtabstop` | `4` | Indentation width |
| `expandtab` | `true` | Use spaces instead of tabs |
| `hlsearch` | `false` | No highlight on search |
| `termguicolors` | `false` (set) / `true` (overridden) | Terminal colors (conflict between files) |
| `listchars` | `tab='» ', trail='·', nbsp='␣'` | Visible whitespace |

## Plugins

### Completion & AI

| Plugin | Purpose | Key Notes |
|--------|---------|-----------|
| `saghen/blink.cmp` | Autocompletion | Uses blink.cmp with Luasnip snippets, lazydev, ripgrep sources |
| `L3MON4D3/LuaSnip` | Snippet engine | Version 2.x, friendly-snippets loaded |
| `milanglacier/minuet-ai.nvim` | AI autocomplete | Ollama `qwen2.5-coder:7b`, context_window=128 |
| `yetone/avante.nvim` | AI assistant | Ollama `qwen2.5-coder:0.5b`, tools disabled (file/bash operations) |
| `David-Kunz/gen.nvim` | AI code generation | Ollama `deepseek-r1:latest`, vertical-split mode |

### Navigation & Search

| Plugin | Purpose | Keymaps |
|--------|---------|---------|
| `nvim-telescope/telescope.nvim` | Fuzzy finder | `<leader>sh` help, `<leader>sk` keymaps, `<leader>sf` files, `<leader>ss` builtin, `<leader>sw` word, `<leader>sg` grep, `<leader>sd` diagnostics, `<leader>sr` resume, `<leader>s.` recent, `<leader><leader>` buffers, `<leader>/` current buffer, `<leader>sn` neovim config |
| `ThePrimeagen/harpoon` | File marking | `<leader>H` add, `<leader>hm` menu, `<leader>hc` clear, `<C-P/N>` next/prev, `<leader>1-5` select |
| `nvim-treesitter/nvim-treesitter-context` | Code context | Enabled, max_lines=0 |

### Editing

| Plugin | Purpose | Keymaps |
|--------|---------|---------|
| `stevearc/conform.nvim` | Formatting | `<leader>ff` format buffer, auto-format on save (excludes c, cpp, js, html) |
| `kylechui/nvim-surround` | Surround text | No default keymap, configured for parens/braces/brackets |
| `echasnovski/mini.nvim` | Utilities | `mini.ai`, `mini.surround`, `mini.statusline` with location |
| `folke/which-key.nvim` | Keybinding display | Delay=0, Nerd Font icons |
| `olrtg/nvim-emmet` | Emmet expansion | `<leader>xe` wrap with abbreviation |

### Language Servers & Tooling

| Plugin | Purpose | Configured Servers |
|--------|---------|-------------------|
| `neovim/nvim-lspconfig` | LSP framework | `lua_ls`, `pylsp`, `html`, `emmet_language_server` |
| `mason-org/mason.nvim` | Tool/package manager | Auto-installs formatters |
| `j-hui/fidget.nvim` | LSP status notifications | - |
| `kawre/leetcode.nvim` | LeetCode platform | JavaScript, lazy-loaded |
| `sbdchd/neoformat` | Multi-formatter | `pg_format` (SQL), `prettier` (JS/CSS) |

### Git & Version Control

| Plugin | Purpose | Keymaps |
|--------|---------|---------|
| `lewis6991/gitsigns.nvim` | Git signs | Custom signs: +, ~, _, ~ |
| `tpope/vim-fugitive` | Git commands | `<leader>G` |
| `harrisoncramer/gitlab.nvim` | GitLab MR management | Custom commands: `GitLabChooseMR`, `GitLabMRPipeline`, `GitLabMergeCurrentMR`, `GitLabMRSummary`, `GitLabMainMergeRequest`, `GitLabTestMergeRequest` |

### Database

| Plugin | Purpose | Keymaps |
|--------|---------|---------|
| `kristijanhusak/vim-dadbod-ui` | Database UI | `<Leader>q` (visual), `<C-s><C-q>` find buffer, `<C-s><C-d>` toggle, `<leader>ese` execute SQL, `<leader>efq` execute function, `<leader>se` select SQL |

### File Management & AI Tools

| Plugin | Purpose | Keymaps |
|--------|---------|---------|
| `is0n/fm-nvim` | File manager | `<leader>V` ifm |
| `atiladefreitas/dooing` | Task/todo manager | `<leader>D` |
| `linux-cultist/venv-selector.nvim` | Python venv selection | `<leader>vs` |
| `Wansmer/langmapper.nvim` | Language mapper | High priority (1), autoremap |
| `AuenKr/open-code.nvim` | Open code tool | No default keymap |
| `niuiic/blink-cmp-rg.nvim` | Ripgrep for blink.cmp | Integrated into completion |

## Custom Keymaps

### Leader Keymaps (`<space>`)

| Keymap | Action | Description |
|--------|--------|-------------|
| `<space>q` | `vim.diagnostic.setloclist` | Open diagnostic quickfix |
| `<space>s` `[S]earch` | Telescope groups | See Telescope section |
| `<space>t` `[T]oggle` | Which-key group | - |
| `<space>h` | Git [H]unk | Which-key group |
| `<space>D` | `:Dooing` | Task manager |
| `<space>V` | `:Vifm` | File manager (ifm) |
| `<space>G` | `:Git` | Fugitive git |
| `<space>g` | `:Gen` | AI generation |
| `<space>nf` | `:Neoformat` | Format buffer |
| `<space>xe` | `nvim-emmet.wrap` | Emmet wrap |
| `<space>vs` | `:VenvSelect` | Python venv selector |
| `<space>fs` | `:w` | Save file |
| `<space>sq` | Live grep SQL function | Search `CREATE.*OR.*REPLACE.*` |
| `<space>ese` | Execute SQL expression | Select and execute |
| `<space>efq` | Execute SQL function query | Select and execute |
| `<space>fq` | Select SQL function query | Select only |
| `<space>se` | Select SQL expression | Select only |
| `<space>ff` | Conform format | Format buffer |

### Special Keymaps

| Keymap | Mode | Action |
|--------|------|--------|
| `<Esc>` | n | Clear search highlights |
| `<Esc><Esc>` | t | Exit terminal mode |
| `<C-h/l/j/k>` | n | Window navigation |
| `j/k` | n | `gj/gk` (display line movement) |
| `J/K` | n | `gJ/gK` (join lines display-aware) |
| `<Leader>fx` | v | Open selection (macOS `open` command) |

## SQL Snippets (LuaSnip)

| Trigger | Description |
|---------|-------------|
| `sndoc` | Comment block (NOTE/TEST) |
| `sncase` | CASE WHEN/ELSE/END |
| `snif` | IF/END IF |
| `snifel` | IF/ELSE/END IF |
| `snfor` | FOR loop |
| `sndop` | DO $$ DECLARE/BEGIN/END $$ |
| `snnoj` | `name_update_json()` call template |
| `snfuncjsobj` | `*_json()` function returning JSON object |
| `snfuncjsarr` | `*_json()` function returning JSON array |

## Auto-Save

Auto-saves buffers on `BufLeave` for filetypes: `html`, `py`, `js`, `lua`, `sql`, `txt`. Skips readonly/modifiable buffers.

## AI Configuration

### Minuet (Autocomplete)
- Provider: `openai_fim_compatible` (Ollama)
- Model: `qwen2.5-coder:7b`
- Endpoint: `http://localhost:11434/v1/completions`
- Context window: 128 (adjust based on compute)

### Avante (AI Assistant)
- Provider: `ollama`
- Model: `qwen2.5-coder:0.5b`
- Endpoint: `http://127.0.0.1:11434`
- Disabled tools: python, git_diff, git_commit, file operations, bash
- Max completion tokens: 512

### Gen (Code Generation)
- Model: `deepseek-r1:latest`
- Display: vertical-split
- Keymap: `<leader>g`

## LSP Servers

| Server | Filetypes | Notes |
|--------|-----------|-------|
| `lua_ls` | `.lua` | Completion snippet: Replace |
| `pylsp` | `.py` | pylint, pyflakes, autopep8 (max 200 chars) |
| `html` | `html`, `xhtml`, `htmldjango` | Validation with 16 tag types |
| `emmet_language_server` | css, html, js, ts, scss, etc. | Emmet expansion |

## Custom Commands

| Command | Description |
|---------|-------------|
| `GenCommitMessage` | Runs Python script to generate commit message from `$SCRIPTS_PATH/generate_commit_message.py` |

## GitLab Commands

Custom Ex commands created via `nvim_create_user_command`:
- `GitLabChooseMR` - Choose merge request
- `GitLabMRPipeline` - View pipeline
- `GitLabMergeCurrentMR` - Merge current MR
- `GitLabMRSummary` - MR summary
- `GitLabMainMergeRequest` - Create MR (main ← test_dev)
- `GitLabTestMergeRequest` - Create MR (test_dev, auto-delete branch)

## Russian Keyboard Mapping

`langmap` configured for Russian/English layout switching:
- Unshifted: Russian → English
- Shifted: Russian → English (shifted)

## Formatting

| Language | Formatter | Config |
|----------|-----------|--------|
| Lua | `stylua` | Via conform.nvim |
| SQL | `pg_format` | `--keep-newline --keyword-case 0 --type-case 0 --comma-end --comma-break --no-space-function --format-type` |
| JavaScript | `prettier` | `--print-width 80 --single-quote --trailing-comma es5 --tab-width 4 --no-bracket-spacing --single-attribute-per-line --parser babel` |
| CSS | `prettier` | `--parser css --print-width 120 --single-quote --tab-width 4` |

## StyLua Configuration (`.stylua.toml`)

```toml
column_width = 160
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferSingle"
call_parentheses = "None"
```

## Known Issues / Conflicts

1. **`scrolloff`** is set to `10` in `init.lua` and `20` in `config_func.lua` (config_func wins as it runs after)
2. **`termguicolors`** is set to `false` in `config_func.lua` then overridden to `true` later in `init.lua`
3. **`tabstop`/`shiftwidth`/`expandtab`** are redundantly set via both `vim.opt` and `vim.g`
4. **Telescope** is configured in `init.lua` and has a duplicate definition in `plugins.lua` (`plugins.telescope()`)
5. **`nvim-web-devicons`** is referenced as dependency in multiple places and also has a standalone plugin function

## Recommended Refactoring

1. Consolidate conflicting options (`scrolloff`, `termguicolors`) into `config_func.lua` only
2. Remove redundant `plugins.telescope()` function (already configured in `init.lua`)
3. Remove redundant `nvim-web-devicons` plugin function (already a dependency)
4. Deduplicate `tabstop`/`shiftwidth`/`expandtab` (use only `vim.opt`)
5. Move LSP server configurations from `init.lua` to a dedicated `lua/lsp_config.lua`
6. Move all keymaps from `init.lua` to `config_func.lua` (already partially done)
7. Add documentation comments to plugin factory functions in `plugins.lua`
8. Consider extracting SQL snippets to `lua/snippets/sql.lua`
