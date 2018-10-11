" PLUGINS --------------------------------------------------------
call plug#begin() "vim-plug: https://github.com/junegunn/vim-plug

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } "File navigator
Plug 'junegunn/goyo.vim', { 'on' : 'Goyo' } "Zen mode
Plug 'rhysd/vim-grammarous', { 'on' : 'GrammarousCheck' } "Grammar checking
"Plug 'ying17zi/vim-live-latex-preview'

call plug#end()

" configs for dpelle/vim-LanguageTool
"let g:languagetool_jar='$HOME/bin/LanguageTool-4.3/languagetool-commandline.jar'
let g:grammarous#languagetool_cmd='java -jar $HOME/bin/LanguageTool-4.3/languagetool-commandline.jar'

" KEY MAPPINGS------------------------------------------------------
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)

" Toggle file navigator
map <F12> :NERDTreeToggle <Enter>

" Toggle Zen mode
map <F11> :Goyo <Enter> 

" Grammar checking
map <F5> :GrammarousCheck <Enter>
map <F6> :GrammarousReset <Enter>
