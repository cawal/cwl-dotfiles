"""Registro de funções de usuário para a command palette do qtile.

Decore uma função com :func:`command` para que ela apareça na palette. A função
recebe o ``Qtile`` (exatamente como um ``lazy.function``) e o rótulo exibido é o
nome dela mais a 1ª linha da docstring — então documente-a e o menu já fica
legível, sem cadastro paralelo de nome/descrição.

Exemplo::

    from qtile_command_palette import command

    @command
    def rescan_screens(qtile):
        \"\"\"Recalcula o layout dos monitores e restaura o wallpaper.\"\"\"
        ...
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Callable, List

if TYPE_CHECKING:  # só p/ tipagem; não depende do libqtile fora do runtime do qtile
    from libqtile.core.manager import Qtile

# Uma ação de usuário: recebe o Qtile e executa (o retorno é ignorado).
UserCommand = Callable[["Qtile"], object]

_registry: List[UserCommand] = []


def command(fn: UserCommand) -> UserCommand:
    """Decorator que registra ``fn`` como comando da palette.

    Retorna ``fn`` inalterada (dá pra empilhar com outros decorators). Registrar
    a mesma função duas vezes é no-op, evitando duplicatas se a config for
    reavaliada no mesmo processo.
    """
    if fn not in _registry:
        _registry.append(fn)
    return fn


def registered() -> List[UserCommand]:
    """Cópia da lista de funções registradas, na ordem de registro."""
    return list(_registry)
