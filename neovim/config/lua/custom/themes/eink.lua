return {
	"e-ink-colorscheme/e-ink.nvim",
	priority = 1000,
	config = function()
		require("e-ink").setup()
		vim.cmd.colorscheme("e-ink")

		-- choose light mode or dark mode
		-- vim.opt.background = "dark"
		-- vim.opt.background = "light"
		--
		-- or do
		-- :set background=dark
		-- :set background=light
		local set_hl = vim.api.nvim_set_hl
		local mono = require("e-ink.palette").mono()

		--[[
-- light mode
{
   "#CCCCCC", "#C2C2C2", "#B8B8B8", "#AEAEAE", "#A4A4A4", "#9A9A9A", "#909090", "#868686",
   "#7C7C7C", "#727272", "#686868", "#5E5E5E", "#545454", "#4A4A4A", "#474747", "#333333"
}

-- dark mode
{
   "#333333", "#474747", "#4A4A4A", "#545454", "#5E5E5E", "#686868", "#727272", "#7C7C7C",
   "#868686", "#909090", "#9A9A9A", "#A4A4A4", "#AEAEAE", "#B8B8B8", "#C2C2C2", "#CCCCCC"
}
]]

		local everforest = require("e-ink.palette").everforest()
		--[[
-- light mode
{
   red = "#F85552",
   statusline3 = "#E66868",
   bg_red = "#FFE7DE",
   yellow = "#DFA000",
   green = "#8DA101",
   statusline1 = "#93B259",
   bg_green = "#f3f5d9",
   blue = "#3A94C5",
   bg_blue = "#ECF5ED",
   aqua = "#35A77C",
   purple = "#DF69BA",
   orange = "#F57D26"
}

-- dark mode
{
   red = "#E67E80",
   statusline3 = "#E67E80",
   bg_red = "#4C3743",
   yellow = "#DBBC7F",
   green = "#A7C080",
   statusline1 = "#A7C080",
   bg_green = "#3C4841",
   blue = "#7FBBB3",
   bg_blue = "#384B55",
   aqua = "#83C092",
   purple = "#D699B6",
   orange = "#E69875"
}
]]
	end,
}
