local M = {}

function M.staged_diff()
	local result = vim.system({ "git", "--no-pager", "diff", "--staged" }, { text = true }):wait()
	if result.code == 129 or result.stdout == "" then
		return nil
	end
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR, { title = "opencode" })
		return nil
	end
	return result.stdout
end

local function strip_gitcommit_fence(text)
	local fenced = text:match("```gitcommit%s*\n(.-)\n```") or text:match("```%s*\n(.-)\n```")
	text = fenced or text
	return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function replace_commit_message(text)
	local lines = vim.split(strip_gitcommit_fence(text), "\n", { plain = true })
	if #lines == 0 or (#lines == 1 and lines[1] == "") then
		vim.notify("opencode returned an empty commit message", vim.log.levels.WARN, { title = "opencode" })
		return
	end

	local buf = vim.api.nvim_get_current_buf()
	local current = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local comment_start = #current
	for i, line in ipairs(current) do
		if line:match("^#") then
			comment_start = i - 1
			break
		end
	end
	if comment_start < #current then
		table.insert(lines, "")
	end
	vim.api.nvim_buf_set_lines(buf, 0, comment_start, false, lines)
end

function M.generate_commit_message()
	local diff = M.staged_diff()
	if not diff then
		vim.notify("No staged changes found", vim.log.levels.WARN, { title = "opencode" })
		return
	end

	local prompt = table.concat({
		"Write a commit message for the staged changes using the commitizen convention.",
		"Keep the title under 50 characters and wrap the body at 72 characters.",
		"Return only the commit message, without markdown fences or explanations.",
		"",
		"Staged diff:",
		"```diff",
		diff,
		"```",
	}, "\n")

	vim.notify("Generating commit message with opencode...", vim.log.levels.INFO, { title = "opencode" })
	vim.system({ "opencode", "run", prompt }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify(
					result.stderr ~= "" and result.stderr or "opencode run failed",
					vim.log.levels.ERROR,
					{ title = "opencode" }
				)
				return
			end
			replace_commit_message(result.stdout)
		end)
	end)
end

function M.select_command()
	require("opencode.server").get():next(function(server)
		return require("opencode.promise").new(function(resolve)
			server:get_commands(function(commands)
				resolve(commands)
			end)
		end)
	end):next(function(commands)
		if #commands == 0 then
			vim.notify("No opencode commands found", vim.log.levels.WARN, { title = "opencode" })
			return
		end
		table.sort(commands, function(a, b)
			return a.name < b.name
		end)
		return require("opencode.promise").select(commands, {
			prompt = "Select opencode command:",
			format_item = function(command)
				return string.format(
					"%s%s%s",
					command.name,
					string.rep(" ", math.max(1, 22 - #command.name)),
					command.description or ""
				)
			end,
		})
	end):next(function(command)
		if not command then
			return
		end
		if command.template and command.template ~= "" then
			require("opencode").prompt(command.template, { submit = true })
		else
			require("opencode").command(command.name)
		end
	end):catch(function(err)
		if err then
			vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
		end
	end)
end

M.prompts = {
	commit = {
		prompt = table.concat({
			"Write a commit message for the staged changes using the commitizen convention.",
			"Keep the title under 50 characters and wrap the body at 72 characters.",
			"Format the answer as a gitcommit code block.",
			"",
			"@staged_diff",
		}, "\n"),
		submit = true,
	},
}

return M
