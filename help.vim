"set cindent
"set autoindent
"set smartindent

:set nonu "cancle line number
:nohl "unset highlight

echo "Hello World"
let a = [1,2,3,4,5]
let i = 0
while i < 5
    echom i
    let i += 1
endwhile

function! TrimBlankLine()
  execute "normal A\n"
  let l:curr_row = line('.')
  let l:next_row = nextnonblank('.')
  if l:next_row - l:curr_row == 1
    return "\<CR>\<ESC>ki}\<ESC>O\<TAB>"
  endif
  while l:next_row - l:curr_row > 2
    execute "normal dd"
    let l:next_row = nextnonblank('.')
  endwhile
  return "}\<ESC>O\<TAB>"
endfunction

function! PrintArray(arr)
  echom string(a:arr)
endfunction

function! CopyArray(arr_orig)
  call PrintArray(a:arr_orig)
  let l:new_list = []
  call extend(l:new_list, a:arr_orig)
  return new_list
endfunction

function! ArrayCompare(src, dst)
  for i in range(len(a:src))
    if a:src[i] != a:dst[i]
      return 0
    endif
  endfor
  return 1
endfunction

function! TrimBlankLine()
  execute "normal A\n"
  let l:blanklines = nextnonblank('.') - line('.') - 1
  if l:blanklines > 0
    return "\<ESC>".l:blanklines."ddkA\<CR>}\<ESC>O\<TAB>"
  elseif l:blanklines == 0 && match(getline(line('.')+1), '}') == -1
    return "\<ESC>kA\<CR>}\<ESC>O\<TAB>"
  endif
  if IsEof()
    return "\<ESC>ddA\<CR>}\<ESC>O\<TAB>"
  endif
  return "\<ESC>ddkA\<CR>}\<ESC>O\<TAB>"
endfunction
