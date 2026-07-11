-- lsp.lua
-- Language Server Protocol configuration
-- Provides IDE-like features: go-to-definition, references, autocompletion, etc.

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP
		{ "j-hui/fidget.nvim", opts = {} },

		-- Lua LSP configuration for Neovim config, runtime and plugins
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },

		-- JSON/YAML schemas for common config files
		"b0o/SchemaStore.nvim",

		-- Better TypeScript server control than plain ts_ls
		{
			"pmizio/typescript-tools.nvim",
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		},

		-- Toggle between compact and expanded diagnostic display
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	},
	config = function()
		-- This function gets run when an LSP attaches to a buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- LSP Navigation keymaps
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map(
					"<leader>ws",
					require("telescope.builtin").lsp_dynamic_workspace_symbols,
					"[W]orkspace [S]ymbols"
				)
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- Highlight references on cursor hold
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		-- Extend LSP capabilities with nvim-cmp
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Define language servers to install and configure
		local servers = {
			pyright = {
				settings = {
					python = {
						analysis = {
							autoImportCompletions = true,
							diagnosticMode = "workspace",
							typeCheckingMode = "basic",
						},
					},
				},
			},
			ruff = {},
			html = {},
			cssls = {},
			tailwindcss = {},
			taplo = {},
			jsonls = {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},
			yamlls = {
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
		}

		require("typescript-tools").setup({
			capabilities = capabilities,
			settings = {
				separate_diagnostic_server = true,
				publish_diagnostic_on = "insert_leave",
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
				tsserver_file_preferences = {
					includeCompletionsForImportStatements = true,
					includeCompletionsForModuleExports = true,
					includeInlayEnumMemberValueHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayVariableTypeHints = true,
				},
				complete_function_calls = true,
				tsserver_max_memory = 4096,
			},
		})

		-- Setup Mason
		require("mason").setup()

		-- Ensure servers and tools are installed
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			-- "stylua", -- Lua formatter - installed via NixOS system package
			"black",
			"eslint_d",
			"isort",
			"prettier",
			"ruff",
			"sqlfluff",
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		-- Configure LSP servers
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		require("lsp_lines").setup()
		vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
		vim.keymap.set("n", "<leader>l", function()
			local config = vim.diagnostic.config() or {}
			vim.diagnostic.config({
				virtual_text = not config.virtual_text,
				virtual_lines = config.virtual_text,
			})
		end, { desc = "Toggle diagnostic lines" })
	end,
}
