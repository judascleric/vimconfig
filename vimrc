"RJL - vim config file

"Commonly forgotten keyboard shortcuts
"gq - wrap text at textwidth, cursor to the end of line vmode, use motion in n
"gw - wrap text at textwidth, restore cursor vmode. use motion in nmode ie ap
"J - join lines nmode must be >1 line
"]s - go to next spelling issue
"z= - spelling suggestions
":j<return> - join lines in vmode(using command mode) good for >=1 line
"Ctrl-] - jump to a tag under the cursor, useful in help docs in terminal

"vim only
set nocompatible

"close buffers when tabs/windows are closed
set nohidden
set showcmd
"change default new window/new buffer split behavior to below or right instead
"of above or left
set splitbelow
set splitright

"pluging configuration
execute pathogen#infect()
filetype on
filetype plugin on
filetype plugin indent on

"auto reload .vimrc whe it is edited
try
	if MySys() == "windows"
		autocmd! bufwritepost vimrc source ~/_vimrc
	else
		autocmd! bufwritepost vimrc source ~/.vimrc
	endif
catch
endtry

"prompt to reload files when modified outisde of vim
"there are other options besides CursorHold, but that provides pretty
"reasonable frequency. It is triggered whenever the cursor is inactive for 4
"seconds. That seems pretty reasonable when you are editing in another
"program or syncing to source control
autocmd! CursorHold * checktime

"set autoformatting options
set formatoptions=
"do not automatically wrap text
set formatoptions-=t
"do not automatically wrap comments
set formatoptions-=c
"do not automatically prepend comment leader on <return>
set formatoptions-=r
"do not automatically prepend comment leader on o/O
set formatoptions-=o
"allow gq to reformat 
set formatoptions+=q
"do not break long lines in insert mode
set formatoptions+=l
"remove comment leader when joining lines
set formatoptions+=j
"preserve indentation of 2nd line for the remainder of paragraph
set formatoptions+=2

"configure status line
set statusline=%f       "tail of the filename
set statusline+=\ %y      "filetype
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%=      "left/right separator
set statusline+=%l:%c[%L]   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"Key remappings
inoremap <Esc> <Esc>`^
vnoremap <Esc> <Esc>gV
"visual search - use // to find the currently highlighted text
vmap // y/<C-R>"<CR><Esc>
"disable highlighting easily
nmap <silent> // :noh<CR>
"generate ctags for browsing/auto-complete for the site-packages in python -
"how to do this for specific languages? is there something like a project file
"for generating relevant tags?
map <S-F11> :exe '!ctags -R -f ' . expand("~/vim_local/tags/python.tags") . ' ' . system('python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"')<CR>
inoremap # X#
"search starts with case insensitive flag. This gives ignorecase like behavior
"without breaking case sensitivity of other commands
nnoremap / /\c
"s is normally a substitution command, similar to d or x, I don't use it and
"it's a really conveinient key on home row so let's use it for creating blocks
"in cpp!
nmap <silent> s <NOP>
nmap <silent> S <NOP>
nmap ss o{<return>}<esc>O
nmap sS O{<return>}<esc>O 
nmap s; o{<return>};<esc>O
nmap sp o{<esc>po}<esc>
nmap sP O{<esc>po}<esc>
"reformat c-style "//" comments starting on the first line. Doesn't work for text
":j<return> = join visual selection, ^wi<space><space><esc> = indent 2 lines
"Vgw = select the line and reformat, <S-x><S-x> = delete the trailing space
vmap gc :j<return>^wi<space><space><esc>Vgw<S-x><S-x>
nmap ,f :NERDTreeToggle<CR>
nnoremap ,od :tabe %:p:h<CR>
nmap ,t :tabe %:p:h/

"tab preferences
"wrap width
set textwidth=80
set softtabstop=2
set shiftwidth=2
set tabstop=2
set noexpandtab "do not convert tabs to spaces
set autoindent "auto indent
set smartindent "smart indent
set wrap "wrap lines - is there a way to add a visual character in the margin when a wrap occurs?

"general editor setting
"set term=builtin_ansi "this should fix the arrow keys in terminal vim
set ruler "Always show current position
syntax enable "syntax highlighting
set listchars=tab:?�,trail:�,eol:�,precedes:�,extends:�,nbsp:� ",conceal:? :conceal doesn't seem to work without ':set conceallevel=1"
set linebreak "break at whitespace boundaries instead of in the middle of words
set number "display line numbers

"searching
set hlsearch "highlight all matching search patterns
set incsearch "incremental search. goto while typing
set showmatch "show matching brackets when cursor is over the other
set mat=2 "not sure... something about 1/10ths of milliseconds to blink search result

"disable backup, it messes with source control
set nobackup
set nowb
set noswapfile

"persistent undo... not sure what this does exactly. but looks userful
try
	if MySys() == "windows"
		set undodir=expand("$TEMP") "I'm not sure this is what we wnat. what about %temp%? That defaults to the user directory on secure windows like Vista and Win7
	else
		set undodir=~/.vim_runtime/undodir
	endif

	set undofile
catch
endtry

"text file options
"enable spell checking in text files
"not sure why other "autocmd! FileType text" blows away the previous seems fine for other autocmds
"formatoptions+=n - recognize numbered lists
"formatoptions+=r - automatically add comment leader on return
"comments+=nfO:* - defines * as a comment to assist in formatting bulleted lists
autocmd! FileType text setlocal spell spelllang=en_us formatoptions+=nr comments+=nfO:*
" I tried using this comment formatting to get bulleted lists that automatically
" indent subsequent lines but on actually hitting a carriage return will start a
" new bulleted item. doesn't work.
"autocmd! FileType text setlocal spell spelllang=en_us formatoptions+=nr comments+=sl:*,mb:\ ,ex-2:\ \n

"c/cpp file options
"enable semantically intelligent indenting for c/cpp
autocmd! FileType c,cpp setlocal cindent
"case statements with switch, indent next line
autocmd! FileType c,cpp setlocal cinoptions=:0,=1s
"scope statements with class/struct, indent next line
autocmd! FileType c,cpp setlocal cinoptions+=g0,h1s

"in MacVim, start text zoomed
if MySys() == "macosx"
	set guifont=Menlo\ Regular:h18
	autocmd! VimEnter * if exists(":macaction") | exe ":macaction performZoom:" | endif
endif

"confiure NERDCommenter
let NERDCreateDefaultMappings=0
map ,cc      <plug>NERDCommenterComment 
map ,c<space> <plug>NERDCommenterToggle 
map ,cm      <plug>NERDCommenterMinimal 
map ,cs      <plug>NERDCommenterSexy 
map ,ci      <plug>NERDCommenterInvert 
map ,cy      <plug>NERDCommenterYank 
map ,cl      <plug>NERDCommenterAlignLeft 
map ,cb      <plug>NERDCommenterAlignBoth 
map ,cn      <plug>NERDCommenterNest 
map ,cu      <plug>NERDCommenterUncomment 
map ,c$      <plug>NERDCommenterToEOL 
map ,cA      <plug>NERDCommenterAppend 
