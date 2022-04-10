from libqtile.core.manager import Qtile
from libqtile.command import lazy
from libqtile.config import Key, Group
from libqtile.log_utils import logger
from typing import Sequence, List, Callable


class VimMarksManager:
    def __init__(self, go_to_group_func: Callable[[Qtile, Group], None]):
        self.marks = dict()
        self.go_to_group_func = go_to_group_func
        for letter in (chr(n) for n in range(ord("a"), ord("z") + 1)):
            self.marks[letter] = None
        logger.warning("VimMarksManager activated")

    def _go_to_group(self, qtile: Qtile, group: Group):
        if self.go_to_group_func:
            self.go_to_group_func(qtile, group)
        else:
            ...

    def get_mark_window_keys(self) -> Sequence[Key]:
        bindings: List[Key] = []
        for letter in self.marks.keys():

            def func(qtile: Qtile, letter=letter, **kwargs):
                self.marks[letter] = qtile.current_window
                logger.warning(f"marked {letter}")

            b = Key([], letter, lazy.function(func))
            bindings.append(b)
        return bindings

    def get_goto_window_keys(self) -> Sequence[Key]:
        bindings: List[Key] = []
        for letter in self.marks.keys():
            logger.warning(letter)

            def func(qtile: Qtile, letter=letter, **kwargs):
                logger.warning(f"going to {letter}")
                window = self.marks.get(letter)
                try:
                    if window and window.state:
                        group = window.group
                        self._go_to_group(qtile, group)
                        qtile.current_group.focus(window)
                    else:
                        logger.warning("mapping not found")

                except Exception as e:
                    logger.warning(e)

            b = Key([], letter, lazy.function(func))
            bindings.append(b)
        return bindings
