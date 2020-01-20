# text-objects ─────────────────────────────────────────────────────────────────

hook global ModuleLoaded objectify %{
  require-module text-objects
}

provide-module text-objects %{
  require-module objectify
  # Surrounding pairs
  evaluate-commands %sh{
    set -- \
      'parenthesis' '(' ')' \
      'braces' '{' '}' \
      'brackets' '[' ']' \
      'angle' '<' '>'
    while test $# -ge 3; do
      name=$1 opening=$2 closing=$3
      shift 3
      echo "
        objectify-map-docstring 'previous $name block' global <a-a> $opening <esc><a-f>$opening<a-a>$opening
        objectify-map-docstring 'previous $name block' global <a-i> $opening <esc><a-f>$opening<a-i>$opening
        objectify-map-docstring 'next $name block' global <a-a> $closing <esc>f$closing<a-a>$closing
        objectify-map-docstring 'next $name block' global <a-i> $closing <esc>f$closing<a-i>$closing
      "
    done
  }
  # Line
  objectify-map-docstring 'line' global <a-i> x <esc><a-x>_
}

# objectify ────────────────────────────────────────────────────────────────────

provide-module objectify %{
  # map [switches] <scope> <mode> <key> <keys>
  # objectify-map <scope> <object-key> <key> <keys>
  # Example: objectify-map global <a-i> x <esc><a-x>_
  define-command objectify-map -params 4 -docstring 'objectify-map <scope> <object-key> <key> <keys>' %{
    objectify-map-docstring '' %arg{@}
  }
  alias global omap objectify-map
  # map [switches] <scope> <mode> <key> <keys>
  # objectify-map-docstring <docstring> <scope> <object-key> <key> <keys>
  # Example: objectify-map-docstring 'line' global <a-i> x <esc><a-x>_
  define-command objectify-map-docstring -params 5 -docstring 'objectify-map-docstring <docstring> <scope> <object-key> <key> <keys>' %{
    evaluate-commands %sh{
      docstring=$1 scope=$2 object_key=$3 key=$4 keys=$5
      case "$object_key" in
        '<a-a>')
          object_name='to_begin-to_end-replace'
          ;;
        '[')
          object_name='to_begin-replace'
          ;;
        ']')
          object_name='to_end-replace'
          ;;
        '{')
          object_name='to_begin-extend'
          ;;
        '}')
          object_name='to_end-extend'
          ;;
        '<a-i>')
          object_name='to_begin-to_end-inner-replace'
          ;;
        '<a-[>')
          object_name='to_begin-inner-replace'
          ;;
        '<a-]>')
          object_name='to_end-inner-replace'
          ;;
        '<a-{>')
          object_name='to_begin-inner-extend'
          ;;
        '<a-}>')
          object_name='to_end-inner-extend'
          ;;
      esac
      key_name=$(printf '%s' "$key" | shasum -a 512 | cut -c 1-7)
      command=objectify-$scope-$object_name-$key_name
      printf '
        define-command -hidden -override %s "execute-keys %%arg{3} %%arg{5}"
        map -docstring %%arg{1} %%arg{2} object %%arg{4} "<a-;> objectify-execute-mapping %%arg{2} %%%%val{object_flags} %%%%val{select_mode} %s<ret>"
      ' "$command" "$key_name"
    }
  }
  alias global omap-docstring objectify-map-docstring
  # objectify-execute-mapping <scope> <object-flags> <select-mode> <key-name>
  define-command -hidden objectify-execute-mapping -params 4 %{
    evaluate-commands %sh{
      scope=$1 object_flags=$2 select_mode=$3 key_name=$4
      object_flags_name=$(printf '%s' "$object_flags" | tr '|' '-')
      object_name=$object_flags_name-$select_mode
      command=objectify-$scope-$object_name-$key_name
      printf '%s' "$command"
    }
  }
}

require-module objectify
