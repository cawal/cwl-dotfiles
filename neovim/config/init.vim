" Maps the leader key
let mapleader = '\'

" PLUGINS --------------------------------------------------------
call plug#begin() "vim-plug: https://github.com/junegunn/vim-plug

Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle','NERDTreeClose'] } "File navigator
Plug 'junegunn/goyo.vim', { 'on' : 'Goyo' } "Zen mode
Plug 'rhysd/vim-grammarous', { 'on' : 'GrammarousCheck' } "Grammar checking
"Plug 'ying17zi/vim-live-latex-preview'

call plug#end()


" CONFIGS ------------------------------------------------------
" Better splits
set splitbelow
set splitright
filetype on

" Config for grammarous
let g:grammarous#languagetool_cmd='java -jar $HOME/bin/LanguageTool-4.3/languagetool-commandline.jar'

" VARIABLES AND OPTIONS -----------------------------------------
set encoding=utf-8
" Don't read the modelines (security)
set modelines=0

" KEY MAPPINGS------------------------------------------------------
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)

function! CWLToggleZenMode()
	:NERDTreeClose
	:Goyo
endfunction

" Toggle file navigator
map <F12> :NERDTreeToggle <Enter>
nnoremap <leader>f :NERDTreeToggle <Enter>

map <F11> :call CWLToggleZenMode()<cr>
nmap <leader>z :call CWLToggleZenMode()<cr> 

" Grammar checking
map <F5> :GrammarousCheck <Enter>
map <F6> :GrammarousReset <Enter>

nnoremap <Esc><Esc> :noh<Enter>

" Join with previous line (symmetric with J)
nnoremap K kJ

nnoremap ; :


" AUTOCOMMANDS -----------------------------------------------------------
" 
augroup CustomTeX : 
	autocmd FileType tex :Goyo 80
augroup END
