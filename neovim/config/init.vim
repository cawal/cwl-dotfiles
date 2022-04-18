" Best practices: https://www.reddit.com/r/vim/wiki/vimrctips

" Maps the leader key
let mapleader = '\'
nnoremap <space> <Nop>
let mapleader = ' '

let THEME = 'neovim-0-2-2'

" PLUGINS --------------------------------------------------------
call plug#begin() "vim-plug: https://github.com/junegunn/vim-plug

" Widgets
Plug 'junegunn/goyo.vim', { 'on' : 'Goyo' } " Zen mode
Plug 'junegunn/limelight.vim', {'on': ['Limelight', 'Limelight!', 'Limelight!!']} " fades all lines but current
Plug 'sjl/gundo.vim', { 'on': ['GundoToggle','GundoShow'] } " Undo tree navigator
Plug 'preservim/tagbar', { 'on' : [ 'TagbarToggle' ] } " File/Class overview  (uses universal-ctags)
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle','NERDTreeClose'] } " File navigator


" General assistance plugins
Plug 'rhysd/vim-grammarous', { 'on' : 'GrammarousCheck' } " Grammar checking
Plug 'SirVer/ultisnips' " Easily create and use code/text snippets
Plug 'junegunn/vim-easy-align' " Easy align for (Markdown) tables
Plug 'tpope/vim-surround' " Easy add (ys) / change (cs) / remove (ds) surrounding characters/html tags
Plug 'chrisbra/Colorizer', { 'on' : 'ColorToggle' } " Highlight string colors
Plug 'junegunn/fzf', { 'dir' : '~/.fzf', 'do': './install --all' } " (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf.vim' " Vim bindings to FZF #awesome
Plug 'junegunn/vim-peekaboo' " Show registers
Plug 'AndrewRadev/linediff.vim' " Diffs lines in same file
Plug 'airblade/vim-rooter' " Automatically set de current dir to project root
Plug 'airblade/vim-gitgutter' " Show diffs in the sign column
Plug 'tpope/vim-fugitive' " Git commands plugin
Plug 'tpope/vim-eunuch' " Commands for easy unix file handling, Delete and Rename are my preferred
Plug 'vim-scripts/restore_view.vim' " saves and restores folds in text

" Programming language-related Plugins
Plug 'neoclide/coc.nvim', {'branch': 'release', 'for' : [ 'java', 'python', 'php', 'vim', 'ruby' ] } " Language Server Client
Plug 'udalov/kotlin-vim', { 'for': 'kotlin'  } " Kotlin syntax highlighting
Plug 'leafgarland/typescript-vim', {'for': 'typescript' } " TS syntax highlighting
Plug 'shmup/vim-sql-syntax'
Plug 'aloussase/gradle.vim' " Gradle
"Plug 'chrisbra/csv.vim'


Plug 'editorconfig/editorconfig-vim' " Use editor config files for formatting
" Other
Plug 'vimwiki/vimwiki' " Markdown wiki, this version use wikilinks. Change when issue closes https://github.com/vimwiki/vimwiki/issues/892
Plug 'michal-h21/vimwiki-sync' " Sync wiki to git repo at startup
Plug 'michal-h21/vim-zettel' " Zettelkasten support
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}


Plug 'lervag/vimtex', {'for': ['tex'] }

call plug#end()


" CoC-Vim
" -----------------------------------------------------

" Path for node.js
let g:coc_node_path = $HOME . '/.nvm/versions/node/v14.16.1/bin/node'

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


" Limelight
" ----------------------------------------------------
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 0

" Beginning/end of paragraph
let g:limelight_bop = '^\s*$'
let g:limelight_eop = '^\s*$'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1


" Grammarous
" -----------------------------------------------------
let g:grammarous#languagetool_cmd='java -jar $HOME/bin/LanguageTool-4.3/languagetool-commandline.jar'


" TagBar
"
" Uses markdown ctags type to overview vimwiki files
let g:tagbar_type_vimwiki = {
  \ 'ctagstype'	: 'markdown',
  \ 'kinds'		: [
    \ 'c:chapter:0:1',
    \ 's:section:0:1',
    \ 'S:subsection:0:1',
    \ 't:subsubsection:0:1',
    \ 'T:l4subsection:0:1',
    \ 'u:l5subsection:0:1',
  \ ],
  \ 'sro'			: '""',
  \ 'kind2scope'	: {
    \ 'c' : 'chapter',
    \ 's' : 'section',
    \ 'S' : 'subsection',
    \ 't' : 'subsubsection',
    \ 'T' : 'l4subsection',
  \ },
  \ 'scope2kind'	: {
    \ 'chapter' : 'c',
    \ 'section' : 's',
    \ 'subsection' : 'S',
    \ 'subsubsection' : 't',
    \ 'l4subsection' : 'T',
  \ },
\ }

" Vim-wiki
" ------------------------------------------------------
" does not consider all md files as wiki
let g:vimwiki_global_ext = 0
let g:vimwiki_tag_format = {'pre_mark': '#', 'post_mark': '[:space:]', 'sep': '#'}
let my_nested_syntaxes = {'java':'java', 'kotlin':'kotlin','php':'php', 'sql':'sql','javascript' : 'javascript', "python" : "python"}
"let g:vimwiki_tag_format = {'pre': '\(^[ -]*tags\s*:.*\)\@<=', 'pre_mark': '', 'post_mark': '', 'sep': '>><<'}

let personal_wiki = {}
let personal_wiki.path = '~/Zettelkasten/'
let personal_wiki.syntax = 'markdown'
let personal_wiki.ext = '.md'
let personal_wiki.nested_syntaxes = my_nested_syntaxes

let phd_wiki = {}
let phd_wiki.path = '~/git/lssb-writing/Projeto-Doc/wiki'
let phd_wiki.syntax = 'markdown'
let phd_wiki.ext = '.md'
let phd_wiki.nested_syntaxes = my_nested_syntaxes

let liber_wiki = {}
let liber_wiki.path = '~/Dropbox/Liber-PKM'
let liber_wiki.syntax = 'markdown'
let liber_wiki.ext = '.md'
let liber_wiki.nested_syntaxes = my_nested_syntaxes

" work-related wiki in work-related computer
if hostname() == 'tachikoma'
    let g:vimwiki_list = [
        \ liber_wiki,
        \ personal_wiki,
        \ phd_wiki
    \ ]
else
    let g:vimwiki_list = [
        \ personal_wiki,
        \ liber_wiki,
        \ phd_wiki
    \ ]

endif

" FZF
" ---------------------------------------------------
" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

function! VimwikiLinkHandler(link)
    if a:link =~ '\.\(pdf\|jpg\|jpeg\|png\|gif\)$'
        call vimwiki#base#open_link(':e ', 'file:'.a:link)
        return 1
    endif
    return 0
endfunction


" Markdown-Preview
" -----------------------------------------------------
function! OpenInSimpleBrowser(url)
    silent execute "!qutebrowser --target tab " . a:url . " &"
endfunction

let g:mkdp_browserfunc = 'OpenInSimpleBrowser'
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 1
" let g:mkdp_browser = 'qutebrowser --target tab'
" let g:mkdp_markdown_css = expand('~/node_modules/markdown-retro/css/retro.css')


" Vim-Rooter
" ------------------------------------------------------
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_patterns = ['latexmkrc', '=liberapi','.git/', 'pom.xml','=Zettelkasten','=src']

" Vimtex
" ------------------------------------------------------
let g:latex_view_general_viewer = 'zathura'
let g:vimtex_view_method = "zathura"

" Vim-Zettel
" -------------------------------------------------------
" {} represents first wiki
let g:zettel_options = [{"front_matter" : [["type","note"],["tags", ""], ]}]

" ULTISNIPS
" -------------------------------------------------------
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-space>"
let g:UltiSnipsJumpForwardTrigger="<c-space>"
let g:UltiSnipsJumpBackwardTrigger="<c-s-space>"
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
	" autocmd FileType tex :Goyo 80
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


function! VimwikiFindIncompleteTasks()
  lvimgrep /- \[ \]/ %:p
  lopen
endfunction

function! VimwikiFindAllIncompleteTasks()
  VimwikiSearch /- \[ \]/
  lopen
endfunction


" CONFIGS ------------------------------------------------------
set hidden " hides the buffer (instead of closing it) when a new file is loaded
" set autochdir	" Change working directory to the one of the open buffer
set encoding=utf-8 " all my systems uses UTF-8
set modelines=0 " Don't read the modelines (security)
set linebreak " break lines at words
set breakindent " maintain identation in line wrapping
set breakindentopt=shift:2,min:40,sbr " ident by an additional 2 characters on wrapped lines, when line >= 40 characters, put 'showbreak' at start of line

set spellsuggest=15 " keeps spell sugestions from taking over the whole screen

" Better splits
set splitbelow " by default, vim open split (:sp) in the top
set splitright " by default, vim open split (:vs) in the left

set tabstop=4 " number of spaces that a <tab> counts for, default 8
set softtabstop=4 " number of spaces that a <tab> counts for while editing
set expandtab " Create spaces instead of tabs
set shiftwidth=4 " number of spaces in (auto) indent, if 0 uses tabstop
set inccommand=nosplit " show :s/_/_/ live
set hlsearch " Show search matches while writing
set foldcolumn=2 " set 2 columns to show folders
set nobackup " do not create a backup file on save
set undodir=~/.vim/undodir " Directory for undo files
set undofile "

" fold text maintain first line identation
set foldtext=substitute(getline(v:foldstart),'\\s',repeat('\ ',1),'g').'...'.trim(getline(v:foldend))

" auto-reload file when changed extenaly
au CursorHold,CursorHoldI * :checktime
au FocusGained,BufEnter * :checktime


