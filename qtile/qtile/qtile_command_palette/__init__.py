"""Command palette do qtile: menu buscável de keybindings e funções de usuário."""

from .palette import (
    CommandPalette,
    FunctionSource,
    KeybindingSource,
    Palette,
)
from .pickers import (
    dmenu_picker,
    make_dmenu_picker,
    make_rofi_picker,
    rofi_picker,
)
from .registry import command, registered

__all__ = [
    "Palette",
    "KeybindingSource",
    "FunctionSource",
    "CommandPalette",
    "command",
    "registered",
    "dmenu_picker",
    "make_dmenu_picker",
    "make_rofi_picker",
    "rofi_picker",
]
