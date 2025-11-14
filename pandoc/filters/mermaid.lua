-- Pandoc filter to process code blocks with class "mermaid" containing
--
-- * Assumes that mmdx is  in the path.
-- * For textual output formats, use --extract-media=mermaid-images
-- * For HTML formats, you may alternatively use --embed-resources

local filetypes = { html = { "png", "image/png" }, latex = { "pdf", "application/pdf" } }
local filetype = filetypes[FORMAT][1] or "png"
local mimetype = filetypes[FORMAT][2] or "image/png"

local function mermaid2eps(mermaid, filetype)
	local final = pandoc.pipe("mmdc", { "-i", "-", "-o", "-", "-e", filetype }, mermaid)
	return final
end

function CodeBlock(block)
	if block.classes[1] == "mermaid" then
		local img = mermaid2eps(block.text, filetype)
		local fname = pandoc.sha1(img) .. "." .. filetype
		pandoc.mediabag.insert(fname, mimetype, img)
		return pandoc.Para({ pandoc.Image({ pandoc.Str("mermaid tune") }, fname) })
	end
end
