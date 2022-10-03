" ls -l /usr/share/vim/vim80/colors
"colorscheme delek
colorscheme elflord
"colorscheme torte
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
syntax on
set paste
set ruler
filetype plugin indent on
 " folding can help troubleshoot indentation syntax
set foldenable
set foldlevelstart=20
set foldmethod=indent
set is hlsearch ai ic scs
"nnoremap <space> za
"nnoremap <esc><esc> :nohls<cr>
" Settings for YAML:
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set nosmartindent
"set mouse=
" basic settings for yaml and python files
"autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab number autoindent
"autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent
autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 et ai

" YAML Editor netrw custom settings:
let g:netrw_list_hide= '.*\.swp$,^.vimrc$,^\.\./$,^\./$,^help$,^TEST.tml$'
let g:netrw_banner=0

" YAML Editor vim settings:
set switchbuf=useopen
set autoread exrc
set number
set colorcolumn=80
"set cursorcolumn    ###vertical line under cursore
" YAML Editor hotkeys:
map \o :rightbelow split .<cr>
map \O :rightbelow vsplit .<cr>
map <SPACE> :call RunYAML()<cr><cr>
map \g :call RunYAML()<cr>:wa<bar>!eval 'gist-paste *.*'<cr>
nnoremap \t :call WriteTestml()<cr><cr>
nnoremap \s :call SaveTestml()<cr><cr>
map \c :sb input.yaml<cr><bar>ggVGd
map \Q :qa!<cr>
map \q :q<cr>
map \8 <c-w>80<bar>
map \= <c-w>=
map \_ <c-w>_
map \<bar> <c-w><bar>
map \n :windo set number!<cr>
map \h :!(clear; less -FRX help)<cr>
map \l :!(clear; yaml-editor -l <bar> less -FRX)<cr>
map \M :set mouse=a<cr>
map \m :set mouse=<cr>
map \p :call PlayUrl()<cr>
map \P :call PlayData()<cr>

" Handy window commands:
nnoremap <c-j> <c-w>j<c-w><Esc>
nnoremap <c-k> <c-w>k<c-w><Esc>
nnoremap <c-l> <c-w>l<c-w><Esc>
nnoremap <c-h> <c-w>h<c-w><Esc>

" YAML Editor command functions:
function RunYAML()
  sb input.yaml
  write
  execute "!timeout 5 yaml-editor RUN"
endfunction

function WriteTestml()
  sb input.yaml
  write
  rightbelow vsplit `yaml-editor TESTML`
  wincmd L
endfunction

function SaveTestml()
  sb input.yaml
  write
  let file = system("yaml-editor SAVE")
  execute "rightbelow vsplit" file
  wincmd L
endfunction

function PlayUrl()
  sb input.yaml
  write
  let b64 = get(systemlist("base64 input.yaml | sed ':a;N;$!ba;s/\\n//g'"), 0, "")
  echom "https://play.yaml.io/main/parser?input=" . b64
endfunction

function PlayData()
  let url = input('Enter YAML Playground URL: ')
  if !empty(url)
    sb input
    normal! gg_dG
    call setline(1, url)
    write
    let x = system("cat input.yaml | sed 's/^[^=]*=//' | base64 -d - | tee input.yaml")
    edit!
  endif
endfunction

"runtime! indent/ruby.vim
"unlet! b:did_indent
let b:did_indent = 1

setlocal autoindent sw=2 et
setlocal indentexpr=GetYamlIndent()
setlocal indentkeys=o,O,*<Return>,!^F

highlight TabsWhitespace ctermbg=blue guibg=blue
autocmd VimEnter,WinEnter,BufNewFile,BufRead * match TabsWhitespace /\t/
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd VimEnter,WinEnter,BufNewFile,BufRead * call matchadd('ExtraWhitespace', '\ \+$')
" autocmd BufNewFile,BufRead * call matchadd('ExtraWhitespace', '\s\+$')

function! GetYamlIndent()
  let lnum = v:lnum - 1
  if lnum == 0
    return 0
  endif
  let line = substitute(getline(lnum),'\s\+$','','')
  let indent = indent(lnum)
  let increase = indent + &sw
  if line =~ ':$'
    return increase
  else
    return indent
  endif
endfunction

" A minimal YAML theme from the web:
if exists("b:did_indent")
  finish
endif
