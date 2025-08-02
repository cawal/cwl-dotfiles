-- CopilotChat.nvim
-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
--

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
	},
	build = "make tiktoken",
	opts = {
		-- See Configuration section for options
	},
	-- See Commands section for default commands if you want to lazy load on them
	config = function()
		chat = require("CopilotChat").setup({
			prompts = {
				-- You can add your own prompts here
				MyCustomPrompt = {
					prompt = "Explain how it works.",
					system_prompt = "You are very good at explaining stuff",
					mapping = "<leader>ce",
					description = "My custom prompt description",
				},
				Yarrr = {
					system_prompt = "You are fascinated by pirates, so please respond in pirate speak.",
				},
				-- NiceInstructions = {
				-- 	system_prompt = "You are a nice coding tutor, so please respond in a friendly and helpful manner."
				-- 		.. require("CopilotChat.config.prompts").COPILOT_BASE.system_prompt,
				-- },
			},
			window = {
				layout = "vertical", -- 'vertical', 'horizontal', 'float'
				width = 0.3, -- 50% of screen width
			},
		})

		-- You can add your own options here
		vim.keymap.set("n", "<leader>cc", function()
			require("CopilotChat").toggle()
		end, { desc = "[C]opilot [C]hat: Toggle chat window" })
		vim.keymap.set("n", "<leader>cp", function()
			require("CopilotChat").select_prompt()
		end, { desc = "[C]opilot [P]rompts: Select prompts" })
		vim.keymap.set("n", "<leader>cm", function()
			require("CopilotChat").select_model()
		end, { desc = "[C]opilot [M]odels: Select models" })
		vim.keymap.set("n", "<leader>cr", function()
			vim.cmd("CopilotChatReview")
		end, { desc = "[C]opilot [R]eview: Review selected code" })
		vim.keymap.set("v", "<leader>cr", function()
			vim.cmd("CopilotChatReview")
		end, { desc = "[C]opilot [R]eview: Review selected code" })
	end,
}
