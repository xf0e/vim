scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("spice")
let s:Prelude = s:V.import("Prelude")
let s:Buffer = s:V.import("Coaster.Buffer")
let s:Highlight = s:V.import("Coaster.Highlight")
let s:Search = s:V.import("Coaster.Search")


let g:spice#enable_filetypes = get(g:, "spice#enable_filetypes", {})
let g:spice#highlight_format  = get(g:, "spice#highlight_format", "\\<%s\\>")


function! s:is_enable_in_current()
	let default = get(g:spice#enable_filetypes, "_", 1)
	return g:spice_enable && get(g:spice#enable_filetypes, &filetype, default)
endfunction


function! spice#hl_clear()
	call s:Highlight.clear("cursor_word")
	call s:Highlight.clear("cursor_line")
	call s:Highlight.clear("current_word")
endfunction


function! s:single_word(group, pattern)
	let pattern = a:pattern
	if pattern ==# ""
		let word = expand("<cword>")
	else
		let word = s:Buffer.get_text_from_pattern(pattern)
	endif

	if word == ""
		return
	endif

	" マルチバイト文字はハイライトしない
	if !empty(filter(split(word, '\zs'), "strlen(v:val) > 1"))
		return
	endif

	let group   = a:group
	let pattern = printf(g:spice#highlight_format, s:Prelude.escape_pattern(word))
	if g:spice_highlight_group_in_cursorline == ""
		call s:Highlight.highlight("cursor_word", group, pattern, -1)
	else
		call s:Highlight.highlight("cursor_word", group, pattern, -1)
		call s:Highlight.highlight("cursor_line", g:spice_highlight_group_in_cursorline, '\%' . line('.') . 'l'. pattern, -1)
	endif
endfunction


function! s:with_current(current_group, group, pattern)
	let [first, last] = s:Search.region(a:pattern, "Wncb", "Wnce")
	if first == [0, 0] || last == [0, 0]
		return
	endif
	let word = s:Buffer.get_text_from_region([0] + first + [0], [0] + last + [0], "v")
	if word !~ '^' . a:pattern . '$'
		return
	endif
	let current = s:Search.pattern_by_range("v", first, last)

	" マルチバイト文字はハイライトしない
	if !empty(filter(split(word, '\zs'), "strlen(v:val) > 1"))
		return
	endif

	let pattern = printf(g:spice#highlight_format, s:Prelude.escape_pattern(word))

	call s:Highlight.highlight("cursor_word", a:group, pattern, -1)
	call s:Highlight.highlight("current_word", a:current_group, current, -1)
endfunction


function! spice#highlight(group, pattern, ...)
	call spice#hl_clear()
	if !s:is_enable_in_current()
		return
	endif

	if get(a:, 1, "") == ""
		return s:single_word(a:group, a:pattern)
	else
		return s:with_current(a:1, a:group, a:pattern)
	endif
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
