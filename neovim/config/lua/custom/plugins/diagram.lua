return {
	"3rd/diagram.nvim",
	dependencies = {
		"3rd/image.nvim", -- you'd probably want to configure image.nvim manually instead of doing this
	},
	opts = { -- you can just pass {}, defaults below
		events = {
			render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" },
			clear_buffer = { "BufLeave" },
		},
		renderer_options = {
			mermaid = {
				background = "transparent", -- nil | "transparent" | "white" | "#hex"
				theme = "dark", -- nil | "default" | "dark" | "forest" | "neutral"
				scale = 1, -- nil | 1 (default) | 2  | 3 | ...
				width = nil, -- nil | 800 | 400 | ...
				height = nil, -- nil | 600 | 300 | ...
				cli_args = nil, -- nil | { "--no-sandbox" } | { "-p", "/path/to/puppeteer" } | ...
			},
			plantuml = {
				charset = nil,
				cli_args = nil, -- nil | { "-Djava.awt.headless=true" } | ...
			},
			d2 = {
				theme_id = nil,
				dark_theme_id = nil,
				scale = nil,
				layout = nil,
				sketch = nil,
				cli_args = nil, -- nil | { "--pad", "0" } | ...
			},
			gnuplot = {
				size = nil, -- nil | "800,600" | ...
				font = nil, -- nil | "Arial,12" | ...
				theme = nil, -- nil | "light" | "dark" | custom theme string
				cli_args = nil, -- nil | { "-p" } | { "-c", "config.plt" } | ...
			},
		},
	},
	-- keys = {
	-- 	{
	-- 		"<leader>k", -- or any key you prefer
	-- 		function()
	-- 			require("diagram").show_diagram_hover()
	-- 		end,
	-- 		mode = "n",
	-- 		ft = { "markdown", "norg" }, -- Only in these filetypes
	-- 		desc = "Show diagram in new tab",
	-- 	},
	-- },
}
