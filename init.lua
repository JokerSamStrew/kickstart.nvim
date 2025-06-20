-- Get the directory containing the init.lua file
local config_dir = vim.fn.stdpath("config")

-- Add the config directory to the package.path
local package_path_str = config_dir .. "/?.lua"
package.path = package.path .. ";" .. package_path_str

local config = require('config_func')

config.setup_globals()
config.setup_options()

config.install_package_manager()

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.

local plugins = require('plugins')
config.package_manager().setup({
    -- NOTE: First, some plugins that don't require any configuration
    plugins.neoformat(),
    plugins.vim_fugitive(),
    plugins.vim_rhubarb(),
    -- plugins.vim_sleuth(),
    plugins.nvim_web_devicons(),
    plugins.nvim_surround(),
    plugins.vim_dadbod_ui(),
    plugins.nvim_lspconfig(),
    plugins.nvim_cmp(),
    plugins.which_key(),
    plugins.gitsigns(),

    plugins.themery(),
    plugins.onedark_nvim(),
    plugins.catppuccin_nvim(),

    plugins.lualine(),
    plugins.indent_blankline(),
    plugins.comment(),
    plugins.venv_selector(),
    plugins.telescope(),
    plugins.nvim_treesitter(),
    plugins.nvim_treesitter_context(),
    plugins.langmapper(),
    plugins.harpoon(),
}, {})


plugins.telescope__configure()
plugins.nvim_treesitter__configure()
plugins.nvim_lspconfig__configure()
plugins.nvim_cmp__configure()
plugins.catppuccin_nvim__configure()

config.setup_keymaps()
