return {
	"junegunn/goyo.vim",
	-- You can enable it later with `:Goyo`
	config = function()
		vim.g.goyo_width = 80 -- Set the width of Goyo mode
		vim.g.goyo_height = 1000 -- Set the height of Goyo mode (0.8 means 80% of the screen height)
		vim.g.goyo_minimalist = 0 -- Enable minimalist mode
		vim.g.goyo_cursorline = 0 -- Enable cursor line in Goyo mode
		vim.g.goyo_cursorcolumn = 0 -- Enable cursor column in Goyo mode

		vim.keymap.set("n", "<leader>z", function()
			vim.cmd("Goyo")
		end, { desc = "[Z]en: Toggle Zen mode" })
	end,
}
