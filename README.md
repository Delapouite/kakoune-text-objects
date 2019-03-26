# kakoune-text-objects

[kakoune](http://kakoune.org) plugin providing extra text-objects

## Install

Add `text-objects.kak` to your autoload dir: `~/.config/kak/autoload/`.

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
scattered around different keys `x`, `<a-h>`, `<a-l>`, `Gh`, `Gi`…

This plugins tries to reunite them under the `x` text-object.
For example `<a-a>x` selects the *whole* line (EOL included), while `<a-i>x`, only select
*inside* the line (not leading spaces and EOL excluded).

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

A `selectors` user-mode is provided. Use the `text-object-map` command to enable it.

By default it is mapped on `user s`. Its goal is to avoid using the `alt` key as much as possible
and the related acrobatic fingers chords over the keyboard.

Example: to extend the selections until the next bracket.
From `<a-}> ]` to `, s K ]`

You are guided by auto-info boxes along the way.

## See Also

- [kakoune-mirror](https://github.com/Delapouite/kakoune-mirror)
- [kakoune-vertical-selection](https://github.com/occivink/kakoune-vertical-selection)
- [objectify.kak](https://github.com/alexherbo2/objectify.kak)

## Licence

Thanks a lot to [occivink](https://github.com/occivink) and
[alex](https://github.com/alexherbo2) for inspiration.

MIT
