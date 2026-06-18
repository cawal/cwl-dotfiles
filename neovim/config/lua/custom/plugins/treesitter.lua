return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	keys = {
		{ "<leader>it", "<cmd>InspectTree<CR>", desc = "[I]nspect [T]ree" },
		{ "<leader>ie", "<cmd>Inspect<CR>", desc = "[I]nspect tree-sitter [E]lement" },
	},
	config = function()
		require("nvim-treesitter").setup({
			ensure_install = {
				"bash",
				"css",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("custom-treesitter-start", { clear = true }),
			callback = function(args)
				local ok = pcall(vim.treesitter.get_parser, args.buf)
				if ok then
					pcall(vim.treesitter.start, args.buf)
				end
			end,
		})
	end,
}
