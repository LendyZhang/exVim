"/////////////////////////////////////////////////////////////////////////////
" basic
"/////////////////////////////////////////////////////////////////////////////

set nocompatible " be iMproved, required

if !has('gui_running') && $TERM_PROGRAM != 'Apple_Terminal'
    set termguicolors
endif

function! OSX()
    return has('macunix')
endfunction
function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
function! WINDOWS()
    return  (has('win16') || has('win32') || has('win64'))
endfunction

" On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
" across (heterogeneous) systems easier.
if !exists('g:exvim_custom_path')
    if WINDOWS()
        set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
    endif
endif

"/////////////////////////////////////////////////////////////////////////////
" language and encoding setup
"/////////////////////////////////////////////////////////////////////////////

" always use English menu
" NOTE: this must before filetype off, otherwise it won't work
set langmenu=none

" use English for anaything in vim-editor.
if WINDOWS()
    silent exec 'language english'
elseif OSX()
    silent exec 'language en_US'
else
    let s:uname = system("uname -s")
    if s:uname == "Darwin\n"
        " in mac-terminal
        silent exec 'language en_US'
    else
        " in linux-terminal
        silent exec 'language en_US.utf8'
        set visualbell t_vb=
    endif
endif

" try to set encoding to utf-8
if WINDOWS()
    " Be nice and check for multi_byte even if the config requires
    " multi_byte support most of the time
    if has('multi_byte')
        " Windows cmd.exe still uses cp850. If Windows ever moved to
        " Powershell as the primary terminal, this would be utf-8
        set termencoding=cp850
        " Let Vim use utf-8 internally, because many scripts require this
        set encoding=utf-8
        setglobal fileencoding=utf-8
        " Windows has traditionally used cp1252, so it's probably wise to
        " fallback into cp1252 instead of eg. iso-8859-15.
        " Newer Windows files might contain utf-8 or utf-16 LE so we might
        " want to try them first.
        set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
    endif

else
    " set default encoding to utf-8
    set encoding=utf-8
    set termencoding=utf-8
endif
scriptencoding utf-8

"/////////////////////////////////////////////////////////////////////////////
" Bundle setup
"/////////////////////////////////////////////////////////////////////////////

" vundle#begin
" filetype off " required

" set the runtime path to include Vundle
if exists('g:exvim_custom_path')
    let g:ex_tools_path = g:exvim_custom_path.'/vimfiles/tools/'
    exec 'set rtp+=' . fnameescape( g:exvim_custom_path.'/vimfiles' )
    call plug#begin(g:exvim_custom_path.'/vimfiles/bundle/')
else
    let g:ex_tools_path = '~/.vim/tools/'
    call plug#begin('~/.vim/bundle/')
endif

" load .vimrc.plugins & .vimrc.plugins.local
if exists('g:exvim_custom_path')
    let vimrc_plugins_path = g:exvim_custom_path.'/.vimrc.plugins'
    let vimrc_plugins_local_path = g:exvim_custom_path.'/.vimrc.plugins.local'
else
    let vimrc_plugins_path = '~/.vimrc.plugins'
    let vimrc_plugins_local_path = '~/.vimrc.plugins.local'
endif
if filereadable(expand(vimrc_plugins_path))
    exec 'source ' . fnameescape(vimrc_plugins_path)
endif
if filereadable(expand(vimrc_plugins_local_path))
    exec 'source ' . fnameescape(vimrc_plugins_local_path)
endif

call plug#end()

" vundle#end
" filetype plugin indent on " required
" syntax on " required

"/////////////////////////////////////////////////////////////////////////////
" Default colorscheme setup
"/////////////////////////////////////////////////////////////////////////////

if has('gui_running')
    set background=dark
else
    set background=dark
    set t_Co=256 " make sure our terminal use 256 color
    let g:solarized_termcolors = 256
endif
" colorscheme solarized
" colorscheme exlightgray
" colorscheme gruvbox
colorscheme one

hi LineNr guibg=#2c323c
hi SignColumn guibg=#2c323c
hi VertSplit guifg=#151515 guibg=#151515
hi CocHighlightText guibg=#4b5263

hi link LspCxxHlGroupEnumConstant Constant
hi link LspCxxHlGroupNamespace Type
hi link LspCxxHlGroupMemberVariable Identifier

