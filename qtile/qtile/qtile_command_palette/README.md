# qtile-command-palette

A searchable **command palette** for the [qtile](https://qtile.org) window
manager. Pop up a fuzzy menu (via `rofi` or `dmenu`) listing every keybinding
**and** your own registered functions, then run the one you pick — no need to
memorize shortcuts.

```
┌─ Commands ──────────────────────────────────────────────┐
│ > win                                                    │
│ Super+Return              Launch terminal                │
│ Super+w                   Close focused window            │
│ Super+p                   Command palette (keys + funcs)  │
│ bring_window              Bring a window (by name) here   │
│ rescan_screens            Recompute monitor layout        │
└──────────────────────────────────────────────────────────┘
```

## Why

- **Discoverability.** Every keybinding is listed with its shortcut and
  description — a live cheatsheet you can act on.
- **User functions as first-class commands.** Decorate any `fn(qtile)` with
  `@command` and it shows up in the same menu. The label is the function name;
  the description is the first line of its docstring. No parallel registry of
  names/descriptions to maintain.
- **One menu, many sources.** Keybindings and functions share a single menu (and
  a single hotkey), or you can split them into dedicated palettes.
- **Pluggable UI.** `dmenu` by default (no rofi required); swap in `rofi` with a
  theme via a one-liner.

## Architecture

Three small, decoupled layers:

| Layer | What it is | File |
|-------|------------|------|
| **Picker** | `(lines, title) -> selected index \| None`. The menu UI. | `pickers.py` |
| **Source** | `() -> [(label, action)]`. Produces entries on demand. | `palette.py` |
| **Palette** | Combines sources, shows them via a picker, runs the chosen `action(qtile)`. | `palette.py` |

An **action** is just a `Callable[[Qtile], object]` — the same shape qtile hands
to `lazy.function`. Two sources ship in the box:

- **`KeybindingSource(keys)`** — indexes qtile's `keys` list, flattening
  `KeyChord`s. Labels are `shortcut + description`; execution replays qtile's
  internal dispatch (`Qtile.server.call`). Because it holds `keys` *by
  reference*, bindings added later (including per-group ones) show up
  automatically.
- **`FunctionSource(commands=registered)`** — pulls from the `@command` registry.
  Labels are `name + first docstring line`; the action is the function itself.

Sources are consulted **every time the palette opens**, so newly registered
commands and bindings appear without a restart.

## Installation

This is a plain Python package — drop the `qtile_command_palette/` directory next
to your `config.py` (or anywhere on qtile's `PYTHONPATH`).

Requirements:
- qtile (tested on 0.36)
- `dmenu` **or** `rofi` on your `PATH` (for the menu UI)

## Quick start

Wire it up at the **end** of your `config.py`, after `keys` (and any per-group
bindings) are fully built:

```python
from qtile_command_palette import Palette, KeybindingSource

palette = Palette(KeybindingSource(keys))          # dmenu by default

keys.append(
    Key([mod], "p", lazy.function(palette.show),
        desc="Command palette"),
)
```

Press `Mod+p` and you get a fuzzy list of every keybinding.

## Registering user functions

Decorate any function that takes `qtile`. The name becomes the label; the first
docstring line becomes the description:

```python
from qtile_command_palette import command, Palette, KeybindingSource, FunctionSource

@command
def toggle_bar(qtile):
    """Show or hide the top bar."""
    qtile.current_screen.top.show(not qtile.current_screen.top.is_show())

# Unified menu: keybindings + functions in one list, one hotkey.
palette = Palette(KeybindingSource(keys), FunctionSource())

keys.append(Key([mod], "p", lazy.function(palette.show), desc="Command palette"))
```

Now `toggle_bar` appears in the same `Mod+p` menu, right alongside your
keybindings.

## Using rofi (with a theme)

`dmenu` is the default so the package works with zero extra deps. To use rofi —
and reuse the same picker inside your functions — build a picker once and pass it
around:

```python
from qtile_command_palette import Palette, KeybindingSource, FunctionSource, command
from qtile_command_palette.pickers import make_rofi_picker

picker = make_rofi_picker(theme="gruvbox-dark")   # any rofi .rasi theme name/path

palette = Palette(KeybindingSource(keys), FunctionSource(),
                  picker=picker, title="Commands")
```

### Functions that ask a second question

Because a picker is just `(lines, title) -> index`, a command can open its **own**
sub-menu. Here's a genuinely useful one — search a window by name across all
groups and pull it into the current group:

```python
@command
def bring_window(qtile):
    """Find a window by name (across all groups) and bring it to the current group."""
    windows = [w for g in qtile.groups for w in g.windows if w.name]
    if not windows:
        return
    current = qtile.current_group
    labels = [f"{w.name:<40} [{w.group.name}]" for w in windows]
    idx = picker(labels, "Bring window")          # reuse the themed rofi picker
    if idx is None or not (0 <= idx < len(windows)):
        return
    win = windows[idx]
    win.togroup(current.name)       # move it here (don't switch groups)
    current.focus(win, warp=True)   # focus the window we just pulled in
```

`Mod+p` → pick `bring_window` → a second rofi lists every window → pick one → it
lands in your current group.

## Separate palettes

Prefer distinct hotkeys? Instantiate a palette per source:

```python
palette_keys = Palette(KeybindingSource(keys), picker=picker, title="Keybindings")
palette_fns  = Palette(FunctionSource(),        picker=picker, title="Functions")

keys += [
    Key([mod], "p", lazy.function(palette_keys.show), desc="Keybinding palette"),
    Key([mod, "shift"], "p", lazy.function(palette_fns.show), desc="Function palette"),
]
```

## Pickers reference

All live in `qtile_command_palette.pickers`:

| Picker | Notes |
|--------|-------|
| `dmenu_picker` | Default. Uses qtile's built-in `Dmenu` extension. No rofi needed. |
| `make_dmenu_picker(**opts)` | Customize dmenu (`dmenu_lines`, `font`, colors, …). |
| `rofi_picker` | Uses `rofi -dmenu`. |
| `make_rofi_picker(theme=...)` | rofi with a fixed `.rasi` theme. |

Any callable matching `(lines: Sequence[str], title: str) -> int | None` works —
roll your own (fzf in a terminal, wofi, a GUI list…) and pass it as `picker=`.

## Writing a custom source

A source is any `() -> [(label, action)]`. Want your MRU apps, a bookmark list,
or systemd units in the palette? Return the entries:

```python
def app_source():
    apps = [("Firefox", "firefox"), ("Kitty", "kitty")]
    return [(name, (lambda q, c=cmd: q.spawn(c))) for name, cmd in apps]

palette = Palette(KeybindingSource(keys), FunctionSource(), app_source,
                  picker=picker)
```

## Notes & caveats

- **The picker blocks qtile's event loop** while the menu is open (it shells out
  to rofi/dmenu). This is fine for a menu, but don't run long work in a picker.
- **Actions run on qtile's main thread** (same as any keybinding). A command that
  blocks will freeze the WM. The palette wraps each action in a `try/except` and
  logs exceptions, so a buggy command won't take qtile down — but it can still
  hang it.
- **`__name__` is raw** (usually `snake_case`). The docstring is what makes the
  menu readable — so write one.

## API summary

```python
from qtile_command_palette import (
    Palette,            # Palette(*sources, picker=dmenu_picker, title="Commands")
    KeybindingSource,   # KeybindingSource(keys)
    FunctionSource,     # FunctionSource(commands=registered)
    command,            # @command decorator
    registered,         # () -> list of registered functions
)
from qtile_command_palette.pickers import (
    dmenu_picker, make_dmenu_picker,
    rofi_picker, make_rofi_picker,
)
```
