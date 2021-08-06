# kakoune-text-objects

[kakoune](http://kakoune.org) plugin providing extra text-objects

## Install

Add `text-objects.kak` to your autoload dir: `~/.config/kak/autoload/`.

Or via [plug.kak](https://github.com/andreyorst/plug.kak):

```
plug 'delapouite/kakoune-text-objects'
```

## Why?

How many modes are there in Kakoune? 8?
`normal`, `insert`, `menu`, `prompt`, `goto`, `view`, `object` and `user`?

Unfortunately *on-key* modes like `object` are in fact divided in *sub-modes*:
`<a-i>q`, `<a-a>q` or `[q` (to name only a few of the possibilities) all
offer a slightly different behavior.

The problem occurs when you declare a new mapping like:

```
map global object f foo
```

There's currently no native way to differentiate between an object triggered by
`<a-i>f` or `<a-a>f`.

This plugin attempts to address this issue.

## Usage

### pairs

This plugin enhances the *pairs* text-objects (`(`, `)`, `{`, `}`…).

Let's illustrate with the `braces` text-object.
If the cursor is in a C function simple body and press `<a-i>{` it will select it.
But what if the cursor is in the main scope, just few lines below the function?
Normally, the `<a-i>{` would result in a noop and nothing would be selected.

With the enhanced behavior provided `<a-i>{` will attempt to find the **previous**
`{…}` in the code and select the inside of it. `<a-a>{` would do the same but select
the braces as well. With `<a-i>}` it will search the **next** couple.

See https://github.com/mawww/kakoune/issues/9

### line

By default Kakoune does not provide a real *line* text-object. This *line* concept is
scattered around different keys like `x`, `<a-h>`, `<a-l>`, `Gh`, `Gi`…

This plugins tries to reunite them under the `x` text-object.
For example `<a-a>x` selects the *whole* line (EOL included), while `<a-i>x`, only select
*inside* the line (not leading spaces and EOL excluded).

You may find this text-object redundant or even useless, but I found it nice to reinforce
Kakoune's *orthogonality*.

### buffer

By default Kakoune does not provide a real *buffer* text-object. This *buffer* concept is
scattered around different keys like `%`, `Gj`, `Gk`, `Ge`…

This plugins tries to reunite them under the `f` text-object.
For example `<a-a>f` selects the *whole* buffer, while `<a-i>f`, only select
*inside* the buffer (not leading or trailing spaces).

You may find this text-object redundant or even useless, but I found it nice to reinforce
Kakoune's *orthogonality*.

### vertical selection

Depends on [kakoune-vertical-selection](https://github.com/occivink/kakoune-vertical-selection).

It's a great companion to the builtin `C` key. `<a-i>v` selects up and down, `[v` selects up
and `]v` selects down.

### XML tags

There's currently a `t` text-object but it's very much work in progress at this stage.
Use it with caution.

### `selectors` mode

A `selectors` user-mode is provided.

Its goal is to avoid using the `alt` key as much as possible and the related acrobatic fingers chords over the keyboard.
Moreover it does not really make sense to waste a modifier key for a one shot sequence (a.k.a. dead-key behavior).

There's no default key to access this user-mode, but I personally map it to the `s` key:

```
map global normal s ': enter-user-mode selectors<ret>' -docstring 'selectors'
```

On a QWERTY layout, the `s` key is under the left hand.
All the keys mapped to this user-mode, like `i`, `o`, `j`… are all under the right hand.

I find this "left then right" hands sequence quite ergonomic.

The mnemonic logic is defined like this:

- `i` → inside, `o` → outside (around). Bonus, on a QWERTY layout there are next to each other.
- `h` → outside left, `l` → outside right
- `j` → inside left, `k` → inside right. Usually, `j` and `k` are for up and down moves.
   But again, on a QWERTY keyboard, `j` and `k` are located between the `h` and `l` pair ("inside" this pair)

As usual, upper keys are used to extend the selection.

Examples:

- to extend the selections until the next square bracket. Before: `<a-}> ]` After: `s K ]`
- to select around words. Before: `<a-a> w` After: `s o w`.

Note: You are guided by auto-info boxes along the way.

"But, by doing so, you're sacrificing the regular behavior of `s` in the normal mode!"

That's correct, but I decided to map it back to `s s`, which is easy to type:

```
map global selectors s s -docstring 'sub-selection'
```

## See Also

- [kakoune-mirror](https://github.com/Delapouite/kakoune-mirror)
- [kakoune-select-view](https://github.com/Delapouite/kakoune-select-view)
- [kakoune-vertical-selection](https://github.com/occivink/kakoune-vertical-selection)
- [objectify.kak](https://github.com/alexherbo2/objectify.kak)

## Licence

Thanks a lot to [occivink](https://github.com/occivink) and
[alex](https://github.com/alexherbo2) for inspiration.

MIT
