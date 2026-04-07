local opts = {
	layout = {
		---@type "left"|"right"
		direction = "left",
		---@type "adaptive"|integer|number
		--- adaptive: exact the width of tree graph
		--- if number given is a float less than 1, the width is set to `vim.o.columns * that number`
		width = 0.5,
	},
	-- diff for the node under cursor
	-- shown under the tree graph
	diff_cur_node = {
		enabled = true,
		---@type number float less than 1
		--- The diff window's height is set to a specified percentage of the original (namely tree graph) window's height.
		split_percent = 0.7,
	},
	-- automatically update the buffer that the tree is attached to
	-- only works for buffer whose buftype is <empty>
	auto_attach = {
		enabled = true,
		excluded_ft = { "oil" },
	},
	marks = {
		persist = true,
		persist_path = vim.fn.stdpath("data") .. "/atone_marks.json",
		---@type string[]
		--- finders are tried in order. "builtin" is always available.
		finders = { "fzf-lua", "telescope", "builtin" },
	},
	keymaps = {
		tree = {
			quit = { "<C-c>", "q" },
			next_node = "j", -- support v:count
			pre_node = "k", -- support v:count
			jump_to_G = "G",
			jump_to_gg = "gg",
			undo_to = "<CR>",
			set_mark = "m",
			delete_mark = { "x", "X" },
			delete_all_marks = "dM",
			goto_mark = { "'", "`" },
			mark_picker = "s",
			help = { "?", "g?" },
		},
		auto_diff = {
			quit = { "<C-c>", "q" },
			help = { "?", "g?" },
		},
		help = {
			quit_help = { "<C-c>", "q" },
		},
	},
	ui = {
		-- refer to `:h 'winborder'`
		border = "single",
		-- compact graph style
		compact = true,
	},
}

return {
	"XXiaoA/atone.nvim",
	cmd = "Atone",
	keys = {
		{ "<leader>sU", "<cmd>Atone toggle<CR>", desc = "[S]how [U]ndo diffs" },
	},
	opts = opts, -- your configuration here
}
