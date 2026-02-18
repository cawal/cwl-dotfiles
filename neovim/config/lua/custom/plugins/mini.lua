-- mini.lua
-- Collection of small independent plugins
-- Includes text objects, surround, and statusline

return {
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		-- Examples: va), yinq, ci'
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings
		-- Examples: saiw), sd', sr)'
		require("mini.surround").setup()

		-- Simple statusline
		local statusline = require("mini.statusline")
		statusline.setup({ use_icons = vim.g.have_nerd_font })

		-- Custom statusline section for cursor location
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			return "%2l:%-2v"
		end
	end,
}
