return {
	"alligator/accent.vim",
	priority = 1000, -- Load before other plugins
	init = function()
		vim.g.accent_colour = "orange"
		vim.g.accent_darken = 1
		-- vim.g.accent_auto_cwd_colour = 1
	end,
}
