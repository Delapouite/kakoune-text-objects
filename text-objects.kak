# extended behaviors for pairs
map global object ( '<esc>:text-object-block (<ret>'              -docstring 'prev parenthesis block'
map global object ) '<esc>:text-object-block )<ret>'              -docstring 'next parenthesis block'
map global object { '<esc>:text-object-block {<ret>'              -docstring 'prev braces block'
map global object } '<esc>:text-object-block }<ret>'              -docstring 'next braces block'
map global object [ '<esc>:text-object-block [<ret>'              -docstring 'prev brackets block'
map global object ] '<esc>:text-object-block ]<ret>'              -docstring 'next brackets block'
map global object <lt> '<esc>:text-object-block <lt><ret>'        -docstring 'prev angle block'
map global object <gt> '<esc>:text-object-block <gt><ret>'        -docstring 'next angle block'
# additional text objects
map global object x <esc>:text-object-line<ret>                   -docstring line
map global object t <esc>:text-object-tag<ret>                    -docstring tag
map global object <tab> <esc>:text-object-indented-paragraph<ret> -docstring 'indented paragraph'
# depends on occivink/vertical-selection.kak
map global object v '<esc>:text-object-vertical<ret>'             -docstring 'vertical'
# alias to avoid shift
map global object d '"'                                           -docstring 'double quote string'

# see issue #9
# first normal behavior, then fallback if it fails
define-command -hidden text-object-block -params 1 %@ %sh!
  # there may be clever way to do this, but I don't want to be clever in shell
  case "$1" in
    '(') t=')';dir='<a-/>'; ;;
    '{') t='}';dir='<a-/>'; ;;
    '[') t=']';dir='<a-/>'; ;;
    '<') t='>';dir='<a-/>'; ;;
    ')') t='(';dir='/'; ;;
    '}') t='{';dir='/'; ;;
    ']') t='[';dir='/'; ;;
    '>') t='<';dir='/'; ;;
  esac
  # $t is used instead of $1 to provide more 'intuitive' prev / next blocks when nested
  echo "try %| exec $kak_opt_last_mode '$t' | catch %| exec $dir \Q '$t' \E <ret> ; exec $kak_opt_last_mode '$t' |"
! @

# this line object may seem to repeat builtins,
# it is mostly here to improve the orthogonality of kakoune design
define-command -hidden text-object-line %{ %sh{
  case "$kak_opt_last_mode" in
    '<a-i>') k='x_' ;;
    '<a-a>') k='x' ;;
    '[') k='<a-h>' ;;
    ']') k='<a-l>L' ;;
    '{') k='Gh' ;;
    '}') k='GlL' ;;
    '<a-[>') k='<a-h>_' ;;
    '<a-]>') k='<a-l>' ;;
    '<a-{>') k='Gi' ;;
    '<a-}>') k='Gl' ;;
  esac
  [ -n "$k" ] && echo "execute-keys <esc> $k"
} }

# work in progress - very brittle for now
define-command -hidden text-object-tag %{ %sh{
  case "$kak_opt_last_mode" in
    '<a-i>') k='<a-i>c<gt>,<lt><ret>' ;;
    '<a-a>') k='<esc><a-f><lt>2f<gt>' ;;
  esac
  [ -n "$k" ] && echo "exec $k"
} }

# thanks occivink
define-command -hidden text-object-indented-paragraph %{
  execute-keys -draft -save-regs '' '<a-i>pZ'
  execute-keys '<a-i>i<a-z>i'
}

# depends on occivink/vertical-selection.kak
define-command -hidden text-object-vertical %{ %sh{
  case "$kak_opt_last_mode" in
    '<a-i>') k='<esc>:select-vertically<ret>' ;;
    '<a-a>') k='<a-i>w<esc>:select-vertically<ret>' ;;
    '[') k='<esc>:select-up<ret>' ;;
    ']') k='<esc>:select-down<ret>' ;;
    '{') k='<a-i>w<esc>:select-up<ret>' ;;
    '}') k='<a-i>w<esc>:select-down<ret>' ;;
  esac
  [ -n "$k" ] && echo "exec $k"
} }

# helpers

# hack to know in which "submode" we are
# gGvV are not used in the context of this plugin
declare-option -hidden str last_mode
hook global NormalKey (g|G|v|V|<a-i>|<a-a>|\[|\]|\{|\}|<a-\[>|<a-\]>|<a-\{>|<a-\}>) %{
  set-option global last_mode %val{hook_param}
}

# to add the mappings back if needed
define-command -hidden text-object-map %{
  try %{ declare-user-mode selectors }
  map global user s ':enter-user-mode selectors<ret>' -docstring 'selectors…'

  map global selectors i <a-i> -docstring 'select inside object <a-i>'
  map global selectors a <a-a> -docstring 'select around object <a-a>'

  map global selectors j <a-[> -docstring 'select inner object start <a-[>'
  map global selectors k <a-]> -docstring 'select inner object end <a-]>'
  map global selectors J <a-{> -docstring 'extend inner object start <a-{>'
  map global selectors K <a-}> -docstring 'extend inner object end <a-}>'

  map global selectors h [ -docstring 'select object start ['
  map global selectors l ] -docstring 'select object end ]'
  map global selectors H { -docstring 'extend object start {'
  map global selectors L } -docstring 'extend object end }'
}

# in rare scenarios when you need the original mappings
define-command -hidden text-object-unmap %{
  unmap global user s

  unmap global selectors i
  unmap global selectors a

  unmap global selectors j
  unmap global selectors k
  unmap global selectors J
  unmap global selectors K

  unmap global selectors h
  unmap global selectors l
  unmap global selectors H
  unmap global selectors L
}

# init
# text-object-map
