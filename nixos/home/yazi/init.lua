-- init.lua — inicialização dos plugins do Yazi (carregado no startup).

-- git.yazi: status do git como linemode. REQUER os fetchers em yazi.toml.
require("git"):setup {
	-- Ordem do sinal de status na linemode (maior = mais à direita).
	order = 1500,
}

-- smart-enter.yazi: por padrão o `open` age só no arquivo sob o cursor
-- (--hovered), evitando abrir seleções por engano. Descomente para que
-- o open aja em todos os arquivos selecionados:
-- require("smart-enter"):setup { open_multi = true }

-- chmod.yazi, smart-filter.yazi e mount.yazi não precisam de setup aqui —
-- são acionados pelos keymaps em keymap.toml.
