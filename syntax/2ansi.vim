" Vim syntax support file
" Author: Rogerz Zhang <rogerz.zhang@gmail.com>
" Create: 2004 Nov 10
" Update:
" 	2004 Nov 11,	Correct bugs when T_co =16
" 			Set bold as default attribute when in gui
" 			Correct bug of unmatched AnsiOpening and AnsiClosing
" 	
" Transform a file into ANSI sequence, using the current syntax highlighting.

" Number lines when explicitely requested or when `number' is set
if exists("ansi_number_lines")
  let s:numblines = ansi_number_lines
else
  let s:numblines = &number
endif

" Return opening Ansi Sequence tag for given highlight id
function! s:AnsiOpening(id)
  let fg = synIDattr(a:id, "fg", "cterm")
  let bg = synIDattr(a:id, "bg", "cterm")
  let inv = synIDattr(a:id, "inverse")
  let ul = synIDattr(a:id, "underline")
  let bd = synIDattr(a:id, "bold")
" Check if it is normal text
  if !(fg || bg || inv || ul || bd) | let s:normal = 1 | return "" | endif
  let s:normal = 0
" When in gui set bold as default attribute
  if has("gui_running") | let bd = 1 | endif
" When in 16 color term
  if fg > 7 | let fg = fg - 8 | let bd = 1 | endif
" Resume system color
  if fg == -1 | let bd = 0 | endif
" Add modifiers
  let a = "\<C-Q>\<C-[>["
  " For inverse
  if inv
    let a = a . "7"
  else
  " Bold control
    if bd | let a = a . "1" | else | let a = a . "0" | endif
  " Underline control
    if ul | let a = a . ";4" | endif
  " Frontgroud color and Background color control
    if fg!="-1" | let a = a . ";3" . fg | endif
    let x = synIDattr(a:id, "bg", "cterm")
    if bg!="-1" | let a = a . ";4" . bg | endif
  endif
  " End modifiers
  let a = a . "m"
  return a
endfun

" Return closing Ansi Sequence for given highlight id
function! s:AnsiClosing(id)
  if !(s:normal) | let a = "\<C-Q>\<C-[>[m" | else | let a = "" | endif
  return a
endfun


" Set some options to make it work faster.
let s:old_title = &title
let s:old_icon = &icon
let s:old_et = &l:et
let s:old_search = @/
let s:old_report = &report

set notitle noicon
setlocal et
set report=10000000

" Split window to create a buffer with the Ansi file.
let s:orgbufnr = winbufnr(0)
if expand("%") == ""
  new Untitled.ansi
else
  new %.ansi
endif
let s:newwin = winnr()
let s:orgwin = bufwinnr(s:orgbufnr)

set modifiable
%d
let s:old_paste = &paste
set paste
let s:old_magic = &magic
set magic

exe s:orgwin . "wincmd w"

" Loop over all lines in the original text.
" Use ansi_start_line and ansi_end_line if they are set.
if exists("ansi_start_line")
  let s:lnum = ansi_start_line
  if s:lnum < 1 || s:lnum > line("$")
    let s:lnum = 1
  endif
else
  let s:lnum = 1
endif
if exists("ansi_end_line")
  let s:end = ansi_end_line
  if s:end < s:lnum || s:end > line("$")
    let s:end = line("$")
  endif
else
  let s:end = line("$")
endif

while s:lnum <= s:end

  " Get the current line
  let s:line = getline(s:lnum)
  let s:len = strlen(s:line)
  let s:new = ""

  " Loop over each character in the line
  let s:col = 1
  while s:col <= s:len
    let s:startcol = s:col " The start column for processing text
    let s:id = synID(s:lnum, s:col, 1)
    let s:col = s:col + 1
    " Speed loop (it's small - that's the trick)
    " Go along till we find a change in synID
    while s:col <= s:len && s:id == synID(s:lnum, s:col, 1) | let s:col = s:col + 1 | endwhile

    " Output the text with the same synID enclosed by ansi sequence
    let s:id = synIDtrans(s:id)
    let s:new = s:AnsiOpening(s:id) . strpart(s:line, s:startcol - 1, s:col - s:startcol) . s:AnsiClosing(s:id)
    exe s:newwin . "wincmd w"
    exe "normal! a" . s:new
    exe s:orgwin . "wincmd w"
    if s:col > s:len
      break
    endif
  endwhile

  " Do the last loop
  exe s:newwin . "wincmd w"
  exe "normal! a" . "\n\e"
  exe s:orgwin . "wincmd w"
  let s:lnum = s:lnum + 1
endwhile

" Cleanup
exe s:newwin . "wincmd w"

" Restore old settings
let &title = s:old_title
let &icon = s:old_icon
let &paste = s:old_paste
let &magic = s:old_magic
let @/ = s:old_search
let &report = s:old_report
exe s:orgwin . "wincmd w"
let &l:et = s:old_et
exe s:newwin . "wincmd w"

" Save a little bit of memory (worth doing?)
unlet s:old_et s:old_paste s:old_icon s:old_title s:old_search s:old_report
unlet s:lnum s:end s:old_magic
unlet! s:col s:id s:attr s:len s:line s:new s:numblines
unlet s:orgwin s:newwin s:orgbufnr
