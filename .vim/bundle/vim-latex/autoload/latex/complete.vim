" {{{1 latex#complete#init
function! latex#complete#init(initialized)
  "
  " Check if bibtex is available
  "
  if !executable('bibtex')
    echom "Warning: bibtex completion not available"
    echom "         Missing executable: bibtex"
    let s:bibtex = 0
  endif

  "
  " Check if kpsewhich is required and available
  "
  if g:latex_complete_recursive_bib && !executable('kpsewhich')
    echom "Warning: bibtex completion not available"
    echom "         Missing executable: kpsewhich"
    echom "         You could try to turn off recursive bib functionality"
    let s:bibtex = 0
  endif

  if g:latex_complete_enabled
    setlocal omnifunc=latex#complete#omnifunc
  endif
endfunction

" {{{1 latex#complete#omnifunc
let s:bibtex = 1
let s:completion_type = ''
function! latex#complete#omnifunc(findstart, base)
  if a:findstart
    "
    " First call:  Find start of text to be completed
    "
    " Note: g:latex_complete_patterns is a dictionary where the keys are the
    " types of completion and the values are the patterns that must match for
    " the given type.  Currently, it completes labels (e.g. \ref{...), bibtex
    " entries (e.g. \cite{...) and commands (e.g. \...).
    "
    let pos  = col('.') - 1
    let line = getline('.')[:pos-1]
    for [type, pattern] in items(g:latex_complete_patterns)
      if line =~ pattern . '$'
        let s:completion_type = type
        while pos > 0
          if line[pos - 1] =~ '{\|,' || line[pos-2:pos-1] == ', '
            return pos
          else
            let pos -= 1
          endif
        endwhile
        return -2
      endif
    endfor
  else
    "
    " Second call:  Find list of matches
    "
    if s:completion_type == 'ref'
      return latex#complete#labels(a:base)
    elseif s:completion_type == 'bib' && s:bibtex
      return latex#complete#bibtex(a:base)
    endif
  endif
endfunction

" {{{1 latex#complete#labels
function! latex#complete#labels(regex)
  let labels = s:labels_get(g:latex#data[b:latex.id].aux())
  let matches = filter(copy(labels), 'v:val[0] =~ ''' . a:regex . '''')

  " Try to match label and number
  if empty(matches)
    let regex_split = split(a:regex)
    if len(regex_split) > 1
      let base = regex_split[0]
      let number = escape(join(regex_split[1:], ' '), '.')
      let matches = filter(copy(labels),
            \ 'v:val[0] =~ ''' . base   . ''' &&' .
            \ 'v:val[1] =~ ''' . number . '''')
    endif
  endif

  " Try to match number
  if empty(matches)
    let matches = filter(copy(labels), 'v:val[1] =~ ''' . a:regex . '''')
  endif

  let suggestions = []
  for m in matches
    let entry = {
          \ 'word': m[0],
          \ 'menu': printf("%7s [p. %s]", '('.m[1].')', m[2])
          \ }
    if g:latex_complete_close_braces && !s:next_chars_match('^\s*[,}]')
      let entry = copy(entry)
      let entry.abbr = entry.word
      let entry.word = entry.word . '}'
    endif
    call add(suggestions, entry)
  endfor

  return suggestions
endfunction

" {{{1 latex#complete#bibtex
function! latex#complete#bibtex(regexp)
  let res = []

  let s:type_length = 4
  for m in s:bibtex_search(a:regexp)
    let type = m['type']   == '' ? '[-]' : '[' . m['type']   . '] '
    let auth = m['author'] == '' ? ''    :       m['author'][:20] . ' '
    let year = m['year']   == '' ? ''    : '(' . m['year']   . ')'

    " Align the type entry and fix minor annoyance in author list
    let type = printf('%-' . s:type_length . 's', type)
    let auth = substitute(auth, '\~', ' ', 'g')
    let auth = substitute(auth, ',.*\ze', ' et al. ', '')

    let w = {
          \ 'word': m['key'],
          \ 'abbr': type . auth . year,
          \ 'menu': m['title']
          \ }

    " Close braces if desired
    if g:latex_complete_close_braces && !s:next_chars_match('^\s*[,}]')
      let w.word = w.word . '}'
    endif

    call add(res, w)
  endfor

  return res
endfunction
" }}}1

" {{{1 s:bibtex_search
let s:bstfile = expand('<sfile>:p:h') . '/vimcomplete'
let s:type_length = 0
function! s:bibtex_search(regexp)
  let res = []

  " Find data from external bib files
  let bibdata = join(s:bibtex_find_bibs(), ',')
  if bibdata != ''
    let tmp = {
          \ 'aux' : 'tmpfile.aux',
          \ 'bbl' : 'tmpfile.bbl',
          \ 'blg' : 'tmpfile.blg',
          \ }

    " Write temporary aux file
    call writefile([
          \ '\citation{*}',
          \ '\bibstyle{' . s:bstfile . '}',
          \ '\bibdata{' . bibdata . '}',
          \ ], tmp.aux)

    " Create temporary bbl file
    silent execute '!bibtex -terse ' . tmp.aux . ' >/dev/null'
    if !has('gui_running')
      redraw!
    endif

    " Parse temporary bbl file
    let lines = split(substitute(join(readfile(tmp.bbl), "\n"),
          \ '\n\n\@!\(\s\=\)\s*\|{\|}', '\1', 'g'), "\n")

    for line in filter(lines, 'v:val =~ a:regexp')
      let matches = matchlist(line,
            \ '^\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)')
      if !empty(matches) && !empty(matches[1])
        let s:type_length = max([s:type_length, len(matches[2]) + 3])
        call add(res, {
              \ 'key':    matches[1],
              \ 'type':   matches[2],
              \ 'author': matches[3],
              \ 'year':   matches[4],
              \ 'title':  matches[5],
              \ })
      endif
    endfor

    call delete(tmp.aux)
    call delete(tmp.bbl)
    call delete(tmp.blg)
  endif

  " Find data from 'thebibliography' environments
  let lines = readfile(g:latex#data[b:latex.id].tex)
  if match(lines, '\C\\begin{thebibliography}') >= 0
    for line in filter(filter(lines, 'v:val =~ ''\C\\bibitem'''),
          \ 'v:val =~ a:regexp')
      let match = matchlist(line, '\\bibitem{\([^}]*\)')[1]
      call add(res, {
            \ 'key': match,
            \ 'type': '',
            \ 'author': '',
            \ 'year': '',
            \ 'title': match,
            \ })
    endfor
  endif

  return res
