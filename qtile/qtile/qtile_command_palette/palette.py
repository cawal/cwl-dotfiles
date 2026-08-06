"""Command palette de keybindings do qtile.

Indexa a lista ``keys`` (achatando os ``KeyChord``), mostra "atalho + descrição"
via um picker plugável e executa o keybinding escolhido replicando o dispatch
interno do qtile (``Qtile.process_key_event``).
"""

from __future__ import annotations

from functools import partial
from typing import Callable, Dict, List, Sequence, Tuple, Union

from libqtile.config import Key, KeyChord
from libqtile.core.manager import Qtile
from libqtile.lazy import LazyCall
from libqtile.log_utils import logger

from .pickers import Picker, dmenu_picker

# Entrada indexada: (rótulo exibido, Key a executar).
Entry = Tuple[str, Key]
# Um binding de topo da lista `keys` (ou de um submapping de chord).
Binding = Union[Key, KeyChord]

MOD_LABELS: Dict[str, str] = {
    "mod4": "Super",
    "mod1": "Alt",
    "control": "Ctrl",
    "shift": "Shift",
    "lock": "Lock",
    "mod5": "Mod5",
}


class CommandPalette:
    """Indexa a lista ``keys`` (achatando ``KeyChord``) e, via um picker plugável,
    permite buscar e executar um keybinding.

    A indexação acontece em tempo de chamada (a lista ``keys`` é guardada por
    referência), então bindings adicionados depois — inclusive os de grupo — entram
    automaticamente.
    """

    def __init__(
        self,
        keys: Sequence[Binding],
        picker: Picker = dmenu_picker,
        title: str = "Commands",
    ) -> None:
        self._keys = keys
        self._picker = picker
        self._title = title

    # -- callback de lazy.function --
    def show(self, qtile: Qtile) -> None:
        entries = self._index()  # [(rótulo, Key)]
        idx = self._picker([label for label, _ in entries], self._title)
        if idx is None or not (0 <= idx < len(entries)):
            return
        self._run_key(qtile, entries[idx][1])

    # -- indexação (walk recursivo, achata KeyChords) --
    def _index(self) -> List[Entry]:
        entries: List[Entry] = []
        self._walk(self._keys, "", entries)
        return entries

    def _walk(
        self, bindings: Sequence[Binding], prefix: str, entries: List[Entry]
    ) -> None:
        for b in bindings:
            if isinstance(b, KeyChord):
                sub_prefix = self._join(prefix, self._fmt_binding(b.modifiers, b.key))
                self._walk(b.submappings, sub_prefix, entries)
            elif isinstance(b, Key):
                if not b.commands:  # ex.: o Key([], "Escape") auto-anexado aos chords
                    continue
                binding = self._join(prefix, self._fmt_binding(b.modifiers, b.key))
                entries.append((f"{binding:<26} {self._label_for(b)}", b))

    def _join(self, prefix: str, part: str) -> str:
        return f"{prefix} → {part}" if prefix else part

    def _fmt_binding(self, modifiers: Sequence[str], key: Union[str, int]) -> str:
        mods = "+".join(MOD_LABELS.get(m, m) for m in modifiers)
        return f"{mods}+{key}" if mods else str(key)

    # -- rótulos: desc= quando existir, senão gerado do LazyCall --
    def _label_for(self, key: Key) -> str:
        if key.desc:
            return key.desc
        return " ; ".join(self._label_for_cmd(c) for c in key.commands)

    def _label_for_cmd(self, cmd: LazyCall) -> str:
        sel = self._sel_str(cmd.selectors)
        name = f"{sel}.{cmd.name}" if sel else cmd.name
        if cmd.name == "function" and cmd.args:
            detail = self._callable_name(cmd.args[0])
        elif cmd.args:
            detail = " ".join(str(a) for a in cmd.args)
        else:
            detail = ""
        return f"{name}: {detail}" if detail else name

    def _sel_str(self, selectors: Sequence[Tuple]) -> str:
        parts: List[str] = []
        for s in selectors or []:
            if not s:
                continue
            name = s[0]
            value = s[1] if len(s) > 1 else None
            parts.append(f"{name}[{value}]" if value is not None else name)
        return ".".join(parts)

    def _callable_name(self, fn: Callable[..., object]) -> str:
        if isinstance(fn, partial):
            fn = fn.func
        return getattr(fn, "__name__", None) or repr(fn)[:40]

    # -- execução: replica o loop do Qtile.process_key_event --
    def _run_key(self, qtile: Qtile, key: Key) -> None:
        for cmd in key.commands:
            if cmd.check(qtile):
                status, val = qtile.server.call(
                    (cmd.selectors, cmd.name, cmd.args, cmd.kwargs, False)
                )
                if status:  # 0 = SUCCESS; !=0 = ERROR/EXCEPTION
                    logger.warning("command palette error %s: %s", cmd.name, val)
