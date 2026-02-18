-- todocomments.lua
-- Highlight TODO, FIXME, NOTE, etc. in comments
-- Makes special comments stand out in your code

return {
	"folke/todo-comments.nvim",
	event = "VimEnter",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = { signs = false },
}
