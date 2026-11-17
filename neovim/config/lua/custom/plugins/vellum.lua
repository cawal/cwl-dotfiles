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

		-- O vellum só desenha imagens se reconhecer kitty/Ghostty, e decide isso
		-- pelo env (KITTY_WINDOW_ID, TERM, TERM_PROGRAM) ou perguntando ao tmux.
		-- Num pane do herdr nada disso aparece: TERM_PROGRAM=herdr, e os panes
		-- herdam o env do *servidor* do herdr, não do kitty onde o cliente roda.
		-- O herdr fala o protocolo kitty graphics, então marcamos o pane como
		-- kitty só para este nvim. Ressalva: com o cliente do herdr dentro do
		-- tmux as imagens somem (herdr#5116); use o atalho Herdr, que abre no kitty.
		if vim.env.TERM_PROGRAM == "herdr" and not vim.env.KITTY_WINDOW_ID then
			vim.env.KITTY_WINDOW_ID = "herdr"
		end
	end,
	opts = {
		-- O herdr descarta sem aviso imagens acima de ~5,9 MP (ver README do
		-- vellum); fora dele, sem limite.
		max_pixels = vim.env.TERM_PROGRAM == "herdr" and 5.5e6 or nil,
	},
}
