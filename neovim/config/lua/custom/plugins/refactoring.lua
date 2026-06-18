return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"lewis6991/async.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("refactoring").setup({})
		-- load refactoring Telescope extension
		pcall(require("telescope").load_extension, "refactoring")

		vim.keymap.set({ "n", "x" }, "<leader>rr", function()
			require("refactoring").select_refactor()
		end, { desc = "[R]efactoring: [R]efactorings..." })
	end,
}
