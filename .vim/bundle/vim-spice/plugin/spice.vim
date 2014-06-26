scriptencoding utf-8
if exists('g:loaded_spice')
  finish
endif
let g:loaded_spice = 1

let s:save_cpo = &cpo
set cpo&vim

let g:spice_highlight_pattern = get(g:, "spice_highlight_pattern",  '\k\+')
let g:spice_highlight_group = get(g:, "spice_highlight_group", "WarningMsg")
let g:spice_highlight_group_in_cursor = get(g:, "spice_highlight_group_in_cursor", "")
let g:spice_highlight_group_in_cursorline = get(g:, "spice_highlight_group_in_cursorline", "")
let g:spice_enable = get(g:, "spice_enable", 1)


function! s:init_hl()
	highlight SpiceDefaultCursorWord gui=underline guifg=NONE
	highlight SpiceUnderline term=underline cterm=underline gui=underline
endfunction

function! s:hl()
" 	call spice#highlight(g:spice_highlight_group, g:spice_highlight_pattern, g:spice_highlight_group_in_cursor)
	call spice#highlight(g:spice_highlight_group, g:spice_highlight_pattern,  "")
endfunction

command! -bar SpiceEnable  let g:spice_enable = 1 | call s:hl()
command! -bar SpiceDisable let g:spice_enable = 0 | call spice#hl_clear()


augroup spice
	autocmd!
	autocmd CursorMoved * call s:hl()
	autocmd BufLeave,WinLeave,InsertEnter * call spice#hl_clear()
	autocmd ColorScheme * call s:init_hl()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
