return {
	"github/copilot.vim",
	config = function()
		vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.keymap.set("n", "<leader>c0", ":Copilot disable<CR>", { desc = "Disable Copilot" })
		vim.keymap.set("n", "<leader>c1", ":Copilot enable<CR>", { desc = "Enable Copilot" })
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_filetypes = {
			["*"] = true,
			["markdown"] = true,
		}
	end,
}
