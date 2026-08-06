"""Backends de menu ("pickers") para o CommandPalette.

Um picker recebe as linhas a exibir e um título e devolve o índice (0-based) da
linha escolhida, ou ``None`` se o usuário cancelou. A interface é deliberadamente
mínima para permitir vários backends sem tocar no núcleo:

- :func:`dmenu_picker` — padrão; usa a extensão ``Dmenu`` do qtile (dmenu
  suckless), disponível sem rofi. Requer o binário ``dmenu`` instalado.
- :func:`rofi_picker` — usa ``rofi -dmenu``.
- :func:`make_rofi_picker` / :func:`make_dmenu_picker` — fábricas para customizar
  (tema do rofi, cores/linhas do dmenu, ...).
"""

from __future__ import annotations

import subprocess
from functools import partial
from typing import Callable, Optional, Sequence

import libqtile
from libqtile.extension import Dmenu

# Contrato do picker: recebe (linhas, título) e devolve o índice escolhido ou None.
Picker = Callable[[Sequence[str], str], Optional[int]]


# --------------------------------------------------------------------------- #
# rofi
# --------------------------------------------------------------------------- #
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


# --------------------------------------------------------------------------- #
# dmenu (extensão do qtile) — picker padrão, não exige rofi
# --------------------------------------------------------------------------- #
def _run_dmenu(ext: Dmenu, lines: Sequence[str], title: str) -> Optional[int]:
    """Executa a extensão Dmenu com ``lines`` e devolve o índice escolhido.

    O ``Dmenu.run()`` retorna o *texto* da linha selecionada (não o índice),
    então mapeamos de volta para o índice. ``_configure`` é chamado a cada uso
    porque ele reconstrói o ``configured_command`` do zero (evita acúmulo de
    flags entre chamadas).
    """
    if not lines:
        return None
    lines = list(lines)
    ext.dmenu_prompt = title
    ext._configure(libqtile.qtile)
    selected = (ext.run(items=lines) or "").rstrip("\n")
    if not selected:
        return None
    try:
        return lines.index(selected)
    except ValueError:
        return None


_default_dmenu: Optional[Dmenu] = None


def dmenu_picker(lines: Sequence[str], title: str = "Commands") -> Optional[int]:
    """Picker padrão baseado no dmenu (suckless), via a extensão ``Dmenu`` do qtile.

    Não exige rofi. A instância ``Dmenu`` é criada preguiçosamente na primeira
    chamada, de modo que configs que usam outro picker não registram uma extensão
    à toa. Requer o binário ``dmenu`` instalado.
    """
    global _default_dmenu
    if _default_dmenu is None:
        _default_dmenu = Dmenu(dmenu_ignorecase=True, dmenu_lines=15)
    return _run_dmenu(_default_dmenu, lines, title)


def make_dmenu_picker(**dmenu_config) -> Picker:
    """Retorna um :data:`Picker` dmenu customizado.

    Aceita as opções da extensão ``Dmenu`` do qtile (``dmenu_lines``,
    ``dmenu_ignorecase``, ``dmenu_bottom``, ``font``, ``background``,
    ``foreground``, ``selected_background``, ``selected_foreground``, ...).
    """
    ext = Dmenu(**dmenu_config)
    return lambda lines, title="Commands": _run_dmenu(ext, lines, title)
