" Generated by Color Theme Generator at Sweyla
" http://themes.sweyla.com/seed/769013/

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

" Set environment to 256 colours
set t_Co=256

let colors_name = "sweyla769013"

if version >= 700
  hi CursorLine     guibg=#060600 ctermbg=16
  hi CursorColumn   guibg=#060600 ctermbg=16
  hi MatchParen     guifg=#BC9590 guibg=#060600 gui=bold ctermfg=138 ctermbg=16 cterm=bold
  hi Pmenu          guifg=#FFFFFF guibg=#323232 ctermfg=255 ctermbg=236
  hi PmenuSel       guifg=#FFFFFF guibg=#D7FF7D ctermfg=255 ctermbg=192
endif

" Background and menu colors
hi Cursor           guifg=NONE guibg=#FFFFFF ctermbg=255 gui=none
hi Normal           guifg=#FFFFFF guibg=#060600 gui=none ctermfg=255 ctermbg=16 cterm=none
hi NonText          guifg=#FFFFFF guibg=#15150F gui=none ctermfg=255 ctermbg=233 cterm=none
hi LineNr           guifg=#FFFFFF guibg=#1F1F19 gui=none ctermfg=255 ctermbg=234 cterm=none
hi StatusLine       guifg=#FFFFFF guibg=#2F3719 gui=italic ctermfg=255 ctermbg=236 cterm=italic
hi StatusLineNC     guifg=#FFFFFF guibg=#2E2E28 gui=none ctermfg=255 ctermbg=236 cterm=none
hi VertSplit        guifg=#FFFFFF guibg=#1F1F19 gui=none ctermfg=255 ctermbg=234 cterm=none
hi Folded           guifg=#FFFFFF guibg=#060600 gui=none ctermfg=255 ctermbg=16 cterm=none
hi Title            guifg=#D7FF7D guibg=NONE	gui=bold ctermfg=192 ctermbg=NONE cterm=bold
hi Visual           guifg=#FFFF00 guibg=#323232 gui=none ctermfg=226 ctermbg=236 cterm=none
hi SpecialKey       guifg=#86FF17 guibg=#15150F gui=none ctermfg=118 ctermbg=233 cterm=none
"hi DiffChange       guibg=#505000 gui=none ctermbg=58 cterm=none
"hi DiffAdd          guibg=#29294C gui=none ctermbg=236 cterm=none
"hi DiffText         guibg=#693566 gui=none ctermbg=241 cterm=none
"hi DiffDelete       guibg=#440400 gui=none ctermbg=52 cterm=none
 
hi DiffChange       guibg=#4C4C09 gui=none ctermbg=234 cterm=none
hi DiffAdd          guibg=#252556 gui=none ctermbg=17 cterm=none
hi DiffText         guibg=#66326E gui=none ctermbg=22 cterm=none
hi DiffDelete       guibg=#3F000A gui=none ctermbg=0 ctermfg=196 cterm=none
hi TabLineFill      guibg=#5E5E5E gui=none ctermbg=235 ctermfg=228 cterm=none
hi TabLineSel       guifg=#FFFFD7 gui=bold ctermfg=230 cterm=bold


" Syntax highlighting
hi Comment guifg=#D7FF7D gui=none ctermfg=192 cterm=none
hi Constant guifg=#86FF17 gui=none ctermfg=118 cterm=none
hi Number guifg=#86FF17 gui=none ctermfg=118 cterm=none
hi Identifier guifg=#DA6270 gui=none ctermfg=167 cterm=none
hi Statement guifg=#BC9590 gui=none ctermfg=138 cterm=none
hi Function guifg=#C7FF76 gui=none ctermfg=192 cterm=none
hi Special guifg=#E9FFA3 gui=none ctermfg=193 cterm=none
hi PreProc guifg=#E9FFA3 gui=none ctermfg=193 cterm=none
hi Keyword guifg=#BC9590 gui=none ctermfg=138 cterm=none
hi String guifg=#FFFF00 gui=none ctermfg=226 cterm=none
hi Type guifg=#FFFF4A gui=none ctermfg=227 cterm=none
hi pythonBuiltin guifg=#DA6270 gui=none ctermfg=167 cterm=none
hi TabLineFill guifg=#696900 gui=none ctermfg=58 cterm=none

