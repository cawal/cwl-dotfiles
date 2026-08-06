"""Backends de menu ("pickers") para o CommandPalette.

Um picker recebe as linhas a exibir e um título e devolve o índice (0-based) da
linha escolhida, ou ``None`` se o usuário cancelou. A interface é deliberadamente
mínima para permitir outros backends (ex.: fzf num terminal) sem tocar no núcleo.
"""

from __future__ import annotations

import subprocess
from functools import partial
from typing import Callable, Optional, Sequence

# Contrato do picker: recebe (linhas, título) e devolve o índice escolhido ou None.
Picker = Callable[[Sequence[str], str], Optional[int]]


def rofi_picker(
    lines: Sequence[str],
    title: str = "Commands",
    theme: Optional[str] = None,
) -> Optional[int]:
    """Mostra ``lines`` no ``rofi -dmenu``; retorna o índice selecionado ou ``None``.

    Usa ``-format i`` para o rofi devolver o índice da escolha, evitando
    ambiguidade quando dois rótulos são iguais.

    theme:
        Nome ou caminho de um tema rofi (``.rasi``). Quando informado, é passado
        via ``-theme``; caso contrário usa o tema padrão do rofi.
    """
    if not lines:
        return None
    command = ["rofi", "-dmenu", "-i", "-format", "i", "-p", title]
    if theme:
        command += ["-theme", theme]
    result = subprocess.run(
        command,
        input="\n".join(lines),
        stdout=subprocess.PIPE,
        universal_newlines=True,
    )
    out = result.stdout.strip()
    if result.returncode != 0 or not out:
        return None
    try:
        return int(out)
    except ValueError:
        return None


def make_rofi_picker(theme: Optional[str] = None) -> Picker:
    """Retorna um :data:`Picker` rofi pré-configurado com um tema.

    Conveniência para passar ao ``CommandPalette``, cuja interface de picker é
    apenas ``(linhas, título)`` — o tema fica fixado aqui via ``partial``.
    ``make_rofi_picker()`` sem argumentos equivale ao :func:`rofi_picker` padrão.
    """
    return partial(rofi_picker, theme=theme)