endfunction

" {{{1 s:bibtex_find_bibs
function! s:bibtex_find_bibs(...)
  if a:0
    let file = a:1
  else
    let file = g:latex#data[b:latex.id].tex
  endif

  if !filereadable(file)
    return ''
  endif
  let lines = readfile(file)
  let bibdata_list = []

  "
  " Search for added bibliographies
  " * Parse commands such as \bibliography{file1,file2.bib,...}
  " * This also removes the .bib extensions
  "
  let bibsearch  = '''\v\C\\'
  let bibsearch .= '(bibliography|add(bibresource|globalbib|sectionbib))'
  let bibsearch .= '\m\s*{\zs[^}]\+\ze}'''
  for entry in map(filter(copy(lines),
          \ 'v:val =~ ' . bibsearch),
        \ 'matchstr(v:val, ' . bibsearch . ')')
    let bibdata_list += map(split(entry, ','), 'fnamemodify(v:val, '':p:r'')')
  endfor

  if g:latex_complete_recursive_bib
    "
    " Recursively search included files
    "
    let incsearch  = '''\C\\'
    let incsearch .= '\%(input\|include\)'
    let incsearch .= '\s*{\zs[^}]\+\ze}'''
    for entry in map(filter(lines,
          \ 'v:val =~ ' . incsearch),
          \ 'matchstr(v:val, ' . incsearch . ')')
      let bibdata_list += s:bibtex_find_bibs(latex#util#kpsewhich(entry))
    endfor
  endif

  return bibdata_list
endfunction

" {{{1 s:labels_cache
"
" s:label_cache is a dictionary that maps filenames to tuples of the form
"
"   [ time, labels, inputs ]
"
" where time is modification time of the cache entry, labels is a list like
" returned by extract_labels, and inputs is a list like returned by
" s:extract_inputs.
"

let s:label_cache = {}

" {{{1 s:labels_get
function! s:labels_get(file)
  "
  " s:labels_get compares modification time of each entry in the label cache
  " and updates it if necessary.  During traversal of the label cache, all
  " current labels are collected and returned.
  "
  if !filereadable(a:file)
    return []
  endif

  " Open file in temporary split window for label extraction.
  if !has_key(s:label_cache , a:file)
        \ || s:label_cache[a:file][0] != getftime(a:file)
    let s:label_cache[a:file] = [
          \ getftime(a:file),
          \ s:labels_extract(a:file),
          \ s:labels_extract_inputs(a:file),
          \ ]
  endif

  " We need to create a copy of s:label_cache[fid][1], otherwise all inputs'
  " labels would be added to the current file's label cache upon each
  " completion call, leading to duplicates/triplicates/etc. and decreased
  " performance.  Also, because we don't anything with the list besides
  " matching copies, we can get away with a shallow copy for now.
  let labels = copy(s:label_cache[a:file][1])

  for input in s:label_cache[a:file][2]
    let labels += s:labels_get(input)
  endfor

  return labels
endfunction

" {{{1 s:labels_extract
function! s:labels_extract(file)
  "
  " Searches file for commands of the form
  "
  "   \newlabel{name}{{number}{page}.*}.*
  "
  " and returns a list of [name, number, page] tuples.
  "
  let matches = []
  let lines = readfile(a:file)
  let lines = filter(lines, 'v:val =~ ''\\newlabel{''')
  let lines = filter(lines, 'v:val !~ ''@cref''')
  let lines = map(lines, 'latex#util#convert_back(v:val)')
  for line in lines
    let tree = latex#util#tex2tree(line)
    if !empty(tree[2][0])
      call add(matches, [
            \ latex#util#tree2tex(tree[1][0]),
            \ latex#util#tree2tex(tree[2][0][0]),
            \ latex#util#tree2tex(tree[2][1][0]),
            \ ])
    endif
  endfor
  return matches
endfunction

" {{{1 s:labels_extract_inputs
function! s:labels_extract_inputs(file)
  "
  " Searches file for \@input{file} entries and returns list of all files.
  "
  let matches = []
  for line in filter(readfile(a:file), 'v:val =~ ''\\@input{''')
    call add(matches, matchstr(line, '{\zs.*\ze}'))
  endfor
  return matches
endfunction

" }}}1

" {{{1 s:next_chars_match
function! s:next_chars_match(regex)
  return strpart(getline('.'), col('.') - 1) =~ a:regex
endfunction
" }}}1

" vim: fdm=marker
