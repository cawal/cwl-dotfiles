" Maps the leader key
let mapleader = '\'

" PLUGINS --------------------------------------------------------
call plug#begin() "vim-plug: https://github.com/junegunn/vim-plug

Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle','NERDTreeClose'] } "File navigator
Plug 'junegunn/goyo.vim', { 'on' : 'Goyo' } "Zen mode
Plug 'rhysd/vim-grammarous', { 'on' : 'GrammarousCheck' } "Grammar checking

Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh', }
" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'leafgarland/typescript-vim', {'for': 'typescript' } 
"Plug 'ying17zi/vim-live-latex-preview'

call plug#end()


augroup filetype_typescript
    autocmd!
    autocmd BufReadPost *.ts setlocal filetype=typescript
augroup END


" Language servers
" Bash: https://github.com/mads-hartmann/bash-language-server
set hidden
let g:LanguageClient_serverCommands = {
    \ 'sh': ['bash-language-server', 'start'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ }

nnoremap <F4> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> <Leader>K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>


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
