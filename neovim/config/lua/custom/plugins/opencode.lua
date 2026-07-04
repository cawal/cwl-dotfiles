return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `toggle()`.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {} } },
	},
	config = function()
		local custom_opencode = require("custom.helpers.opencode")

		vim.g.opencode_opts = {
			contexts = {
				["@staged_diff"] = custom_opencode.staged_diff,
			},
			prompts = custom_opencode.prompts,
		}

		-- Required for `vim.g.opencode_opts.auto_reload`
		vim.opt.autoread = true

		-- Recommended/example keymaps
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask about this" })
		vim.keymap.set({ "n", "x" }, "<leader>o+", function()
			require("opencode").prompt("@this")
		end, { desc = "Add this" })
		vim.keymap.set({ "n", "x" }, "<leader>os", function()
			require("opencode").select()
		end, { desc = "Select prompt" })
		vim.keymap.set("n", "<leader>ot", function()
			require("opencode").toggle()
		end, { desc = "Toggle embedded" })
		vim.keymap.set("n", "<leader>oc", function()
			custom_opencode.select_command()
		end, { desc = "Select opencode command" })
		vim.keymap.set("n", "<leader>om", function()
			require("opencode").prompt("commit")
		end, { desc = "Generate commit message prompt" })
		vim.keymap.set("n", "<leader>on", function()
			require("opencode").command("session.new")
		end, { desc = "New session" })
		vim.keymap.set("n", "<leader>oi", function()
			require("opencode").command("session.interrupt")
		end, { desc = "Interrupt session" })
		vim.keymap.set("n", "<leader>oA", function()
			require("opencode").command("agent.cycle")
		end, { desc = "Cycle selected agent" })
		vim.keymap.set("n", "<S-C-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "Messages half page up" })
		vim.keymap.set("n", "<S-C-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "Messages half page down" })

		vim.api.nvim_create_user_command("OpencodeCommitMessage", custom_opencode.generate_commit_message, {})
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "gitcommit",
			callback = function(args)
				vim.keymap.set("n", "<leader>og", custom_opencode.generate_commit_message, {
					buffer = args.buf,
					desc = "Generate commit message with opencode",
				})
			end,
		})
	end,
}
