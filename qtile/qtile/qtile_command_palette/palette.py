"""Command palette unificada do qtile.

Mostra, num picker plugável (dmenu/rofi), uma lista buscável de comandos e
executa o escolhido. As entradas vêm de uma ou mais *fontes* — cada fonte é um
callable que devolve ``[(rótulo, ação)]`` sob demanda:

- :class:`KeybindingSource` — indexa a lista ``keys`` do qtile (achatando os
  ``KeyChord``); o rótulo é "atalho + descrição" e a execução replica o dispatch
  interno do qtile (``Qtile.server.call``).
- :class:`FunctionSource` — funções de usuário registradas via
  :func:`qtile_command_palette.registry.command`; o rótulo é "nome + 1ª linha da
  docstring" e a execução é ``fn(qtile)`` direto (não precisa do server.call).

A :class:`Palette` combina quantas fontes quiser: um único menu com keybindings
*e* funções, ou instâncias separadas por fonte para atalhos dedicados.
"""

from __future__ import annotations

from functools import partial
from typing import Callable, Dict, List, Sequence, Tuple, Union

from libqtile.config import Key, KeyChord
from libqtile.core.manager import Qtile
from libqtile.lazy import LazyCall
from libqtile.log_utils import logger

from .pickers import Picker, dmenu_picker
from .registry import UserCommand, registered

# Ação de uma entrada: recebe o Qtile (como um lazy.function) e executa.
Action = Callable[[Qtile], object]
# Entrada indexada: (rótulo exibido, ação a executar).
Entry = Tuple[str, Action]
# Fonte de entradas: produz a lista a cada abertura da palette (lazy).
Source = Callable[[], List[Entry]]
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

# Largura da 1ª coluna (atalho ou nome da função), p/ alinhar a descrição.
_LABEL_WIDTH = 26


class Palette:
    """Combina fontes de :data:`Entry` e, via um picker plugável, permite buscar
    e executar um comando.

    As fontes são consultadas a cada :meth:`show` (lazy), então bindings ou
    funções registrados depois entram automaticamente.
    """

    def __init__(
        self,
        *sources: Source,
        picker: Picker = dmenu_picker,
        title: str = "Commands",
    ) -> None:
        if not sources:
            raise ValueError("Palette exige ao menos uma fonte de entradas")
        self._sources = sources
        self._picker = picker
        self._title = title

    # -- callback de lazy.function --
    def show(self, qtile: Qtile) -> None:
        entries = self._collect()
        idx = self._picker([label for label, _ in entries], self._title)
        if idx is None or not (0 <= idx < len(entries)):
            return
        self._dispatch(qtile, entries[idx][1])

    def _collect(self) -> List[Entry]:
        entries: List[Entry] = []
        for source in self._sources:
            entries.extend(source())
        return entries

    def _dispatch(self, qtile: Qtile, action: Action) -> None:
        # Uma ação com bug não pode derrubar o WM: isola e loga.
        try:
            action(qtile)
        except Exception:  # noqa: BLE001
            logger.exception("command palette: erro ao executar a ação")


class KeybindingSource:
    """Fonte de entradas a partir da lista ``keys`` do qtile.

    Achata os ``KeyChord`` recursivamente. A lista ``keys`` é guardada por
    referência, então bindings adicionados depois — inclusive os de grupo —
    entram automaticamente. A execução replica o loop do
    ``Qtile.process_key_event``.
    """

    def __init__(self, keys: Sequence[Binding]) -> None:
        self._keys = keys

    def __call__(self) -> List[Entry]:
        entries: List[Entry] = []
        self._walk(self._keys, "", entries)
        return entries

    # -- indexação (walk recursivo, achata KeyChords) --
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
                label = f"{binding:<{_LABEL_WIDTH}} {self._label_for(b)}"
                entries.append((label, partial(self._run_key, key=b)))

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


class FunctionSource:
    """Fonte de entradas a partir de funções de usuário registradas.

    Por padrão consulta o registro global (:func:`registered`), mas aceita
    qualquer sequência de callables ``(qtile) -> object`` — ou um callable que a
    devolva — para testes ou registros isolados. O rótulo é ``nome`` + 1ª linha
    da docstring; a ação é a própria função (recebe o Qtile).
    """

    def __init__(
        self,
        commands: Union[Callable[[], Sequence[UserCommand]], Sequence[UserCommand]] = registered,
    ) -> None:
        self._commands = commands

    def __call__(self) -> List[Entry]:
        cmds = self._commands() if callable(self._commands) else self._commands
        return [(self._label(fn), fn) for fn in cmds]

    def _label(self, fn: UserCommand) -> str:
        name = getattr(fn, "__name__", None) or repr(fn)[:40]
        doc = fn.__doc__.strip().splitlines()[0] if fn.__doc__ else ""
        return f"{name:<{_LABEL_WIDTH}} {doc}" if doc else name


class CommandPalette(Palette):
    """Compat: palette só de keybindings.

    Equivale a ``Palette(KeybindingSource(keys), ...)``. Mantida para não quebrar
    configs antigas; prefira montar as fontes explicitamente.
    """

    def __init__(
        self,
        keys: Sequence[Binding],
        picker: Picker = dmenu_picker,
        title: str = "Commands",
    ) -> None:
        super().__init__(KeybindingSource(keys), picker=picker, title=title)
