from typing import Sequence, Dict
from libqtile.config import Group
from libqtile.log_utils import logger
from host import list_screens


def group_by_name(qtile, gname: str):
    return [group for group in qtile.groups if group.name == gname][0]


class GroupToDisplayMapper:
    def __init__(self, groups: Sequence[Group]):
        self.map: Dict[str, int] = dict([(group.name, 0) for group in groups])
        self.calculate_initial_config()

    def calculate_initial_config(self):
        screens = list_screens()
        n_screens = len(screens)
        n_groups = len(self.map)
        groups_per_screen = int(n_groups / n_screens)
        for index, group in enumerate(self.map.keys()):
            screen_index = int(index / groups_per_screen)
            logger.warning(
                f"Assigning group {group}" f"to screen {screens[screen_index]}"
            )
            self.map[group] = screen_index

    def go_to_group(self, qtile, group: Group):
        index = self.map.get(group.name, 0)
        qtile.cmd_to_screen(index)
        group_by_name(qtile, group.name).cmd_toscreen(toggle=False)

    def shift_group_display(self):
        def f(qtile):
            screens = list_screens()
            g = qtile.current_group
            index = self.map.get(g.name, 0)
            self.map[g.name] = (index + 1) % len(screens)
            self.go_to_group(qtile,g)

        return f

    def add_group(self, group_name: str):
        if group_name in self.map:
            return
        else:
            self.map[group_name] = 0

    def remove_group(self, group_name: str):
        if group_name not in self.map:
            return
        else:
            del self.map[group_name]
