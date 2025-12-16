return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("refactoring").setup({})
		-- load refactoring Telescope extension
		require("telescope").load_extension("refactoring")

		vim.keymap.set({ "n", "x" }, "<leader>rr", function()
			require("telescope").extensions.refactoring.refactors()
		end, { desc = "[R]efactoring: [R]efactorings..." })
	end,
}
