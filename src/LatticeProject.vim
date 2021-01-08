let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <C-J> <Plug>IMAP_JumpForward
inoremap <silent> <Plug>IMAP_JumpBack :call IMAP_Jumpfunc('b', 0)
inoremap <silent> <Plug>IMAP_JumpForward :call IMAP_Jumpfunc('', 0)
inoremap <C-U> u
vmap  "+y 
vmap <NL> <Plug>IMAP_JumpForward
nmap <NL> <Plug>IMAP_JumpForward
omap <silent> % <Plug>(MatchitOperationForward)
xmap <silent> % <Plug>(MatchitVisualForward)
nmap <silent> % <Plug>(MatchitNormalForward)
map Q gq
omap <silent> [% <Plug>(MatchitOperationMultiBackward)
xmap <silent> [% <Plug>(MatchitVisualMultiBackward)
nmap <silent> [% <Plug>(MatchitNormalMultiBackward)
omap <silent> ]% <Plug>(MatchitOperationMultiForward)
xmap <silent> ]% <Plug>(MatchitVisualMultiForward)
nmap <silent> ]% <Plug>(MatchitNormalMultiForward)
xmap a% <Plug>(MatchitVisualTextObject)
vmap gx <Plug>NetrwBrowseXVis
nmap gx <Plug>NetrwBrowseX
omap <silent> g% <Plug>(MatchitOperationBackward)
xmap <silent> g% <Plug>(MatchitVisualBackward)
nmap <silent> g% <Plug>(MatchitNormalBackward)
vnoremap <silent> <Plug>NetrwBrowseXVis :call netrw#BrowseXVis()
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(netrw#GX(),netrw#CheckIfRemote(netrw#GX()))
vmap <C-J> <Plug>IMAP_JumpForward
nmap <C-J> <Plug>IMAP_JumpForward
vnoremap <silent> <Plug>IMAP_JumpBack `<:call IMAP_Jumpfunc('b', 0)
vnoremap <silent> <Plug>IMAP_JumpForward :call IMAP_Jumpfunc('', 0)
vnoremap <silent> <Plug>IMAP_DeleteAndJumpBack "_<Del>:call IMAP_Jumpfunc('b', 0)
vnoremap <silent> <Plug>IMAP_DeleteAndJumpForward "_<Del>:call IMAP_Jumpfunc('', 0)
nnoremap <silent> <Plug>IMAP_JumpBack :call IMAP_Jumpfunc('b', 0)
nnoremap <silent> <Plug>IMAP_JumpForward :call IMAP_Jumpfunc('', 0)
vmap <C-C> "+y 
xmap <silent> <Plug>(MatchitVisualTextObject) <Plug>(MatchitVisualMultiBackward)o<Plug>(MatchitVisualMultiForward)
onoremap <silent> <Plug>(MatchitOperationMultiForward) :call matchit#MultiMatch("W",  "o")
onoremap <silent> <Plug>(MatchitOperationMultiBackward) :call matchit#MultiMatch("bW", "o")
xnoremap <silent> <Plug>(MatchitVisualMultiForward) :call matchit#MultiMatch("W",  "n")m'gv``
xnoremap <silent> <Plug>(MatchitVisualMultiBackward) :call matchit#MultiMatch("bW", "n")m'gv``
nnoremap <silent> <Plug>(MatchitNormalMultiForward) :call matchit#MultiMatch("W",  "n")
nnoremap <silent> <Plug>(MatchitNormalMultiBackward) :call matchit#MultiMatch("bW", "n")
onoremap <silent> <Plug>(MatchitOperationBackward) :call matchit#Match_wrapper('',0,'o')
onoremap <silent> <Plug>(MatchitOperationForward) :call matchit#Match_wrapper('',1,'o')
xnoremap <silent> <Plug>(MatchitVisualBackward) :call matchit#Match_wrapper('',0,'v')m'gv``
xnoremap <silent> <Plug>(MatchitVisualForward) :call matchit#Match_wrapper('',1,'v')m'gv``
nnoremap <silent> <Plug>(MatchitNormalBackward) :call matchit#Match_wrapper('',0,'n')
nnoremap <silent> <Plug>(MatchitNormalForward) :call matchit#Match_wrapper('',1,'n')
imap <NL> <Plug>IMAP_JumpForward
inoremap  u
let &cpo=s:cpo_save
unlet s:cpo_save
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=~/.cache/vim/backup//
set directory=~/.cache/vim/swap//
set expandtab
set fileencodings=ucs-bom,utf-8,default,latin1
set helplang=en
set hlsearch
set incsearch
set langnoremap
set nolangremap
set mouse=a
set ruler
set runtimepath=~/.vim,/usr/share/vim/vimfiles,/usr/share/vim/vim82,/usr/share/vim/vim82/pack/dist/opt/matchit,/usr/share/vim/vimfiles/after,~/.vim/after
set scrolloff=5
set shiftwidth=4
set showcmd
set showmatch
set splitright
set suffixes=.bak,~,.o,.info,.swp,.aux,.bbl,.blg,.brf,.cb,.dvi,.idx,.ilg,.ind,.inx,.jpg,.log,.out,.png,.toc
set tabstop=4
set undodir=~/.cache/vim/undo//
set undofile
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/.julia/dev/LightLattices/src
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
$argadd LightLattices.jl
edit rearrange_indices.jl
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 23 + 24) / 49)
exe 'vert 1resize ' . ((&columns * 104 + 94) / 189)
exe '2resize ' . ((&lines * 23 + 24) / 49)
exe 'vert 2resize ' . ((&columns * 104 + 94) / 189)
exe '3resize ' . ((&lines * 26 + 24) / 49)
exe 'vert 3resize ' . ((&columns * 84 + 94) / 189)
exe '4resize ' . ((&lines * 20 + 24) / 49)
exe 'vert 4resize ' . ((&columns * 84 + 94) / 189)
argglobal
balt LightLattices.jl
let s:cpo_save=&cpo
set cpo&vim
inoremap <buffer> <expr> <Plug>L2UTab LaTeXtoUnicode#Tab()
cnoremap <buffer> <S-Tab> eLaTeXtoUnicode#CmdTab(0)
inoremap <buffer> L2UFallbackTab 	
xnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_p")
onoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_p()
xnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_P")
onoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_P()
xnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_p")
onoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1 | call julia_blocks#move_p()
xnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_P")
onoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1 | call julia_blocks#move_P()
xnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_n")
onoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_n()
xnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_n")
onoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1 | call julia_blocks#move_n()
xnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_N")
onoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_N()
xnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_N")
onoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1 | call julia_blocks#move_N()
xnoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_a")
onoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_a")
xnoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_i")
onoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_i")
nnoremap <buffer> <silent> <Plug>(JuliaDocPrompt) :call julia#doc#prompt()
cnoremap <buffer> 	 eLaTeXtoUnicode#CmdTab(1)
imap <buffer> 	 <Plug>L2UTab
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=#1
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#=%s=#
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=^\\s*macro\\>
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'julia'
setlocal filetype=julia
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=^\\s*\\%(reload\\|include\\)\\>
setlocal includeexpr=
setlocal indentexpr=GetJuliaIndent()
setlocal indentkeys=0),0],!^F,o,O,e,=end,=else,=catch,=finally,),],}
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=:JuliaDocKeywordprg
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=LaTeXtoUnicode#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=4
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal spelloptions=
setlocal statusline=
setlocal suffixesadd=.jl
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'julia'
setlocal syntax=julia
endif
setlocal tabstop=4
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal undofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 5 - ((4 * winheight(0) + 11) / 23)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 0127|
wincmd w
argglobal
if bufexists("LightLattices.jl") | buffer LightLattices.jl | else | edit LightLattices.jl | endif
balt rearrange_indices.jl
let s:cpo_save=&cpo
set cpo&vim
inoremap <buffer> <expr> <Plug>L2UTab LaTeXtoUnicode#Tab()
cnoremap <buffer> <S-Tab> eLaTeXtoUnicode#CmdTab(0)
inoremap <buffer> L2UFallbackTab 	
xnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_p")
onoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_p()
xnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_P")
onoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_P()
xnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_p")
onoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1 | call julia_blocks#move_p()
xnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_P")
onoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1 | call julia_blocks#move_P()
xnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_n")
onoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_n()
xnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_n")
onoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1 | call julia_blocks#move_n()
xnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_N")
onoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_N()
xnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_N")
onoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1 | call julia_blocks#move_N()
xnoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_a")
onoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_a")
xnoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_i")
onoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_i")
nnoremap <buffer> <silent> <Plug>(JuliaDocPrompt) :call julia#doc#prompt()
cnoremap <buffer> 	 eLaTeXtoUnicode#CmdTab(1)
imap <buffer> 	 <Plug>L2UTab
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=#1
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#=%s=#
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=^\\s*macro\\>
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'julia'
setlocal filetype=julia
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=^\\s*\\%(reload\\|include\\)\\>
setlocal includeexpr=
setlocal indentexpr=GetJuliaIndent()
setlocal indentkeys=0),0],!^F,o,O,e,=end,=else,=catch,=finally,),],}
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=:JuliaDocKeywordprg
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=LaTeXtoUnicode#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=4
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal spelloptions=
setlocal statusline=
setlocal suffixesadd=.jl
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'julia'
setlocal syntax=julia
endif
setlocal tabstop=4
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal undofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 15 - ((5 * winheight(0) + 11) / 23)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
15
normal! 03|
wincmd w
argglobal
if bufexists("cells.jl") | buffer cells.jl | else | edit cells.jl | endif
balt lattices.jl
let s:cpo_save=&cpo
set cpo&vim
inoremap <buffer> <expr> <Plug>L2UTab LaTeXtoUnicode#Tab()
cnoremap <buffer> <S-Tab> eLaTeXtoUnicode#CmdTab(0)
inoremap <buffer> L2UFallbackTab 	
xnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_p")
onoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_p()
xnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_P")
onoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_P()
xnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_p")
onoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1 | call julia_blocks#move_p()
xnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_P")
onoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1 | call julia_blocks#move_P()
xnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_n")
onoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_n()
xnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_n")
onoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1 | call julia_blocks#move_n()
xnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_N")
onoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_N()
xnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_N")
onoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1 | call julia_blocks#move_N()
xnoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_a")
onoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_a")
xnoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_i")
onoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_i")
nnoremap <buffer> <silent> <Plug>(JuliaDocPrompt) :call julia#doc#prompt()
cnoremap <buffer> 	 eLaTeXtoUnicode#CmdTab(1)
imap <buffer> 	 <Plug>L2UTab
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=#1
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#=%s=#
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=^\\s*macro\\>
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'julia'
setlocal filetype=julia
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=^\\s*\\%(reload\\|include\\)\\>
setlocal includeexpr=
setlocal indentexpr=GetJuliaIndent()
setlocal indentkeys=0),0],!^F,o,O,e,=end,=else,=catch,=finally,),],}
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=:JuliaDocKeywordprg
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=LaTeXtoUnicode#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=4
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal spelloptions=
setlocal statusline=
setlocal suffixesadd=.jl
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'julia'
setlocal syntax=julia
endif
setlocal tabstop=4
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal undofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 155 - ((12 * winheight(0) + 13) / 26)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
155
normal! 041|
wincmd w
argglobal
if bufexists("lattices.jl") | buffer lattices.jl | else | edit lattices.jl | endif
balt cells.jl
let s:cpo_save=&cpo
set cpo&vim
inoremap <buffer> <expr> <Plug>L2UTab LaTeXtoUnicode#Tab()
cnoremap <buffer> <S-Tab> eLaTeXtoUnicode#CmdTab(0)
inoremap <buffer> L2UFallbackTab 	
xnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_p")
onoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [[ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_p()
xnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_P")
onoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_P()
xnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_p")
onoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_p", 0, 1)
nnoremap <buffer> <nowait> <silent> [j :let b:jlblk_count=v:count1 | call julia_blocks#move_p()
xnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_P")
onoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_P", 1, 1)
nnoremap <buffer> <nowait> <silent> [J :let b:jlblk_count=v:count1 | call julia_blocks#move_P()
xnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_n")
onoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]] :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_n()
xnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_n")
onoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_n", 0, 0)
nnoremap <buffer> <nowait> <silent> ]j :let b:jlblk_count=v:count1 | call julia_blocks#move_n()
xnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#moveblock_N")
onoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#moveblock_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ][ :let b:jlblk_count=v:count1 | call julia_blocks#moveblock_N()
xnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1gv:call julia_blocks#vwrapper_move("julia_blocks#move_N")
onoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1:call julia_blocks#owrapper_move(v:operator, "julia_blocks#move_N", 1, 0)
nnoremap <buffer> <nowait> <silent> ]J :let b:jlblk_count=v:count1 | call julia_blocks#move_N()
xnoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_a")
onoremap <buffer> <nowait> <silent> aj :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_a")
xnoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#vwrapper_select("julia_blocks#select_i")
onoremap <buffer> <nowait> <silent> ij :let b:jlblk_inwrapper=1:let b:jlblk_count=max([v:prevcount,1]):call julia_blocks#owrapper_select(v:operator, "julia_blocks#select_i")
nnoremap <buffer> <silent> <Plug>(JuliaDocPrompt) :call julia#doc#prompt()
cnoremap <buffer> 	 eLaTeXtoUnicode#CmdTab(1)
imap <buffer> 	 <Plug>L2UTab
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=#1
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#=%s=#
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=^\\s*macro\\>
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'julia'
setlocal filetype=julia
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=^\\s*\\%(reload\\|include\\)\\>
setlocal includeexpr=
setlocal indentexpr=GetJuliaIndent()
setlocal indentkeys=0),0],!^F,o,O,e,=end,=else,=catch,=finally,),],}
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=:JuliaDocKeywordprg
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=LaTeXtoUnicode#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=4
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal spelloptions=
setlocal statusline=
setlocal suffixesadd=.jl
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'julia'
setlocal syntax=julia
endif
setlocal tabstop=4
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal undofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 135 - ((5 * winheight(0) + 10) / 20)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
135
normal! 0142|
wincmd w
3wincmd w
exe '1resize ' . ((&lines * 23 + 24) / 49)
exe 'vert 1resize ' . ((&columns * 104 + 94) / 189)
exe '2resize ' . ((&lines * 23 + 24) / 49)
exe 'vert 2resize ' . ((&columns * 104 + 94) / 189)
exe '3resize ' . ((&lines * 26 + 24) / 49)
exe 'vert 3resize ' . ((&columns * 84 + 94) / 189)
exe '4resize ' . ((&lines * 20 + 24) / 49)
exe 'vert 4resize ' . ((&columns * 84 + 94) / 189)
tabnext 1
badd +0 LightLattices.jl
badd +96 cells.jl
badd +0 lattices.jl
badd +0 rearrange_indices.jl
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOS
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
