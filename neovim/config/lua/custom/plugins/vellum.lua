return {
	"blackhat-7/vellum.nvim",
	ft = "markdown",
	keys = { { "<leader>mp", "<cmd>Vellum<cr>", desc = "Markdown preview" } },
	init = function()
		-- O renderer (mermaid, KaTeX) usa o puppeteer, que baixa um
		-- chrome-headless-shell genérico em ~/.cache/puppeteer. No NixOS esse
		-- binário não roda (falta libnspr4.so e cia., o nix-ld não as traz), e
		-- os diagramas nunca viravam imagem. Apontar o puppeteer para o Chrome
		-- do sistema resolve; o processo do renderer herda o env do nvim.
		if not vim.env.PUPPETEER_EXECUTABLE_PATH then
			local chrome = vim.fn.exepath("google-chrome-stable")
			if chrome ~= "" then
				vim.env.PUPPETEER_EXECUTABLE_PATH = chrome
			end
		end
	end,
	opts = {
		-- O herdr descarta sem aviso imagens acima de ~5,9 MP (ver README do
		-- vellum); fora dele, sem limite.
		max_pixels = vim.env.TERM_PROGRAM == "herdr" and 5.5e6 or nil,
	},
}
