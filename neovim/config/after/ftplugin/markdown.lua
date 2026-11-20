-- Auto-save de markdown: ao sair do insert, após mudanças no normal (dd, p, u),
-- ao trocar de buffer e quando o nvim perde o foco. Nunca enquanto se digita
-- (sem TextChangedI), para não gravar no disco a cada tecla.
--
-- Roda só em buffers markdown (este ftplugin) e o autocmd é local ao buffer.
-- O augroup leva o número do buffer: se o ftplugin rodar de novo no mesmo
-- buffer (ex.: :set ft=markdown), o clear evita autocmds duplicados.
local buf = vim.api.nvim_get_current_buf()

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	desc = "Auto-save de arquivos markdown",
	group = vim.api.nvim_create_augroup("cwl-markdown-autosave-" .. buf, { clear = true }),
	buffer = buf,
	callback = function()
		-- Só arquivos de verdade: pula buffers especiais e sem nome.
		if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("silent! update")
			end)
		end
	end,
})
