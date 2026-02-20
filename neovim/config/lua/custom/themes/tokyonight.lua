-- tokyonight.lua
-- Tokyo Night colorscheme
-- Modern dark theme with multiple variants

return {
	"folke/tokyonight.nvim",
	priority = 1000, -- Load before other plugins
	init = function()
		vim.cmd.colorscheme("tokyonight-night")
		vim.cmd.hi("Comment gui=none")
	end,
}
