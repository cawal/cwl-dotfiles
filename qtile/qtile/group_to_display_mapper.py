from typing import Sequence, Dict, Union, Protocol
from libqtile.log_utils import logger
from host import list_screens


def group_by_name(qtile, gname: str):
    return [group for group in qtile.groups if group.name == gname][0]

class NamedElement(Protocol):
    name: str


class GroupToDisplayMapper:
    def __init__(self, groups: Sequence[Union[str,NamedElement]]):
        self.map: Dict[str, int] = dict([(self._name_for_group(group), 0) for group in groups])
        self.calculate_initial_config()

    def calculate_initial_config(self):
        screens = list_screens()
        n_screens = len(screens)
        n_groups = len(self.map)
        groups_per_screen = int(n_groups / n_screens)
        for index, group in enumerate(self.map.keys()):
            screen_index = int(index / groups_per_screen)
            logger.warning(f"Assigning group {group} to screen {screens[screen_index]}")
            self.map[group] = screen_index

    def go_to_group(self, qtile, group: Union[str, NamedElement]):
        group_name = self._name_for_group(group)
        index = self.map.get(group_name, 0)
        qtile.to_screen(index)
        group_by_name(qtile, group_name).toscreen(toggle=False)

    def shift_group_display(self, qtile):
        group = qtile.current_group.name
        self.rotate_group(group)
        self.go_to_group(qtile, group)

    def rotate_all_groups_to_next_screen(self, qtile):
        for group_name in self.map.keys():
            self.rotate_group(group_name)

    def rotate_group(self, group: str):
        screens = list_screens()
        index = self.map.get(group, 0)
        self.map[group] = (index + 1) % len(screens)

    def _name_for_group(self, group: Union[str,NamedElement]):
        if hasattr(group, "name"):
            return group.name
        elif isinstance(group,str):
            return group
        else:
            raise Exception("`group`is not a string or has name")


    def add_group(self, group: str):
        if group in self.map:
            return
        else:
            self.map[group] = 0

    def remove_group(self, group: str):
        if group not in self.map:
            return
        else:
            del self.map[group]