"/////////////////////////////////////////////////////////////////////////////
" General
"/////////////////////////////////////////////////////////////////////////////

"set path=.,/usr/include/*,, " where gf, ^Wf, :find will search
set backup " make backup file and leave it around

" setup back and swap directory
let data_dir = $HOME.'/.data/'
let backup_dir = data_dir . 'backup'
let swap_dir = data_dir . 'swap'
if finddir(data_dir) == ''
    silent call mkdir(data_dir)
endif
if finddir(backup_dir) == ''
    silent call mkdir(backup_dir)
endif
if finddir(swap_dir) == ''
    silent call mkdir(swap_dir)
endif
unlet backup_dir
unlet swap_dir
unlet data_dir

set backupdir=$HOME/.data/backup " where to put backup file
set directory=$HOME/.data/swap " where to put swap file

" Redefine the shell redirection operator to receive both the stderr messages and stdout messages
set shellredir=>%s\ 2>&1
set history=50 " keep 50 lines of command line history
set updatetime=300 " default = 4000
set autoread " auto read same-file change ( better for vc/vim change )
set maxmempattern=1000 " enlarge maxmempattern from 1000 to ... (2000000 will give it without limit)

"/////////////////////////////////////////////////////////////////////////////
" xterm settings
"/////////////////////////////////////////////////////////////////////////////

behave xterm  " set mouse behavior as xterm
if exists('+mouse') " &term =~ 'xterm'
    set mouse=a
endif

"/////////////////////////////////////////////////////////////////////////////
" Variable settings ( set all )
"/////////////////////////////////////////////////////////////////////////////

" ------------------------------------------------------------------
" Desc: Visual
" ------------------------------------------------------------------

set matchtime=0 " 0 second to show the matching paren ( much faster )
set nu " show line number
set scrolloff=3 " minimal number of screen lines to keep above and below the cursor
set nowrap " do not wrap text

" only supoort in 7.3 or higher
if v:version >= 703
    set noacd " no autochchdir
endif

" set default guifont
if has('gui_running') && (WINDOWS() || OSX() || has('gui_gtk2') || has('gui_gtk3')) && (exists('+guifont') && &guifont == "")
    augroup ex_gui_font
        " check and determine the gui font after GUIEnter.
        " NOTE: getfontname function only works after GUIEnter.
        au!
        au GUIEnter * call s:set_gui_font()
    augroup END

    " set guifont
    function! s:set_gui_font()
        if WINDOWS()
            let font_descs = [
                \['JetBrainsMono NF',                9, 2],
                \['InconsolataGo NF',               10, 2],
                \['Consolas NF',                    10, 2],
                \['Inconsolata for Powerline',      10, 2],
                \['Inconsolata',                    10, 2],
                \['DejaVu Sans Mono for Powerline',  9, 2],
                \['DejaVu Sans Mono',                9, 2],
                \['Consolas'                        10, 2]
            \]
        elseif OSX()
            let font_descs = [
                \['JetBrainsMono Nerd Font',        12, 2],
                \['JetBrainsMono Nerd Font Mono',   12, 2],
                \['InconsolataGo Nerd Font',        14, 2],
                \['InconsolataGo Nerd Font Mono',   14, 2],
                \['Inconsolata for Powerline',      14, 2],
                \['Inconsolata',                    14, 2],
                \['DejaVu Sans Mono for Powerline', 12, 2],
                \['DejaVu Sans Mono',               12, 2],
                \['Monokai',                        12, 2]
            \]
        else
            let font_descs = [
                \['JetBrainsMono Nerd Font',         9, 2],
                \['JetBrainsMono Nerd Font Mono',    9, 2],
                \['InconsolataGo Nerd Font',        10, 2],
                \['InconsolataGo Nerd Font Mono',   10, 2],
                \['Inconsolata for Powerline',      10, 2],
                \['Inconsolata',                    10, 2],
                \['DejaVu Sans Mono for Powerline',  9, 2],
                \['DejaVu Sans Mono',                9, 2],
                \['Monospace',                       9, 2]
            \]
        endif

        for [font_name, font_size, line_space] in font_descs
            if getfontname(font_name) != ''
                let font_setting = font_name
                if has('gui_gtk2') || has('gui_gtk3')
                    let font_setting .= ' ' . font_size
                else
                    let font_setting .= ':h' . font_size
                endif

                let &guifont = font_setting
                let &linespace = line_space
                break
            endif
        endfor
    endfunction
