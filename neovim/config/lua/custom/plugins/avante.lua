-- plugin url: https://github.com/yetone/avante.nvim
return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	version = false,
	build = "make",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"hrsh7th/nvim-cmp",
		"folke/snacks.nvim",
		"MeanderingProgrammer/render-markdown.nvim",
	},
	opts = {
		provider = "opencode",
		instructions_file = "AGENTS.md",
		-- Keep the default mappings explicit here as a quick local reference.
		mappings = {
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<M-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
			cancel = {
				normal = { "<C-c>", "<Esc>", "q" },
				insert = { "<C-c>" },
			},
			sidebar = {
				apply_all = "A",
				apply_cursor = "a",
				retry_user_request = "r",
				edit_user_request = "e",
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
				remove_file = "d",
				add_file = "@",
				close = { "<Esc>", "q" },
				close_from_input = nil,
			},
		},
		input = {
			provider = "snacks",
			provider_opts = {
				title = "Avante Input",
				icon = " ",
			},
		},
		acp_providers = {
			["opencode"] = {
				command = "opencode",
				args = { "acp" },
			},
			["gemini-cli"] = {
				command = "gemini",
				args = { "--experimental-acp" },
				env = {
					NODE_NO_WARNINGS = "1",
					GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
				},
			},
		},
	},
}
