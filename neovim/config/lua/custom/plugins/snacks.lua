return {
	"folke/snacks.nvim",
	---@type snacks.Config
	opts = {
		gh = { -- https://github.com/folke/snacks.nvim/blob/main/docs/gh.md
			-- your gh configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section
			--- Keymaps for GitHub buffers
			---@type table<string, snacks.gh.Keymap|false>?
			keys = {
				select = { "<cr>", "gh_actions", desc = "Select Action" },
				edit = { "i", "gh_edit", desc = "Edit" },
				comment = { "a", "gh_comment", desc = "Add Comment" },
				close = { "c", "gh_close", desc = "Close" },
				reopen = { "o", "gh_reopen", desc = "Reopen" },
			},
		},
	},
	keys = {
		{
			"<leader>gi",
			function()
				Snacks.picker.gh_issue()
			end,
			desc = "GitHub Issues (open)",
		},
		{
			"<leader>gI",
			function()
				Snacks.picker.gh_issue({ state = "all" })
			end,
			desc = "GitHub Issues (all)",
		},
		{
			"<leader>gp",
			function()
				Snacks.picker.gh_pr()
			end,
			desc = "GitHub Pull Requests (open)",
		},
		{
			"<leader>gP",
			function()
				Snacks.picker.gh_pr({ state = "all" })
			end,
			desc = "GitHub Pull Requests (all)",
		},
	},
}
