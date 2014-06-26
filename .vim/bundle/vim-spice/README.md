#spice.vim

カーソル下の単語を移動するたびにハイライトする。

## Screencapture

![spice](https://cloud.githubusercontent.com/assets/214488/3297888/eb37a8dc-f5f9-11e3-8620-5876f030d762.gif)

## Using

```vim
" ハイライトを有効にします（既定値）
SpiceEnable

" ハイライトを無効にします
SpiceDisable

" ハイライトするグループ名を設定します
let g:spice_highlight_group = "Search"

" filetype=cpp を無効にする
let g:spice#enable_filetypes = {
\	"cpp" : 0
\}

" filetype=vim のみを有効にする
let g:spice#enable_filetypes = {
\	"_"   : 0
\	"vim" : 1
\}
```


