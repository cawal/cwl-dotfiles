" Best practices: https://www.reddit.com/r/vim/wiki/vimrctips

" Maps the leader key
let mapleader = '\'

let THEME = 'neovim-0-2-2'

" PLUGINS --------------------------------------------------------
call plug#begin() "vim-plug: https://github.com/junegunn/vim-plug

" Widgets
Plug 'junegunn/goyo.vim', { 'on' : 'Goyo' } " Zen mode
Plug 'sjl/gundo.vim', { 'on': ['GundoToggle','GundoShow'] } " Undo tree navigator
Plug 'majutsushi/tagbar', { 'on' : [ 'TagbarToggle' ] } " File/Class overview  (uses exuberant-ctags)
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle','NERDTreeClose'] } " File navigator


" General assistance plugins
Plug 'rhysd/vim-grammarous', { 'on' : 'GrammarousCheck' } " Grammar checking
Plug 'SirVer/ultisnips' " Easily create and use code/text snippets
Plug 'junegunn/vim-easy-align' " Easy align for (Markdown) tables
Plug 'tpope/vim-surround' " Easy add (ys) / change (cs) / remove (ds) surrounding characters/html tags
Plug 'chrisbra/Colorizer', { 'on' : 'ColorToggle' } " Highlight string colors
Plug 'junegunn/fzf', { 'dir' : '~/.fzf', 'do': './install --all' } " (Optional) Multi-entry selection UI.


" Programming language-related Plugins
Plug 'neoclide/coc.nvim', {'branch': 'release', 'for' : [ 'java', 'python' ] } " Language Server Client
Plug 'udalov/kotlin-vim', { 'for': 'kotlin'  } " Kotlin syntax highlighting
Plug 'leafgarland/typescript-vim', {'for': 'typescript' } " TS syntax highlighting

" Other
Plug 'vimwiki/vimwiki' " Markdown wiki for quick 'evernoting'

"Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh', }
call plug#end()


" CoC-Vim
" -----------------------------------------------------
let g:coc_node_path = $HOME . '/.nvm/versions/node/v12.6.0/bin/node'

" Goyo
" -----------------------------------------------------
function! s:goyo_enter()
endfunction

function! s:goyo_leave()
	colorscheme neovim-0-2-2
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" Grammarous
" -----------------------------------------------------
let g:grammarous#languagetool_cmd='java -jar $HOME/bin/LanguageTool-4.3/languagetool-commandline.jar'

" Vim-wiki
" ------------------------------------------------------
let g:vimwiki_list = [
	\ {'path':'~/Dropbox/vimwiki/', 'syntax':'markdown', 'ext':'.md'},
	\ {'path':'~/Dropbox/Academico/literature-reviews',
		\ 'syntax':'markdown', 'ext':'.md'}
\ ]


" ULTISNIPS
" -------------------------------------------------------
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
" Snippet directory
let g:UltiSnipsSnippetDirectories=["ultisnips"]

let g:deoplete#enable_at_startup = 1



" Filetypes and autocommands
" -------------------------------------------------------
augroup filetype_typescript
    autocmd!
    autocmd BufReadPost *.ts setlocal filetype=typescript
augroup END

augroup CustomTeX : 
	autocmd FileType tex :Goyo 80
	autocmd FileType tex :set spell
augroup END


" Language servers
" -------------------------------------------------------
" Bash: https://github.com/mads-hartmann/bash-language-server
"let g:LanguageClient_serverCommands = {
"    \ 'sh': ['bash-language-server', 'start'],
"    \ 'typescript': ['typescript-language-server', '--stdio'],
"    \ }


" VARIABLES AND OPTIONS -----------------------------------------

" Custom functions -------------------------------------------------

function! CWLInstallLanguageServers()
	:CocInstall coc-java
endfunction

function! CWLToggleZenMode()
	:NERDTreeClose
	:Goyo
endfunction

" Forces the coloring of the spelling errors
function! CWLToggleSpell()
	:set spell!
	:hi clear SpellBad
	:hi SpellBad ctermfg=7 ctermbg=1 
endfunction


" CONFIGS ------------------------------------------------------
" Better splits
set hidden " hides the buffer (instead of closing it) when a new file is loaded
set autochdir	" Change working directory to the one of the open buffer
set encoding=utf-8 " all my systems uses UTF-8
set modelines=0 " Don't read the modelines (security)
set linebreak " break lines at words
set splitbelow " by default, vim open split (:sp) in the top
set splitright " by default, vim open split (:vs) in the left
filetype on " enable filetype detection

" Spell highlight config ---------------------------------------
" http://vimdoc.sourceforge.net/htmldoc/syntax.html
" Using ANSI colors to match terminal XResources config
function! CWLHighlights() abort
	highlight clear SpellBad
	highlight SpellBad ctermfg=7 ctermbg=1 
	" hi SpellBad cterm=reverse

	highlight clear Search
	highlight Search ctermfg=0 ctermbg=7

	highlight clear IncSearch
	highlight IncSearch ctermfg=0 ctermbg=15
endfunction

augroup MyColors " auto reload my highlight scheme when colorscheme changes
    " Remove all auto-commands of this augroup 
    autocmd! 
    autocmd ColorScheme * call CWLHighlights()
augroup END
colorscheme default


" KEY MAPPINGS -----------------------------------------------------
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)

" Join with previous line (symmetric with J)
nnoremap K kJ
nnoremap <Esc><Esc> :noh<cr>

nnoremap <leader>c :ColorToggle<cr>
nnoremap <leader>f :NERDTreeToggle<cr>
nnoremap <leader>n :set number!<cr>
" run current file
nnoremap <leader>r :!"%:p"
nnoremap <leader>s :call CWLToggleSpell()<cr>
nnoremap <leader>z :call CWLToggleZenMode()<cr> 
nnoremap <leader>u :GundoToggle<cr>
nnoremap <leader>o :TagbarToggle<cr>

" Grammar checking
map <F5> :GrammarousCheck<cr>
map <F6> :GrammarousReset<cr>
map <F7> :set spelllang+=pt<cr>
map <F11> :call CWLToggleZenMode()<cr>

nnoremap <F4> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> <Leader>K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive Easyalign for a motion/text object (e.g., gaip)
nmap ga <Plug>(EasyAlign)

colorscheme neovim-0-2-2