endif

" ------------------------------------------------------------------
" Desc: Vim UI
" ------------------------------------------------------------------

set wildmenu " turn on wild menu, try typing :h and press <Tab>
set showcmd " display incomplete commands
set cmdheight=1 " 1 screen lines to use for the command-line
set ruler " show the cursor position all the time
set hidden " allow to change buffer without saving
set shortmess=aoOtTI " shortens messages to avoid 'press a key' prompt
set lazyredraw " do not redraw while executing macros (much faster)
set display+=lastline " for easy browse last line with wrap text
set laststatus=2 " always have status-line
set titlestring=%t\ (%{expand(\"%:p:.:h\")}/)
set cursorline
set numberwidth=6

" set window size (if it's GUI)
if has('gui_running') && !has('gui_vimr')
    " set window's width to 130 columns and height to 40 rows
    if exists('+lines')
        set lines=128
    endif
    if exists('+columns')
        set columns=256
    endif
endif

set showfulltag " show tag with function protype.
set guioptions+=b " present the bottom scrollbar when the longest visible line exceed the window

" disable menu & toolbar
set guioptions-=m
set guioptions-=T

" ------------------------------------------------------------------
" Desc: Text edit
" ------------------------------------------------------------------

set ai " autoindent
set si " smartindent
set backspace=indent,eol,start " allow backspacing over everything in insert mode
" indent options
" see help cinoptions-values for more details
set	cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,l0,b0,g0,hs,ps,ts,is,+s,c3,C0,0,(0,us,U0,w0,W0,m0,j0,)20,*30
" default '0{,0},0),:,0#,!^F,o,O,e' disable 0# for not ident preprocess
" set cinkeys=0{,0},0),:,!^F,o,O,e

" official diff settings
set diffexpr=g:MyDiff()
function! g:MyDiff()
    let opt = '-a --binary -w '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    silent execute '!' .  'diff ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
endfunction

set cindent shiftwidth=4 " set cindent on to autoinent when editing c/c++ file, with 4 shift width
set tabstop=4 " set tabstop to 4 characters
set noexpandtab " set expandtab on, the tab will be change to space automaticaly
set ve=block " in visual block mode, cursor can be positioned where there is no actual character

" set Number format to null(default is octal) , when press CTRL-A on number
" like 007, it would not become 010
set nf=

" ------------------------------------------------------------------
" Desc: Fold text
" ------------------------------------------------------------------

set foldmethod=marker foldmarker={,} foldlevel=9999
set diffopt=filler,context:9999

" ------------------------------------------------------------------
" Desc: Search
" ------------------------------------------------------------------

set showmatch " show matching paren
set incsearch " do incremental searching
set hlsearch " highlight search terms
set ignorecase " set search/replace pattern to ignore case
set smartcase " set smartcase mode on, If there is upper case character in the search patern, the 'ignorecase' option will be override.

" set this to use id-utils for global search
set grepprg=lid\ -Rgrep\ -s
set grepformat=%f:%l:%m

"/////////////////////////////////////////////////////////////////////////////
" Auto Command
"/////////////////////////////////////////////////////////////////////////////

" ------------------------------------------------------------------
" Desc: Only do this part when compiled with support for autocommands.
" ------------------------------------------------------------------

if has('autocmd')
    augroup ex
        au!

        " when editing a file, always jump to the last known cursor position.
        " don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        au BufReadPost *
                    \ if line("'\"") > 0 && line("'\"") <= line("$") |
                    \   exe "normal g`\"" |
                    \ endif
        au BufNewFile,BufEnter * set cpoptions+=d " NOTE: ctags find the tags file from the current path instead of the path of currect file
        au BufEnter * :syntax sync fromstart " ensure every file does syntax highlighting (full)
        au BufNewFile,BufRead *.avs set syntax=avs " for avs syntax file.

        " DISABLE {
        " NOTE: will have problem with exvim, because exvim use exES_CWD as working directory for tag and other thing
        " Change current directory to the file of the buffer ( from Script#65"CD.vim"
        " au   BufEnter *   execute ":lcd " . expand("%:p:h")
        " } DISABLE end

        au FileType text setlocal textwidth=78 " for all text files set 'textwidth' to 78 characters.
        au FileType c,cpp,cs,swig set nomodeline " this will avoid bug in my project with namespace ex, the vim will tree ex:: as modeline.

        " disable auto-comment for c/cpp, lua, javascript, c# and vim-script
        au FileType c,cpp,java,javascript set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f://
        au FileType cs set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f:///,f://
        au FileType vim set comments=sO:\"\ -,mO:\"\ \ ,eO:\"\",f:\"
        au FileType lua set comments=f:--

    augroup END
endif

"/////////////////////////////////////////////////////////////////////////////
" Key Mappings
"/////////////////////////////////////////////////////////////////////////////

" NOTE: F10 looks like have some feature, when map with F10, the map will take no effects

" Don't use Ex mode, use Q for formatting
map Q gq

" define the copy/paste judged by clipboard
if &clipboard ==# 'unnamed'
    " fix the visual paste bug in vim
    " vnoremap <silent>p :call g:()<CR>
else
    " general copy/paste.
    " NOTE: y,p,P could be mapped by other key-mapping
    map <leader>y "*y
    map <leader>p "*p
    map <leader>P "*P
endif

" copy folder path to clipboard, foo/bar/foobar.c => foo/bar/
nnoremap <silent> <leader>y1 :let @*=fnamemodify(bufname('%'),":p:h")<CR>

" copy file name to clipboard, foo/bar/foobar.c => foobar.c
nnoremap <silent> <leader>y2 :let @*=fnamemodify(bufname('%'),":p:t")<CR>

" copy full path to clipboard, foo/bar/foobar.c => foo/bar/foobar.c
nnoremap <silent> <leader>y3 :let @*=fnamemodify(bufname('%'),":p")<CR>

" F8 or <leader>/:  Set Search pattern highlight on/off
nnoremap <F8> :let @/=""<CR>
nnoremap <leader>/ :let @/=""<CR>
" DISABLE: though nohlsearch is standard way in Vim, but it will not erase the
"          search pattern, which is not so good when use it with exVim's <leader>r
"          filter method
" nnoremap <F8> :nohlsearch<CR>
" nnoremap <leader>/ :nohlsearch<CR>

" map Ctrl-Tab to switch window
nnoremap <S-Up> <C-W><Up>
nnoremap <S-Down> <C-W><Down>
nnoremap <S-Left> <C-W><Left>
nnoremap <S-Right> <C-W><Right>

" easy buffer navigation
" NOTE: if we already map to EXbn,EXbp. skip setting this
if !hasmapto(':EXbn<CR>') && mapcheck('<C-l>','n') == ''
    nnoremap <C-l> :bn<CR>
endif
if !hasmapto(':EXbp<CR>') && mapcheck('<C-h>','n') == ''
    noremap <C-h> :bp<CR>
endif

" easy diff goto
noremap <C-k> [c
noremap <C-j> ]c

" enhance '<' '>' , do not need to reselect the block after shift it.
vnoremap < <gv
vnoremap > >gv

" map Up & Down to gj & gk, helpful for wrap text edit
noremap <Up> gk
noremap <Down> gj

" TODO: I should write a better one, make it as plugin exvim/swapword
" VimTip 329: A map for swapping words
" http://vim.sourceforge.net/tip_view.php?tip_id=
" Then when you put the cursor on or in a word, press "\sw", and
" the word will be swapped with the next word.  The words may
" even be separated by punctuation (such as "abc = def").
nnoremap <silent> <leader>sw "_yiw:s/\(\%#\w\+\)\(\W\+\)\(\w\+\)/\3\2\1/<cr><c-o>

"/////////////////////////////////////////////////////////////////////////////
" local setup
"/////////////////////////////////////////////////////////////////////////////

let vimrc_local_path = '~/.vimrc.local'
if exists('g:exvim_custom_path')
    let vimrc_local_path = g:exvim_custom_path.'/.vimrc.local'
endif

if filereadable(expand(vimrc_local_path))
    exec 'source ' . fnameescape(vimrc_local_path)
endif

" vim:ts=4:sw=4:sts=4 et fdm=marker:
