"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible
set background=dark

filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'git://github.com/jlanzarotta/bufexplorer.git'
Plugin 'git://github.com/Raimondi/delimitMate.git'
Plugin 'git://github.com/easymotion/vim-easymotion.git'
Plugin 'git://github.com/tpope/vim-fugitive.git'
Plugin 'git://github.com/sjl/gundo.vim.git'
Plugin 'git://github.com/henrik/vim-indexed-search.git'
Plugin 'git://github.com/davidhalter/jedi-vim.git'
Plugin 'git://github.com/Shougo/neocomplete.vim.git'
Plugin 'git://github.com/scrooloose/nerdtree.git'
Plugin 'git://github.com/tpope/vim-surround.git'
Plugin 'git://github.com/scrooloose/syntastic.git'
Plugin 'git://github.com/vim-airline/vim-airline.git'
Plugin 'git://github.com/osyo-manga/vim-over.git'
Plugin 'git://github.com/mhinz/vim-startify.git'
call vundle#end()            " required
filetype plugin indent on    " required

colorscheme papercolors
set guifont=PragmataPro\ 12

"allow backspacing over everything in insert mode
"set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000
set spelllang =en,de

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom
set hlsearch
set ignorecase
set showmatch
set number      "show line numbers
set incsearch   "find the next match as we type the search
set lz "lazy screen redraw an running scripts

"display tabs and trailing spaces
"set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set wrap        "dont wrap lines
set linebreak   "wrap lines at convenient points

if v:version >= 703
    "undo settings
    set undodir=~/.undofiles
    set undofile

    set colorcolumn=81 "mark the ideal max text width
    let s:color_column_old = 0
endif

"default indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smarttab

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"tell the term has 256 colors/uncomment if u want use csapprox
set t_Co=256

"hide buffers when not displayed
set hidden

set laststatus=2

set statusline=%!SetStatusline()

function! SetStatusline()
  " let stl = ' %4*%<%f%*'
  let stl = ' %<%f'

  if exists('b:git_dir')
    let stl    .= '%3*:%*'
    let branch  = fugitive#head(8)
    let stl    .= (branch == 'master') ? '%1*master%*' : '%2*'. branch .'%*'
    let stl    .= mhi#sy_stats_wrapper()
  endif

  let stl .=
        \   '%m%r%h%w'
        \ . '%= '
        \ . '%#ErrorMsg#%{&paste ? " paste " : ""}%*'
        \ . '%#WarningMsg#%{&ff != "unix" ? " ".&ff." ":""}%* '
        \ . '%#warningmsg#%{&fenc != "utf-8" && &fenc != "" ? " ".&fenc." " :""}%* '

  if get(b:, 'stl_highlight')
    let id = synID(line('.'), col('.'), 1)
    let stl .=
          \   '%#WarningMsg#['
          \ . '%{synIDattr('.id.',"name")} as '
          \ . '%{synIDattr(synIDtrans('.id.'),"name")}'
          \ . ']%* '
  endif

  if get(b:, 'stl_location', 1)
    let stl .=
          \   '%3*[%*%v%3*,%*%l%3*/%*%L%3*]%* '
          \ . '%p%3*%%%* '
  endif

  return stl
endfunction


"syntastic statusline
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Plugin: surround {{{2
let g:surround_indent = 1
let g:surround_{char2nr('k')} = "<kbd>\r</kbd>""}}


let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"source project specific config files
runtime! projects/**/*.vim

"make Y consistent with C and D
nnoremap Y y$

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"spell check when writing commit logs
autocmd filetype svn,*commit* setlocal spell

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40

"explorer mappings
nnoremap <f2> :NERDTreeToggle<cr>

" F3 - быстрое сохранение
nmap <F3> :w<cr>
vmap <F3> <esc>:w<cr>i
imap <F3> <esc>:w<cr>i

" F4 - просмотр ошибок
nmap <F4> :copen<cr>
vmap <F4> <esc>:copen<cr>
imap <F4> <esc>:copen<cr>

" " F5 - просмотр списка буферов
nmap <F5> <Esc>:BufExplorer<cr>
vmap <F5> <esc>:BufExplorer<cr>
imap <F5> <esc><esc>:BufExplorer<cr>

" F6 - обозреватель файлов
map <F6> :Ex<cr>
vmap <F6> <esc>:Ex<cr>i
imap <F6> <esc>:Ex<cr>i

" F8 - список закладок
map <F8> :MarksBrowser<cr>
vmap <F8> <esc>:MarksBrowser<cr>
imap <F8> <esc>:MarksBrowser<cr>

" F9 - "make" команда
map <F9> :make<cr>
vmap <F9> <esc>:make<cr>i
imap <F9> <esc>:make<cr>i

" F10 - удалить буфер
map <F10> :bd<cr>
vmap <F10> <esc>:bd<cr>
imap <F10> <esc>:bd<cr>

" F11 - показать окно Taglist
map <F11> :TlistToggle<cr>
vmap <F11> <esc>:TlistToggle<cr>
imap <F11> <esc>:TlistToggle<cr>

let g:bufExplorerOpenMode=1
let g:bufExplorerSortBy='mru'
let g:bufExplorerSplitType='v'
let g:bufExplorerSplitVertSize = 40
let g:bufExplorerShowDirectories=1

" Слова откуда будем завершать
set complete=""
" Из текущего буфера
set complete+=.
" Из словаря
set complete+=k
" Из других открытых буферов
set complete+=b
" из тегов
set complete+=t

"start neocomplete
let g:neocomplete#enable_at_startup = 1
