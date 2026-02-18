-- filetree.lua
-- File explorer in a tree view
-- Navigate and manage files with <leader>st

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			sources = {
				"filesystem",
				"buffers",
				"git_status",
				"document_symbols",
			},
		})
		vim.keymap.set("n", "<leader>st", function()
			vim.cmd("Neotree toggle")
		end, { desc = "[S]earch Files in a [T]ree / Close Tree" })
		vim.keymap.set("n", "<leader>sB", function()
			vim.cmd("Neotree buffers toggle")
		end, { desc = "[S]earch [B]uffer in a Tree / Close Tree" })
	end,
}
