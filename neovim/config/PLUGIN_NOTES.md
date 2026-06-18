# Neovim Plugin Notes

This note records plugins and config ideas adopted from `do-not-commit/config.nvim`.

## Added Or Expanded

- `b0o/SchemaStore.nvim`: common JSON/YAML schemas for `jsonls` and `yamlls`.
- `pmizio/typescript-tools.nvim`: richer TypeScript LSP integration, inlay hints, import completions, JSX tag closing, and separate diagnostics.
- `https://git.sr.ht/~whynothugo/lsp_lines.nvim`: toggle diagnostics between virtual text and expanded virtual lines with `<leader>l`.
- `tpope/vim-dadbod`: database adapter for SQL workflows.
- `kristijanhusak/vim-dadbod-ui`: UI for Dadbod connections and queries.
- `kristijanhusak/vim-dadbod-completion`: SQL completion source for `nvim-cmp`.
- `laytan/cloak.nvim`: masks sensitive values in `.env*` and `auth.json` buffers.
- `onsails/lspkind.nvim`: adds readable completion item labels/icons.
- `hrsh7th/cmp-buffer`: adds buffer words to completion.
- `roobert/tailwindcss-colorizer-cmp.nvim`: shows Tailwind color hints in completion.
- `mini.hipatterns`: highlights hex colors inline through the existing `mini.nvim` setup.

## Existing Plugins Strengthened

- `nvim-treesitter/nvim-treesitter`: now installs and starts parsers for Python, TypeScript/TSX, JavaScript, HTML, CSS, JSON/JSONC, SQL, Markdown, YAML, TOML, Lua, Vim, Bash, regex, and query files.
- `neovim/nvim-lspconfig`: now covers Python, Ruff, HTML, CSS, Tailwind, JSON, YAML, TOML, and Lua.
- `stevearc/conform.nvim`: now formats Python, JS/TS/TSX, HTML, CSS, JSON/JSONC, Markdown, YAML, SQL, and Lua.
- `mfussenegger/nvim-lint`: now runs Ruff, ESLint daemon, and SQLFluff where appropriate.

## Useful Commands

- `:Lazy`: inspect plugin install/load state.
- `:Mason`: inspect installed LSP servers, linters, and formatters.
- `:LspInfo`: confirm which LSP clients are attached to the current buffer.
- `:ConformInfo`: inspect formatter availability and selection.
- `:InspectTree`: inspect Treesitter parse tree for the current buffer.
- `:checkhealth`: run health checks.
- `<leader>l`: toggle diagnostic virtual text vs virtual lines.

## Follow-Up Ideas

- Consider `stevearc/oil.nvim` if you want a buffer-first file manager instead of a side tree.
- Consider Telescope smart history with `nvim-telescope/telescope-smart-history.nvim` and `kkharji/sqlite.lua`.
- Consider `stevearc/qf_helper.nvim` if quickfix becomes a bigger part of your workflow.
- Consider moving global options/keymaps into `plugin/*.lua` later to match Neovim runtime conventions.
