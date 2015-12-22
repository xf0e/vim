set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "railscasts"

hi link htmlTag xmlTag
hi link htmlTagName xmlTagName
hi link htmlEndTag xmlEndTag

highlight Normal guifg=#E6E1DC guibg=#232323
highlight Cursor guifg=#000000 ctermfg=0 guibg=#FFFFFF ctermbg=15
highlight CursorLine guibg=#000000 ctermbg=233 cterm=NONE

highlight Comment guifg=#BC9458 ctermfg=180 gui=italic
highlight Constant guifg=#6D9CBE ctermfg=73
highlight Define guifg=#CC7833 ctermfg=173
highlight Error guifg=#FFC66D ctermfg=221 guibg=#990000 ctermbg=88
highlight Function guifg=#FFC66D ctermfg=221 gui=NONE cterm=NONE
highlight Identifier guifg=#6D9CBE ctermfg=73 gui=NONE cterm=NONE
highlight Include guifg=#CC7833 ctermfg=173 gui=NONE cterm=NONE
highlight PreCondit guifg=#CC7833 ctermfg=173 gui=NONE cterm=NONE
highlight Keyword guifg=#CC7833 ctermfg=173 cterm=NONE
hi LineNr guifg=#808080 guibg=#222222 gui=none ctermfg=244 ctermbg=232
highlight Number guifg=#A5C261 ctermfg=107
highlight PreProc guifg=#E6E1DC ctermfg=103
highlight Search guifg=NONE ctermfg=NONE guibg=#2b2b2b ctermbg=235 gui=italic cterm=underline
highlight Statement guifg=#CC7833 ctermfg=173 gui=NONE cterm=NONE
highlight String guifg=#A5C261 ctermfg=107
highlight Title guifg=#FFFFFF ctermfg=15
highlight Type guifg=#DA4939 ctermfg=167 gui=NONE cterm=NONE
highlight Visual guibg=#5A647E ctermbg=60

highlight DiffAdd guifg=#E6E1DC ctermfg=7 guibg=#519F50 ctermbg=71
highlight DiffDelete guifg=#E6E1DC ctermfg=7 guibg=#660000 ctermbg=52
highlight Special guifg=#DA4939 ctermfg=167

highlight pythonBuiltin guifg=#6D9CBE ctermfg=73 gui=NONE cterm=NONE
highlight rubyBlockParameter guifg=#FFFFFF ctermfg=15
highlight rubyClass guifg=#FFFFFF ctermfg=15
highlight rubyConstant guifg=#DA4939 ctermfg=167
highlight rubyInstanceVariable guifg=#D0D0FF ctermfg=189
highlight rubyInterpolation guifg=#519F50 ctermfg=107
highlight rubyLocalVariableOrMethod guifg=#D0D0FF ctermfg=189
highlight rubyPredefinedConstant guifg=#DA4939 ctermfg=167
highlight rubyPseudoVariable guifg=#FFC66D ctermfg=221
highlight rubyStringDelimiter guifg=#A5C261 ctermfg=143

highlight xmlTag guifg=#E8BF6A ctermfg=179
highlight xmlTagName guifg=#E8BF6A ctermfg=179
highlight xmlEndTag guifg=#E8BF6A ctermfg=179

highlight mailSubject guifg=#A5C261 ctermfg=107
highlight mailHeaderKey guifg=#FFC66D ctermfg=221
highlight mailEmail guifg=#A5C261 ctermfg=107 gui=italic cterm=underline

highlight SpellBad guifg=#D70000 ctermfg=160 ctermbg=NONE cterm=underline
highlight SpellRare guifg=#D75F87 ctermfg=168 guibg=NONE ctermbg=NONE gui=underline cterm=underline
highlight SpellCap guifg=#D0D0FF ctermfg=189 guibg=NONE ctermbg=NONE gui=underline cterm=underline
highlight MatchParen guifg=#FFFFFF ctermfg=15 guibg=#005f5f ctermbg=23

"hi NonText guifg=#808080 guibg=#303030 gui=none ctermfg=244 ctermbg=235
hi NonText guifg=#606060 guibg=#232323 gui=none ctermfg=244 ctermbg=235

" General colors
hi Cursor guifg=NONE guibg=#626262 gui=none ctermbg=241
"hi Normal guifg=#e2e2e5 guibg=#202020 gui=none ctermfg=253 ctermbg=234
"hi NonText guifg=#808080 guibg=#303030 gui=none ctermfg=244 ctermbg=235
"hi LineNr guifg=#808080 guibg=#000000 gui=none ctermfg=244 ctermbg=232
"hi StatusLine guifg=#d3d3d5 guibg=#444444 gui=italic ctermfg=253 ctermbg=238 cterm=italic
"hi StatusLineNC guifg=#939395 guibg=#444444 gui=none ctermfg=246 ctermbg=238
"hi VertSplit guifg=#444444 guibg=#444444 gui=none ctermfg=238 ctermbg=238
"hi Folded guibg=#384048 guifg=#a0a8b0 gui=none ctermbg=4 ctermfg=248
"hi Title guifg=#f6f3e8 guibg=NONE gui=bold ctermfg=254 cterm=bold
"hi Visual guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=254 ctermbg=4
"hi SpecialKey guifg=#808080 guibg=#343434 gui=none ctermfg=244 ctermbg=236