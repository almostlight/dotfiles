""vim user config 

scriptencoding utf-8
"let g:python3_host_prog = '/Library/Frameworks/Python.framework/Versions/3.13/bin/python3'
"export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
imap jk <Esc>
imap kj <Esc>

"" automatic backups
set backup 
set backupdir=~/.vim/backup/
set writebackup
set backupcopy=yes

set number
set relativenumber
syntax on
"setlocal spell spelllang=pl
"setlocal spell spelllang=en_gb
"set background=dark
colorscheme deus   
"set clipboard=unnamedplus 
set encoding=utf-8
let g:airline_powerline_fonts = 1  
"" vimtex config 
let maplocalleader = "\\"
filetype plugin indent on 
let g:livepreview_previewer = 'zathura'
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_method = 'latexrun'


"open new split panes to right and below
set splitright
set splitbelow

"general config 
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
"set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set an 80 column border for good coding style
"set mouse=a                 " enable mouse click
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set noswapfile            " disable creating swap file


"Remap keys 
"Move line or visually selected block - alt+j/k
"inoremap <A-j> <Esc>:m .+1<CR>==gi
"inoremap <A-k> <Esc>:m .-2<CR>==gi
"vnoremap <A-j> :m '>+1<CR>gv=gv
"vnoremap <A-k> :m '<-2<CR>gv=gv" move split panes to left/bottom/top/right
" nnoremap <A-h> <C-W>H
" nnoremap <A-j> <C-W>J
" nnoremap <A-k> <C-W>K
" nnoremap <A-l> <C-W>L" move between panes to left/bottom/top/right
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l


" active plugins 
"if !has('nvim')
        call plug#begin() 
        Plug 'dracula/vim'  
        Plug 'morhetz/gruvbox'
        Plug 'honza/vim-snippets'
        Plug 'scrooloose/nerdtree'
        Plug 'preservim/nerdcommenter'
        Plug 'mhinz/vim-startify'
"        Plug 'lervag/vimtex'
        Plug 'neoclide/coc.nvim', {'branch': 'release'} 
    call plug#end()
"endif

