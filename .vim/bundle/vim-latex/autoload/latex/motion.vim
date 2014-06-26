" {{{1 latex#motion#init
function! latex#motion#init(initialized)
  if !g:latex_motion_enabled | return | endif

  if g:latex_mappings_enabled
    nnoremap <silent><buffer> % :call latex#motion#find_matching_pair()<cr>
    vnoremap <silent><buffer> %
          \ :<c-u>call latex#motion#find_matching_pair(1)<cr>
    onoremap <silent><buffer> % :normal v%<cr>

    nnoremap <silent><buffer> ]] :call latex#motion#next_section(0,0,0)<cr>
    nnoremap <silent><buffer> ][ :call latex#motion#next_section(1,0,0)<cr>
    nnoremap <silent><buffer> [] :call latex#motion#next_section(1,1,0)<cr>
    nnoremap <silent><buffer> [[ :call latex#motion#next_section(0,1,0)<cr>
    vnoremap <silent><buffer> ]] :<c-u>call latex#motion#next_section(0,0,1)<cr>
    vnoremap <silent><buffer> ][ :<c-u>call latex#motion#next_section(1,0,1)<cr>
    vnoremap <silent><buffer> [] :<c-u>call latex#motion#next_section(1,1,1)<cr>
    vnoremap <silent><buffer> [[ :<c-u>call latex#motion#next_section(0,1,1)<cr>
    onoremap <silent><buffer> ]] :normal v]]<cr>
    onoremap <silent><buffer> ][ :normal v][<cr>
    onoremap <silent><buffer> [] :normal v[]<cr>
    onoremap <silent><buffer> [[ :normal v[[<cr>

    vnoremap <silent><buffer> ie :<c-u>call latex#motion#sel_environment(1)<cr>
    vnoremap <silent><buffer> ae :<c-u>call latex#motion#sel_environment()<cr>
    onoremap <silent><buffer> ie :normal vie<cr>
    onoremap <silent><buffer> ae :normal vae<cr>

    vnoremap <silent><buffer> i$ :<c-u>call latex#motion#sel_inline_math(1)<cr>
    vnoremap <silent><buffer> a$ :<c-u>call latex#motion#sel_inline_math()<cr>
    onoremap <silent><buffer> i$ :normal vi$<cr>
    onoremap <silent><buffer> a$ :normal va$<cr>

    vnoremap <silent><buffer> id :<c-u>call latex#motion#sel_delimiter(1)<cr>
    vnoremap <silent><buffer> ad :<c-u>call latex#motion#sel_delimiter()<cr>
    onoremap <silent><buffer> id :normal vi(<cr>
    onoremap <silent><buffer> ad :normal va(<cr>
  endif

  "
  " Highlight matching parens ($, (), ...)
  "
  if !a:initialized && g:latex_motion_matchparen
    augroup latex_motion
      autocmd!
      " Disable matchparen autocommands
      autocmd BufEnter *.tex
            \   if !exists("g:loaded_matchparen") || !g:loaded_matchparen
            \ |   runtime plugin/matchparen.vim
            \ | endif
      autocmd BufEnter *.tex
            \ 3match none | unlet! g:loaded_matchparen | au! matchparen

      " Enable latex matchparen functionality
      autocmd! CursorMoved  *.tex call s:highlight_matching_pair(1)
      autocmd! CursorMovedI *.tex call s:highlight_matching_pair()
    augroup END
  endif
endfunction

" {{{1 latex#motion#find_matching_pair
function! latex#motion#find_matching_pair(...)
  if a:0 > 0
    normal! gv
  endif

  if latex#util#in_comment() | return | endif

  " Save position
  let nl = line('.')
  let nc = col('.')

  " Find delimiter under cursor
  let [lnum, cnum] = searchpos(s:delimiters, 'cbnW', nl-2)
  let delim = matchstr(getline(lnum), '^' . s:delimiters, cnum-1)

  " If delimiter not found, try to search forward instead
  if empty(delim)
    let [lnum, cnum] = searchpos(s:delimiters, 'cnW', nl+2)
    let delim = matchstr(getline(lnum), '^'. s:delimiters, cnum-1)
    if empty(delim)
      return
    endif
  endif

  " Utility pattern to NOT match the current cursor position
  let not_cursor = '\%(\%'. lnum . 'l\%' . cnum . 'c\)\@!'

  " Finally, find the matching delimiter
  if delim =~ '^\$'
    let inline = s:notcomment . s:notbslash . '\$'
    let [lnum0, cnum0] = searchpos('.', 'nW')
    if lnum0 && latex#util#has_syntax('texMathZoneX', lnum0, cnum0)
      let [lnum2, cnum2] = searchpos(inline, 'nW', 0, 200)
    else
      let [lnum2, cnum2] = searchpos(not_cursor . inline, 'bnW', 0, 200)
    endif

    call cursor(lnum2,cnum2)
  else
    for i in range(len(s:delimiters))
      let open_pat  = '\C' . s:notbslash . s:delimiters_open[i]
      let close_pat = '\C' . s:notbslash . s:delimiters_close[i]

      if delim =~# '^' . open_pat
        call searchpairpos(open_pat, '', close_pat,
              \ 'W', 'latex#util#in_comment()', 0, 200)
        call search(close_pat, 'ce')
        return
      elseif delim =~# '^' . close_pat
        call searchpairpos(open_pat, '', not_cursor . close_pat,
              \ 'bW', 'latex#util#in_comment()', 0, 200)
        return
      endif
    endfor
  endif
endfunction

" {{{1 latex#motion#next_section
function! latex#motion#next_section(type, backwards, visual)
  " Restore visual mode if desired
  if a:visual
    normal! gv
  endif

  " For the [] and ][ commands we move up or down before the search
  if a:type == 1
    if a:backwards
      normal! k
    else
      normal! j
    endif
  endif

  " Define search pattern and do the search while preserving "/
  let flags = 'W'
  if a:backwards
    let flags = 'b' . flags
  endif

  " Perform the search
  call search(s:section, flags)

  " For the [] and ][ commands we move down or up after the search
  if a:type == 1
    if a:backwards
      normal! j
    else
      normal! k
    endif
  endif
endfunction

" {{{1 latex#motion#sel_delimiter
function! latex#motion#sel_delimiter(...)
  let inner = a:0 > 0

  let [d1, l1, c1, d2, l2, c2] = latex#util#get_delim()

  if inner
    let c1 += len(d1)
    if c1 != len(getline(l1))
      let l1 += 1
      let c1 = 1
    endif
  endif

  if inner
    let c2 -= 1
    if c2 < 1
      let l2 -= 1
      let c2 = len(getline(l2))
    endif
  else
    let c2 += len(d2) - 1
  endif

  if l1 < l2 || (l1 == l2 && c1 < c2)
    call cursor(l1,c1)
    if visualmode() ==# 'V'
      normal! V
    else
      normal! v
    endif
    call cursor(l2,c2)
  endif
endfunction

" {{{1 latex#motion#sel_environment
function! latex#motion#sel_environment(...)
  let inner = a:0 > 0

  let [env, lnum, cnum, lnum2, cnum2] = latex#util#get_env(1)
  call cursor(lnum, cnum)
  if inner
    if env =~ '^\'
      call search('\\.\_\s*\S', 'eW')
    else
      call search('}\(\_\s*\[\_[^]]*\]\)\?\_\s*\S', 'eW')
    endif
  endif
  if visualmode() ==# 'V'
    normal! V
  else
    normal! v
  endif
  call cursor(lnum2, cnum2)
  if inner
    call search('\S\_\s*', 'bW')
  else
    if env =~ '^\'
      normal! l
    else
      call search('}', 'eW')
    endif
  endif
endfunction

" {{{1 latex#motion#sel_inline_math
function! latex#motion#sel_inline_math(...)
  let inner = a:0 > 0

  let dollar_pat = '\\\@<!\$'

  if latex#util#has_syntax('texMathZoneX')
    call s:search_and_skip_comments(dollar_pat, 'cbW')
  elseif getline('.')[col('.') - 1] == '$'
    call s:search_and_skip_comments(dollar_pat, 'bW')
  else
    return
  endif

  if inner
    normal! l
  endif

  if visualmode() ==# 'V'
    normal! V
  else
    normal! v
  endif

  call s:search_and_skip_comments(dollar_pat, 'W')

  if inner
    normal! h
  endif
endfunction
" }}}1

" {{{1 Common patterns

let s:notbslash = '\%(\\\@<!\%(\\\\\)*\)\@<='
let s:notcomment = '\%(\%(\\\@<!\%(\\\\\)*\)\@<=%.*\)\@<!'

" Patterns to match opening and closing delimiters/environments
let s:delimiters_open = [
        \ '{',
        \ '(',
        \ '\[',
        \ '\\{',
        \ '\\(',
        \ '\\\[',
        \ '\\\Cbegin\s*{.\{-}}',
        \ '\\\Cleft\s*\%([^\\a-zA-Z0-9]\|\\.\|\\\a*\)',
        \ '\\\cbigg\?\((\|\[\|\\{\)',
      \ ]
let s:delimiters_close = [
        \ '}',
        \ ')',
        \ '\]',
        \ '\\}',
        \ '\\)',
        \ '\\\]',
        \ '\\\Cend\s*{.\{-}}',
        \ '\\\Cright\s*\%([^\\a-zA-Z0-9]\|\\.\|\\\a*\)',
        \ '\\\cbigg\?\()\|\]\|\\}\)',
      \ ]
let s:delimiters = join(s:delimiters_open + s:delimiters_close, '\|')
let s:delimiters = '\(' . s:delimiters . '\|\$\)'

" Pattern to match section/chapter/...
let s:section = s:notcomment . '\v\s*\\'
let s:section.= '((sub)*section|chapter|part|appendix|(front|back|main)matter)'
let s:section.= '>'

" }}}1

" {{{1 s:highlight_matching_pair
function! s:highlight_matching_pair(...)
  if latex#util#in_comment() | return | endif
  let hmode = a:0 > 0 ? 1 : 0

  2match none

  " Save position
  let nl = line('.')
  let nc = col('.')
  let line = getline(nl)

  " Find delimiter under cursor
  let cnum = searchpos(s:delimiters, 'cbnW', nl)[1]
  let delim = matchstr(line, '^'. s:delimiters, cnum-1)

  " Only highlight when cursor is on delimiters
  if empty(delim) || strlen(delim)+cnum-hmode < nc
    return
  endif

  if delim =~ '^\$'
    "
    " Match inline math
    "
    let [lnum0, cnum0] = searchpos('.', 'nW')
    if lnum0 && latex#util#has_syntax('texMathZoneX', lnum0, cnum0)
      let [lnum2, cnum2] = searchpos(s:notcomment . s:notbslash . '\$',
            \ 'nW', line('w$'), 200)
    else
      let [lnum2, cnum2] = searchpos('\%(\%'. nl . 'l\%'
            \ . cnum . 'c\)\@!'. s:notcomment . s:notbslash . '\$',
            \ 'bnW', line('w0'), 200)
    endif

    execute '2match MatchParen /\%(\%' . nl . 'l\%'
          \ . cnum . 'c\$' . '\|\%' . lnum2 . 'l\%' . cnum2 . 'c\$\)/'
  else
    "
    " Match other delimitors
    "
    for i in range(len(s:delimiters_open))
      let open_pat  = '\C' . s:notbslash . s:delimiters_open[i]
      let close_pat = '\C' . s:notbslash . s:delimiters_close[i]

      if delim =~# '^' . open_pat
        let [lnum2, cnum2] = searchpairpos(open_pat, '', close_pat,
              \ 'nW', 'latex#util#in_comment()', line('w$'), 200)
        execute '2match MatchParen /\%(\%' . nl . 'l\%' . cnum
              \ . 'c' . s:delimiters_open[i] . '\|\%'
              \ . lnum2 . 'l\%' . cnum2 . 'c'
              \ . s:delimiters_close[i] . '\)/'
        return
      elseif delim =~# '^' . close_pat
        let [lnum2, cnum2] =  searchpairpos(open_pat, '',
              \ '\C\%(\%'. nl . 'l\%' . cnum . 'c\)\@!' . close_pat,
              \ 'bnW', 'latex#util#in_comment()', line('w0'), 200)
        execute '2match MatchParen /\%(\%' . lnum2 . 'l\%' . cnum2
              \ . 'c' . s:delimiters_open[i] . '\|\%'
              \ . nl . 'l\%' . cnum . 'c'
              \ . s:delimiters_close[i] . '\)/'
        return
      endif
    endfor
  endif
endfunction

" {{{1 s:search_and_skip_comments
function! s:search_and_skip_comments(pat, ...)
  " Usage: s:search_and_skip_comments(pat, [flags, stopline])
  let flags             = a:0 >= 1 ? a:1 : ''
  let stopline  = a:0 >= 2 ? a:2 : 0
  let saved_pos = getpos('.')

  " search once
  let ret = search(a:pat, flags, stopline)

  if ret
    " do not match at current position if inside comment
    let flags = substitute(flags, 'c', '', 'g')

    " keep searching while in comment
    while latex#util#in_comment()
      let ret = search(a:pat, flags, stopline)
      if !ret
        break
      endif
    endwhile
  endif

  if !ret
    " if no match found, restore position
    call setpos('.', saved_pos)
  endif

  return ret
endfunction
" }}}1

" vim: fdm=marker
