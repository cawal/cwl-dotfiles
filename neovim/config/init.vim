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

Plug 'tpope/vim-fugitive' " Git commands plugin

" Programming language-related Plugins
Plug 'neoclide/coc.nvim', {'branch': 'release', 'for' : [ 'java', 'python' ] } " Language Server Client
Plug 'udalov/kotlin-vim', { 'for': 'kotlin'  } " Kotlin syntax highlighting
Plug 'leafgarland/typescript-vim', {'for': 'typescript' } " TS syntax highlighting

Plug 'editorconfig/editorconfig-vim' " Use editor config files for formatting
" Other
Plug 'vimwiki/vimwiki' " Markdown wiki for quick 'evernoting'

call plug#end()


" CoC-Vim
" -----------------------------------------------------

" Path for node.js
let g:coc_node_path = $HOME . '/.nvm/versions/node/v12.6.0/bin/node'

" Goyo
" -----------------------------------------------------
function! s:goyo_enter()
	" commands to execute when entering zen mode
	" nothing extra here...
endfunction

function! s:goyo_leave()
	" After leaving zen mode, 
	" its necessary to reload the colorscheme
	colorscheme neovim-0-2-2
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" Grammarous
" -----------------------------------------------------
let g:grammarous#languagetool_cmd='java -jar $HOME/bin/LanguageTool-4.3/languagetool-commandline.jar'

" Vim-wiki
" ------------------------------------------------------
let my_nested_syntaxes = {'java':'java', 'kotlin':'kotlin','python':'python'}

let personal_wiki = {}
let personal_wiki.path = '~/Dropbox/vimwiki/'
let personal_wiki.syntax = 'markdown'
let personal_wiki.ext = '.md'
let personal_wiki.nested_syntaxes = my_nested_syntaxes

let phd_wiki = {}
let phd_wiki.path = '~/Dropbox/Academico/literature-reviews'
let phd_wiki.syntax = 'markdown'
let phd_wiki.ext = '.md'
let phd_wiki.nested_syntaxes = my_nested_syntaxes


let g:vimwiki_list = [
	\ personal_wiki,
	\ phd_wiki 
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


" Custom functions -------------------------------------------------
function! CWLInstallLanguageServers()
	:CocInstall coc-java
endfunction

function! CWLToggleZenMode()
	:NERDTreeClose
	:Goyo
endfunction

" Forces the coloring of the spelling errors
" TODO I think I don't need it anymore with my ~own~ colorscheme
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
" TODO I think I don't need it anymore with my ~own~ colorscheme
function! CWLHighlights() abort
	highlight clear SpellBad
	highlight SpellBad ctermfg=7 ctermbg=1 
	" hi SpellBad cterm=reverse

	highlight clear Search
	highlight Search ctermfg=0 ctermbg=7

	highlight clear IncSearch
	highlight IncSearch ctermfg=0 ctermbg=15
endfunction

" TODO I think I don't need it anymore with my ~own~ colorscheme
augroup MyColors " auto reload my highlight scheme when colorscheme changes
    " Remove all auto-commands of this augroup 
    autocmd! 
    autocmd ColorScheme * call CWLHighlights()
augroup END
colorscheme default


" KEY MAPPINGS -----------------------------------------------------
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)


" ALL MODE MAPPINGS
" No arrow keys (Vim Hard mode)
"noremap <Up> <NOP>
"noremap <Down> <NOP>
"noremap <Left> <NOP>
"noremap <Right> <NOP>

" Grammar checking
map <F5> :GrammarousCheck<cr>
" Remove grammar checking marks
map <F6> :GrammarousReset<cr>
" Add portuguese words to spell
map <F7> :set spelllang+=pt<cr>


" NORMAL MODE MAPPINGS

" Start interactive EasyAlign for a motion/text object (e.g., gaip)
nmap ga <Plug>(EasyAlign)

" Join with previous line (symmetric with J)
nnoremap K kJ

" remove search highlights
nnoremap <Esc><Esc> :noh<cr>

" toggle matching highlight for color codes
nnoremap <leader>c :ColorToggle<cr>

" Toggles Nerdtree navigation
nnoremap <leader>f :NERDTreeToggle<cr>

" Toggles line number indication
nnoremap <leader>n :set number!<cr>

" Toggle file/class overeview panel
nnoremap <leader>o :TagbarToggle<cr>

" run current file contents
nnoremap <leader>r :!"%:p"

" Toggle spell checking
nnoremap <leader>s :call CWLToggleSpell()<cr>

" Toggle zen mode
nnoremap <leader>z :call CWLToggleZenMode()<cr> 

" Toggle undo history graph panel
nnoremap <leader>u :GundoToggle<cr>

" Switching Buffers
nnoremap <leader>[ :bp<cr>
nnoremap <leader>] :bn<cr>


" VISUAL MODE MAPPINGS

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)


" ------------------------------------------------------------
" Set my Neovim v0.2.2-derived colorscheme (XResources-based)
colorscheme neovim-0-2-2
