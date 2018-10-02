" PLUGINS --------------------------------------------------------
call plug#begin() "vim-plug: https://github.com/junegunn/vim-plug
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } "File navigator
Plug 'junegunn/goyo.vim', { 'on' : 'Goyo' } "Zen mode
"Plug 'ying17zi/vim-live-latex-preview'
call plug#end()


" KEY MAPPINGS------------------------------------------------------
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)

" Toggle file navigator
map <F12> :NERDTreeToggle <Enter>

" Toggle Zen mode
map <F11> :Goyo <Enter> 
