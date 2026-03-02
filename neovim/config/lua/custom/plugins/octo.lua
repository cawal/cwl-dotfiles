return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	opts = {
		-- or "fzf-lua" or "snacks" or "default"
		picker = "telescope",
		-- bare Octo command opens picker of commands
		enable_builtin = true,
	},
	keys = {
		{
			"<leader>ghi",
			"<CMD>Octo issue list<CR>",
			desc = "List GitHub Issues",
		},
		{
			"<leader>ghp",
			"<CMD>Octo pr list<CR>",
			desc = "List GitHub PullRequests",
		},
		{
			"<leader>ghd",
			"<CMD>Octo discussion list<CR>",
			desc = "List GitHub Discussions",
		},
		{
			"<leader>ghn",
			"<CMD>Octo notification list<CR>",
			desc = "List GitHub Notifications",
		},
		{
			"<leader>ghs",
			function()
				require("octo.utils").create_base_search_command({ include_current_repo = true })
			end,
			desc = "Search GitHub",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		-- OR "ibhagwan/fzf-lua",
		-- OR "folke/snacks.nvim",
		"nvim-tree/nvim-web-devicons",
	},
}
