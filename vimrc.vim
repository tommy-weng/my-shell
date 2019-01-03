" Tab width
set tabstop=4
set softtabstop=4
set expandtab

" Indent width
set shiftwidth=4
set autoindent

" Set line number
set nu

" Init varable
let s:prev_pos = []

" Auto complete
:inoremap ( <c-r>=OpenPair('(', ')')<CR>
:inoremap ) <c-r>=ClosePair(')')<CR>

:inoremap [ <c-r>=OpenPair('[', ']')<CR>
:inoremap ] <c-r>=ClosePair(']')<CR>

:inoremap " <c-r>=QuotePair('"')<CR>
:inoremap ' <c-r>=QuotePair("'")<CR>

:inoremap { <c-r>=BracePairHorizon()<CR>
:inoremap <CR> <c-r>=BracePairVertical()<CR>
:inoremap } <c-r>=ClosePair('}')<CR>

:inoremap <BS> <c-r>=RemovePair()<CR>

function! OpenPair(open, close)
  let l:line = getline('.')
  if col('.') > strlen(l:line) || index(["}",")","]"," "], l:line[col('.') - 1]) != -1
    return a:open.a:close."\<ESC>i"
  else
    return a:open
  endif
endfunction

function! ClosePair(close)
  let l:line = getline('.')
  if ExistPair() == 1 && l:line[col('.') - 1] == a:close
    return "\<Right>"
  else
    return a:close
  endif
endfunction

function! QuotePair(quote)
  let l:line = getline('.')
  if l:line[col('.') - 2] == ' ' && l:line[col('.') - 1] == ''
    return a:quote.a:quote."\<ESC>i"
  elseif l:line[col('.') - 1] == a:quote
    return "\<Right>"
  else
    return a:quote
  endif
endfunction

function! ExistPair()
  let l:original_pos = getpos(".")
  execute "normal %"
  let l:new_pos1 = getpos(".")
  execute "normal %"
  let l:new_pos2 = getpos(".")
  call setpos(".", l:original_pos)
  if l:new_pos1 == l:new_pos2
    return 0
  else
    if l:new_pos1[1] == l:new_pos2[1] && l:new_pos1[2] != l:new_pos2[2]
      return 1
    elseif l:new_pos1[1] != l:new_pos2[1] && l:new_pos1[2] == l:new_pos2[2]
      return 2
    else
      return 3
    endif
  endif
endfunction  

function! BracePairHorizon()
  let l:line = getline('.')
  if match(l:line,'=') != -1 || index(["}",")","]"," "], l:line[col('.') - 1]) != -1
    return "{}\<ESC>i"
  else
    return "{"
endfunction

function! ShiftLeft()
  let l:curr_pos = getpos(".")
  let l:curr_pos[2] -= 1
  call setpos(".", l:curr_pos)
endfunction

function! ShiftRight()
  let l:curr_pos = getpos(".")
  let l:curr_pos[2] += 1
  call setpos(".", l:curr_pos)
endfunction

function! BracePairVertical()
  let l:line  = getline('.')
  if getline('.')[col('.') - 2] == '{'
    call ShiftLeft()
    let l:status = ExistPair()
    call ShiftRight()
    if index([0,3], l:status) != -1
      return "\<CR>}\<ESC>O\<TAB>"
    elseif l:status == 1
      return "\<CR>\<ESC>O\<TAB>"
    elseif l:status == 2
      return "\<CR>\<TAB>"
    endif
  elseif index([")", "]", "}"], l:line[col('.') - 1]) != -1
    let l:curr_pos = getpos(".")
    if s:prev_pos != l:curr_pos
      let s:prev_pos = l:curr_pos
      return "\<right>"
    endif
  endif
  return "\<CR>"
endfunction

function RemovePair()
  let l:line  = getline('.')
  let l:left  = l:line[col('.')-2]
  let l:right = l:line[col('.')-1]
  let l:leftpos  = index(["{","(","[","\'","\""],l:left)
  let l:rightpos = index(["}",")","]","\'","\""],l:right)
  if l:leftpos != -1 && l:rightpos != -1 && l:leftpos == l:rightpos
    return "\<Esc>dldli"
  endif
  if l:left == ' ' && l:right == ''
    let l:preline  = getline(line('.')-1)
    let l:nextline = getline(line('.')+1)
    if match(l:preline,'{') != -1 && match(l:preline,'}') == -1
      if match(l:nextline,'{') == -1 && match(l:nextline,'}') != -1
        return "\<Esc>dldldldljddkk$dda"
      endif
    endif
  endif
  return "\<BS>"
endf

