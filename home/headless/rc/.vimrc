" .vimrc for VSCodeVim (vim.vimrc.path) and ~/.ideavimrc

" Leader
let mapleader = ' '
let maplocalleader = ' '

" Plugin globals
let g:tex_flavor  = 'latex'
let g:tex_conceal = 'abdmgs'
let g:airline_powerline_fonts = 1
let g:livepreview_previewer = 'zathura'
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_method = 'latexrun'

" Display
set number
set relativenumber
set cursorline
" set noshowmode
set signcolumn=yes
set scrolloff=10
set splitright
set splitbelow
set conceallevel=2
set showmatch
set ttyfast
set cc=80

" Spell
set spell
set spelllang=pl

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Indentation and whitespace
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set breakindent
set list
set listchars=tab:»\ ,trail:·,nbsp:␣

" Editing behaviour
set mouse=
set clipboard=unnamedplus
set undofile
set confirm
set wildmode=longest,list

" Backups
set backup
set backupcopy=yes
set backupdir=~/.vim/backup/
set writebackup

" Encoding
scriptencoding utf-8

" Timing
set updatetime=250
set timeoutlen=300

" Filetype
filetype plugin indent on

" Keymaps
nnoremap <Esc>		:nohlsearch<CR>
nnoremap <left>		:echo "Use h to move!!"<CR>
nnoremap <right>	:echo "Use l to move!!"<CR>
nnoremap <up>		:echo "Use k to move!!"<CR>
nnoremap <down>		:echo "Use j to move!!"<CR>
nnoremap <C-h>		<C-w><C-h>
nnoremap <C-l>		<C-w><C-l>
nnoremap <C-j>		<C-w><C-j>
nnoremap <C-k>		<C-w><C-k>