filetype on " enable filetype detection

" Spell highlight config ---------------------------------------
" http://vimdoc.sourceforge.net/htmldoc/syntax.html
" Using ANSI colors to match terminal XResources config
" TODO I think I don't need it anymore with my ~own~ colorscheme
function! CWLHighlights() abort
"	highlight clear SpellBad
"	highlight SpellBad ctermfg=7 ctermbg=1
"	" hi SpellBad cterm=reverse
"
"	highlight clear Search
"	highlight Search ctermfg=0 ctermbg=7
"
"	highlight clear IncSearch
"	highlight IncSearch ctermfg=0 ctermbg=15
endfunction

" TODO I think I don't need it anymore with my ~own~ colorscheme
augroup MyColors " auto reload my highlight scheme when colorscheme changes
    " Remove all auto-commands of this augroup
    autocmd!
    autocmd ColorScheme * call CWLHighlights()
augroup END
colorscheme default

" auto-switch line numbering on insert mode toggle
" autocmd InsertEnter * :set norelativenumber
" autocmd InsertLeave * :set relativenumber

" KEY MAPPINGS -----------------------------------------------------
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)


" ALL MODE MAPPINGS
" No arrow keys (Vim Hard mode)
" REMOVE ARROW COMPULSION
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Grammar checking
map <F5> :GrammarousCheck<cr>
" Remove grammar checking marks
map <F6> :GrammarousReset<cr>
" Add portuguese words to spell
map <F7> :set spelllang+=pt<cr>


" NORMAL MODE MAPPINGS

" Start interactive EasyAlign for a motion/text object (e.g., gaip)
nmap ga <Plug>(EasyAlign)

" reselects pasted text
nnoremap gp `[v`]

" Join with previous line (symmetric with J)
"nnoremap K kJ

" Keeps `search next occurrence` centered
nnoremap n nzzzv
nnoremap N Nzzzv

" Center the new line
nnoremap o o<esc>zzi
nnoremap O O<esc>zzi

" Makes Y behave like D and C, only yanking to the end of line
nnoremap Y y$


" remove search highlights
nnoremap <Esc><Esc> :noh<cr>

" Search buffers with FZF
nnoremap <leader>b :Buffers<cr>

" toggle matching highlight for color codes
nnoremap <leader>c :ColorToggle<cr>

" Search files with FZF + Vim-Rooter
nnoremap <leader>f :FZF<cr>
"
" Toggles Nerdtree navigation
nnoremap <leader>F :NERDTreeToggle<cr>

" Toggle limelight
nnoremap <leader>l :Limelight!!<cr>
xnoremap <leader>l :Limelight!!<cr>

" Toggles line number indication
nnoremap <leader>n :set number!<cr>

" Toggle file/class overeview panel
nnoremap <leader>o :TagbarToggle<cr>

" Filetype dependand preview
nnoremap <leader>p :call Preview()<cr>

" reload vi config
nnoremap <leader>r :source $MYVIMRC<cr>

" run current file contents
nnoremap <leader>R :!"%:p"

" Toggle spell checking
nnoremap <leader>s :call CWLToggleSpell()<cr>

" Toggle zen mode
nnoremap <leader>z :call CWLToggleZenMode()<cr>

" Tab control
noremap <leader>tt :tabnew<cr>
noremap <leader>tc :tabclose<cr>

" New Zettel
nnoremap <leader>Z :ZettelNew<space>

" Toggle undo history graph panel
nnoremap <leader>u :GundoToggle<cr>

" Switching Buffers
nnoremap <leader>[ :bp<cr>
nnoremap <leader>] :bn<cr>

nmap <leader>wa :call VimwikiFindAllIncompleteTasks()<CR>
nmap <leader>wx :call VimwikiFindIncompleteTasks()<CR>


" Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<cr>
nmap <silent> <c-j> :wincmd j<cr>
nmap <silent> <c-h> :wincmd h<cr>
nmap <silent> <c-l> :wincmd l<cr>


" VISUAL MODE MAPPINGS

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" move selected lines down
vnoremap J :m '>+1<CR>gv=gv
" move selected lines up
vnoremap K :m '<-2<CR>gv=gv

" INSERT MODE MAPPINGS

" Insert undo break points at punctuations
inoremap <cr> <cr><c-g>u
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap : :<c-g>u
inoremap / /<c-g>u
"inoremap ( (<c-g>u
"inoremap ) )<c-g>u
"inoremap { {<c-g>u
"inoremap } }<c-g>u


" ------------------------------------------------------------
" Set my Neovim v0.2.2-derived colorscheme (XResources-based)
colorscheme neovim-0-2-2





augroup vimrc_trim_trailing
    autocmd!
    "                                     mark position
    "                                        |    Remove trailings
    "                                        |    \             /  Return to position
    "                                        |     \           /         |
    autocmd BufWritePre * :execute "normal! mz" . ':%s/\s\+$//e'. "\<cr>`z"
augroup END
