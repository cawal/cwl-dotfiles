-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options") -- Load options
require("keymaps") -- Load keymaps
require("autocommands") -- Load autocommands

-- [[ Install `lazy.nvim` plugin manager ]]
require("lazy_install") -- Load lazy.nvim plugin manager

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Plugins are now modularized in lua/custom/plugins/*.lua
require("lazy").setup({
	-- Import kickstart plugins (debug, indent_line, lint)
	require("kickstart.plugins.debug"),
	require("kickstart.plugins.indent_line"),
	require("kickstart.plugins.lint"),

	-- Import all custom themes from lua/custom/themes/*.lua
	-- Themes have priority = 1000 and load before regular plugins
	{ import = "custom.themes" },

	-- Import all custom plugins from lua/custom/plugins/*.lua
	-- This includes: sleuth, comment, gitsigns, whichkey, telescope, lsp,
	-- formatter, completion, todocomments, filetree, mini, treesitter
	-- and your custom plugins (copilot, obsidian, etc.)
	{ import = "custom.plugins" },
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
vim.cmd.colorscheme("visual_studio_code")
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
