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

"set autoindent
"set smartindent