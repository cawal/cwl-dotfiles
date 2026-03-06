return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>G", ":tab Git<CR>", { desc = "Abrir Git Status em nova tab" })
	end,
}
