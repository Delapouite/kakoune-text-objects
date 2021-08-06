# extended behaviors for pairs
map global object '('    '<esc>: text-object-block (<ret>'    -docstring 'prev parenthesis block'
map global object ')'    '<esc>: text-object-block )<ret>'    -docstring 'next parenthesis block'
map global object '{'    '<esc>: text-object-block {<ret>'    -docstring 'prev braces block'
map global object '}'    '<esc>: text-object-block }<ret>'    -docstring 'next braces block'
map global object '['    '<esc>: text-object-block [<ret>'    -docstring 'prev brackets block'
map global object ']'    '<esc>: text-object-block ]<ret>'    -docstring 'next brackets block'
map global object '<lt>' '<esc>: text-object-block <lt><ret>' -docstring 'prev angle block'
map global object '<gt>' '<esc>: text-object-block <gt><ret>' -docstring 'next angle block'
# additional text objects
map global object 'x'     '<esc>: text-object-line<ret>'               -docstring 'line'
map global object 't'     '<esc>: text-object-tag<ret>'                -docstring 'tag'
map global object 'f'     '<esc>: text-object-buffer<ret>'             -docstring 'buffer'
map global object '<tab>' '<esc>: text-object-indented-paragraph<ret>' -docstring 'indented paragraph'
# depends on occivink/kakoune-vertical-selection
map global object 'v' '<esc>: text-object-vertical<ret>' -docstring 'vertical selection'

# alias to avoid shift
map global object 'd' '"' -docstring 'double quote string'
map global object 'o' 'B' -docstring 'braces'

# see issue #9
# first normal behavior, then fallback if it fails
define-command -hidden text-object-block -params 1 %@
  evaluate-commands %sh!
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
    echo "try %| exec $kak_opt_objects_last_mode '$t' | catch %| exec $dir \Q '$t' \E <ret> ; exec $kak_opt_objects_last_mode '$t' |"
  !
@

# this line object may seem to repeat builtins,
# it is mostly here to improve the orthogonality of kakoune design
define-command -hidden text-object-line %{
  evaluate-commands %sh{
    case "$kak_opt_objects_last_mode" in
      # around
      '<a-a>') k='x' ;;
      '[') k='<a-h>' ;;
      ']') k='<a-l>L' ;;
      '{') k='Gh' ;;
      '}') k='GlL' ;;
      # inside
      '<a-i>') k='x_' ;;
      '<a-[>') k='<a-h>_' ;;
      '<a-]>') k='<a-l>' ;;
      '<a-{>') k='Gi' ;;
      '<a-}>') k='Gl' ;;
    esac
    [ -n "$k" ] && echo "execute-keys <esc> $k"
  }
}

# this buffer object may seem to repeat builtins,
# it is mostly here to improve the orthogonality of kakoune design
define-command -hidden text-object-buffer %{
  evaluate-commands %sh{
    case "$kak_opt_objects_last_mode" in
      # around
      '<a-a>') k='\%' ;;
      '[') k='<a-:><a-\;>\;Gk' ;;
      ']') k='<a-:>\;Ge' ;;
      '{') k='<a-:><a-\;>Gk' ;;
      '}') k='<a-:>Ge' ;;
      # inside
      '<a-i>') k='\%_' ;;
      '<a-[>') k='<a-:><a-\;>\;Gk_' ;;
      '<a-]>') k='<a-:>\;Ge_' ;;
      '<a-{>') k='<a-:><a-\;>Gk_' ;;
      '<a-}>') k='<a-:>Ge_' ;;
    esac
    [ -n "$k" ] && echo "execute-keys <esc> $k"
  }
}

# work in progress - very brittle for now
define-command -hidden text-object-tag %{
  evaluate-commands %sh{
    case "$kak_opt_objects_last_mode" in
      '<a-a>') k='<esc><a-f><lt>2f<gt>' ;;
      '<a-i>') k='<a-i>c<gt>,<lt><ret>' ;;
    esac
    [ -n "$k" ] && echo "execute-keys $k"
  }
}

# thanks occivink
define-command -hidden text-object-indented-paragraph %{
  execute-keys -draft -save-regs '' '<a-i>pZ'
  execute-keys '<a-i>i<a-z>i'
}

# depends on occivink/kakoune-vertical-selection
define-command -hidden text-object-vertical %{
  try %{
    evaluate-commands %sh{
      case "$kak_opt_objects_last_mode" in
        '<a-i>') k='<esc>:<space>vertical-selection-up-and-down<ret>' ;;
        '<a-a>') k='<a-i>w<esc>:<space>vertical-selection-up-and-down<ret>' ;;
        '[') k='<esc>:<space>vertical-selection-up<ret>' ;;
        ']') k='<esc>:<space>vertical-selection-down<ret>' ;;
        '{') k='<a-i>w<esc>:<space>vertical-selection-up<ret>' ;;
        '}') k='<a-i>w<esc>:<space>vertical-selection-down<ret>' ;;
      esac
      [ -n "$k" ] && echo "execute-keys $k"
    }
  } catch %{
    fail "no selections remaining" 
  }
}

# helpers

# hack to know in which "submode" we are
# gGvV are not used in the context of this plugin
declare-option -hidden str objects_last_mode
hook global NormalKey (g|G|v|V|<a-i>|<a-a>|\[|\]|\{|\}|<a-\[>|<a-\]>|<a-\{>|<a-\}>) %{
  set-option global objects_last_mode %val{hook_param}
}

# selectors user-mode, see README for usage
declare-user-mode selectors

map global selectors 'a' '*%s<ret>' -docstring 'select all'

map global selectors 'i' '<a-i>' -docstring 'select inside object <a-i>'
map global selectors 'o' '<a-a>' -docstring 'select outside object <a-a>'

map global selectors 'j' '<a-[>' -docstring 'select inner object start <a-[>'
map global selectors 'k' '<a-]>' -docstring 'select inner object end <a-]>'
map global selectors 'J' '<a-{>' -docstring 'extend inner object start <a-{>'
map global selectors 'K' '<a-}>' -docstring 'extend inner object end <a-}>'

map global selectors 'h' '[' -docstring 'select object start ['
map global selectors 'l' ']' -docstring 'select object end ]'
map global selectors 'H' '{' -docstring 'extend object start {'
map global selectors 'L' '}' -docstring 'extend object end }'
