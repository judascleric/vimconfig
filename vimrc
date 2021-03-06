"RJL - vim config file

"Commonly forgotten keyboard shortcuts
"gq - wrap text at textwidth, cursor to the end of line vmode, use motion in n
"gw - wrap text at textwidth, restore cursor vmode. use motion in nmode ie ap
"J - join lines nmode must be >1 line
"]s - go to next spelling issue
"z= - spelling suggestions
":j<return> - join lines in vmode(using command mode) good for >=1 line
":vimgrep /{search}/gj %:p:h/**/*.cpp - search for *.cpp files recursively in the current directory
":cw - open quicklist (after vimgrep) - can append to vimgrep command with " | cw"
":cex[] - clear the quickfix window
":cn - next match in the quickfix window
":cp - previous match in the quickfix window
":ccl - close the quickfix window
"Ctrl-w gf  - jump to a file under the cursor in quicklist (or any file under the cursor)
"Ctrl-] - jump to a tag under the cursor, useful in help docs in terminal
"=% - reformat block
"{Visual Select}= - reformat selection

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

"file encoding
"set utf-8 as default encoding
set encoding=utf-8
set fileencodings=ucs-bom,uft-8ucs-2le,latin1

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

"custom functions - should these go in a separate .vim file?
"SearchInFiles is a smart vimgrep invocation. Intended use is to select text in
" visual mode and search recursively from the current file directory in all files
" with the same file extension
"Arguments:
" firstFile - path to start search from. typically expand('%:p')
" searchText - the regular expression to search for, does not smartly escape
"  characters from a visual mode select
" Returns:
"  nothing, but the quick list will be populated with the search results
fun! SearchInFiles(firstFile, searchText)
	let parentDir = fnamemodify(a:firstFile, ':p:h')
	let fileFilter = parentDir . '/**'
	let fileExtension = fnamemodify(a:firstFile, ':e')
	if !empty(fileExtension)
		let fileFilter .= '*.' . fileExtension 
	endif
	let vimgrepCmd = ':vimgrep /' . a:searchText . '/gj ' . fileFilter
	execute vimgrepCmd
endfun

fun! SetP4Client()
    let hostname = split(system("hostname"))[0]
    let p4clientsOut = system("p4 clients -u %P4USER%")
    let p4clientsOutLines = split(p4clientsOut, "\n")
    let p4clientList = []
    let idx = 1
    for p4clientsOutLine in p4clientsOutLines
        " only add clients usable on this host
        let p4client = split(p4clientsOutLine)[1]
        let p4clientOut = system("p4 client -o " . p4client)
        let p4clientOutLines = split(p4clientOut, "\n")
        for p4clientOutLine in p4clientOutLines
            let hostLine = matchstr(p4clientOutLine, "^Host:.*")
            if !empty(hostLine)
                let clientHost = split(hostLine)[1]
                " do we need to save ignorecase state?
                set ignorecase
                if clientHost == hostname
                    call add(p4clientList, p4client)
                    let idx = idx + 1
                endif
            endif
        endfor
    endfor
    if len(p4clientList) > 0
        let choices = "&" . join(p4clientList, "\n&")
        let choice = confirm("Choose a P4 Client", choices)
        let $P4CLIENT = p4clientList[choice-1]
    else
        echom "No Clients Found"
    endif
endfun

"Key remappings
if MySys() == "windows"
    "get windows keybindings for copy, paste, save
    source $vimruntime/mswin.vim
endif
let mapleader = ","
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
nmap sp o{<return>}<esc>Pk=%%
nmap sP O{<return>}<esc>Pk=%%
"reformat c-style "//" comments starting on the first line. Doesn't work for text
":j<return> = join visual selection, ^wi<space><space><esc> = indent 2 lines
"Vgw = select the line and reformat, <S-x><S-x> = delete the trailing space
vmap gc :j<return>^wi<space><space><esc>Vgw<S-x><S-x>
"toggle nerdtree file browser
nmap <Leader>f :NERDTreeToggle<CR>
"open file browser in the parent directory of the currently opened file
nnoremap <Leader>od :tabe %:p:h<CR>
"open file in directory of the currently opened file [partial commnand]
nmap <Leader>t :tabe %:p:h/
"move current tab to the first tab
nmap <Leader>1 :tabm 0<CR>
"move current tab to {n} position [partial command]
nmap <Leader>m :tabm 
"prep a recursive search from the highlighted word in vmode, you can then
" tack on a file extension filter and open the quicklist
vmap <Leader>g y:vimgrep /<C-r>"/gj %:p:h/** \| cw
"do a recursive search for the highlighted word in vmode, open quicklist
vmap <Leader>s y:call SearchInFiles(expand('%:p'),expand('<C-r>"'))<CR>:cw<CR>
"do a search for the highlighted word in current file, open quicklist
vmap <Leader>f y:vimgrep /<C-r>"/gj %:p<CR>:cw<CR>
"next search result from quicklist
nmap <F3> :cn<CR>
"previous search result from quicklist
nmap <S-F3> :cp<CR>
"close the quickfix window
nmap <Leader>q :ccl<CR>
"jump to file under the cursor in a new tab, typically done from quicklist
nmap <Leader>j <C-w>gf
"close current tab/window
nmap <Leader>c :clo<CR>
"perforce commands
nmap <Leader>pe :!p4 edit %<CR>
nmap <Leader>pa :!p4 add %<CR>
nmap <Leader>pr :!p4 revert %<CR>
nmap <Leader>pc :call SetP4Client()<CR>
"toggle visible whitespace
nmap <Leader>l :set list!<CR>

"tab preferences
"wrap width
set textwidth=80
set softtabstop=4
set shiftwidth=4
set tabstop=4
set expandtab "convert tabs to spaces
"set noexpandtab "do not convert tabs to spaces
set nosmartindent "smartindent lacks configuration options to control special indentation and preprocessor and comment configuration
set cindent "add extra indent for statements that continue on the same line
set cinkeys-=0# "do not remove indentation for # on preprocessor commands and comments
set indentkeys-=0# "do not remove indentation for # on preprocessor commands and comments
set wrap "wrap lines - is there a way to add a visual character in the margin when a wrap occurs?
set autoindent "indent at the start of new blocks

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
map <Leader>cc      <plug>NERDCommenterComment 
map <Leader>c<space> <plug>NERDCommenterToggle 
map <Leader>cm      <plug>NERDCommenterMinimal 
map <Leader>cs      <plug>NERDCommenterSexy 
map <Leader>ci      <plug>NERDCommenterInvert 
map <Leader>cy      <plug>NERDCommenterYank 
map <Leader>cl      <plug>NERDCommenterAlignLeft 
map <Leader>cb      <plug>NERDCommenterAlignBoth 
map <Leader>cn      <plug>NERDCommenterNest 
map <Leader>cu      <plug>NERDCommenterUncomment 
map <Leader>c$      <plug>NERDCommenterToEOL 
map <Leader>cA      <plug>NERDCommenterAppend 

