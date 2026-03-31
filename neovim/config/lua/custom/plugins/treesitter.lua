-- treesitter.lua
-- Advanced syntax highlighting and code understanding
-- Provides better syntax highlighting than default vim
--
-- return {
-- 	"nvim-treesitter/nvim-treesitter",
-- 	branch = "main",
-- 	lazy = false,
-- 	build = ":TSUpdate",
-- 	opts = {
-- 		ensure_installed = { "bash", "c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
-- 		auto_install = true,
-- 		highlight = {
-- 			enable = true,
-- 			additional_vim_regex_highlighting = { "ruby" },
-- 		},
-- 		indent = { enable = true, disable = { "ruby" } },
-- 	},
-- 	config = function(_, opts)
-- 		require("nvim-treesitter.configs").setup(opts)
-- 	end,
-- }
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
}
