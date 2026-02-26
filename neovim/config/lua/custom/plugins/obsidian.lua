return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	ft = "markdown",
	---@module 'obsidian'
	---@type obsidian.config
	opts = { -- default options: https://github.com/obsidian-nvim/obsidian.nvim/blob/main/lua/obsidian/config/default.lua
		legacy_commands = false, -- this will be removed in the next major release
		workspaces = {
			{
				name = "personal",
				path = "~/Zettelkasten",
			},
		},
		note = {
			template = vim.NIL,
		},
		frontmatter = {
			enabled = false, -- enable frontmatter to add metadata to your notes
		},
	},
}
