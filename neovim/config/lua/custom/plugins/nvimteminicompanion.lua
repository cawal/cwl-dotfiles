-- https://github.com/gutsavgupta/nvim-gemini-companion
return {
	"gutsavgupta/nvim-gemini-companion",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
	},
	event = "VeryLazy",
	config = function()
		-- You can configure the plugin by passing a table to the setup function
		-- Example:
		-- require("gemini").setup({
		--   cmds = {"gemini"},
		--   win = {
		--     preset = "floating",
		--     width = 0.8,
		--     height = 0.8,
		--   }
		-- })
		require("gemini").setup()
	end,
	-- keys = {
	-- 	{ "<leader>gg", "<cmd>GeminiToggle<cr>", desc = "Toggle Gemini CLI" },
	-- 	{ "<leader>gc", "<cmd>GeminiClose<cr>", desc = "Close Gemini CLI process" },
	-- 	{ "<leader>ga", "<cmd>GeminiAccept<cr>", desc = "Accept Gemini suggested changes" },
	-- 	{ "<leader>gr", "<cmd>GeminiReject<cr>", desc = "Reject Gemini suggested changes" },
	-- 	{ "<leader>gD", "<cmd>GeminiSendFileDiagnostic<cr>", desc = "Send File Diagnostics" },
	-- 	{ "<leader>gd", "<cmd>GeminiSendLineDiagnostic<cr>", desc = "Send Line Diagnostics" },
	-- 	{ "<leader>gs", "<cmd>GeminiSwitchSidebarStyle<cr>", desc = "Switch Sidebar Style" },
	-- },
}
