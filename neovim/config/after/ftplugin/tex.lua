vim.keymap.set("n", "z]]", "V]]kkzf]]", { buffer = true, desc = "Fold until next section" })
vim.keymap.set("n", "z[]", "[[}V]]kkzf]]", { buffer = true, desc = "Fold current section" })
