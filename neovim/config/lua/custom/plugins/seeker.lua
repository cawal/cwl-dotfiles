return {
	"2kabhishek/seeker.nvim",
	dependencies = { "nvim-telescope/telescope.nvim", "folke/snacks.nvim" },
	cmd = { "Seeker" },
	keys = {
		{ "<leader>fa", ":Seeker files<CR>", desc = "Seek Files" },
		{ "<leader>ff", ":Seeker git_files<CR>", desc = "Seek Git Files" },
		{ "<leader>fg", ":Seeker grep<CR>", desc = "Seek Grep" },
		{ "<leader>fw", ":Seeker grep_word<CR>", desc = "Seek Grep Word" },
	},
	opts = {
		picker_provider = "telescope",
		-- picker_provider = "snacks", -- Picker provider: 'snacks' or 'telescope' (default: 'snacks')
		toggle_key = "<C-e>", -- Key to toggle between modes (default)
		picker_opts = {}, -- Options passed to the picker provider (optional)
	},
}
