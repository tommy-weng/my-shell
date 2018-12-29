" Tab width
set tabstop=4
set softtabstop=4
set expandtab

" Indent width
set shiftwidth=4
set autoindent

" Set line number
set nu

" Auto complete
:inoremap ( <c-r>=OpenPair('(', ')')<CR>
:inoremap ) <c-r>=ClosePair(')')<CR>

:inoremap [ <c-r>=OpenPair('[', ']')<CR>
:inoremap ] <c-r>=ClosePair(']')<CR>

:inoremap " <c-r>=OpenPair('"', '"')<CR>
:inoremap ' <c-r>=OpenPair("'", "'")<CR>

:inoremap <CR> <c-r>=BracePair()<CR>
:inoremap <BS> <c-r>=RemovePair()<CR>

function! OpenPair(open, close)
  let l:line = getline('.')
  if col('.') > strlen(l:line) || l:line[col('.') - 1] == ' ' || l:line[col('.') - 1] == a:close
    return a:open.a:close."\<ESC>i"
  else
    return a:open
  endif
endfunction

function! ClosePair(close)
  let l:line = getline('.')
  if ExistPair() == 1 && l:line[col('.') - 1] != ''
    return "\<Right>"
  else
    return a:close
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

function! BracePair()
  if getline('.')[col('.') - 2] == '{'
    let l:status = ExistPair()
    if index([0,3], l:status) != -1
      return "\<CR>}\<ESC>O\<TAB>"
    elseif l:status == 1
      return "\<CR>\<ESC>O\<TAB>"
    elseif l:status == 2
      return "\<CR>\<TAB>"
    endif
  endif
  return "\<CR>"
endfunction

function RemovePair()
  let l:line  = getline('.')
  let l:left  = l:line[col('.')-2]
  let l:right = l:line[col('.')-1]
  if index(["{","(","[","\'","\""],l:left)!=-1 && index(["}",")","]","\'","\""],l:right)!=-1
    if len(l:line)==col('.')
      return "\<Esc>dldla"
    else
      return "\<Esc>dldli"
    endif
  endif
  if strlen(l:line) == 4 && l:left == ' ' && l:right == ''
    let l:preline  = getline(line('.')-1)
    let l:nextline = getline(line('.')+1)
    if match(l:preline,'{') != -1 && match(l:preline,'}') == -1
      if match(l:nextline,'{') == -1 && match(l:nextline,'}') != -1
        return "\<Esc>jddkk$dla"
      endif
    endif
  endif
  return "\<BS>"
endf

