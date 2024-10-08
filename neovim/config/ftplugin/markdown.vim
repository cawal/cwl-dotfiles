" Recognizes $$ as math boundaries
"autocmd filetype markdown syn region math start=/\\$\\$/ end=/\\$\\$/
"autocmd filetype markdown syn match math '\\$[^$].\{-}\$'
"hi link math Statement
"
"function! Preview()
"    MarkdownPreview
"endfunction 


