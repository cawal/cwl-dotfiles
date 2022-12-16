import socket
from Xlib import X, display
from Xlib.ext import randr
from Xlib.Xatom import RESOURCE_MANAGER, STRING
from Xlib.display import Display
from typing import Sequence,Dict
from libqtile.config import Screen, Group
from libqtile.log_utils import logger

hostname = socket.gethostname()


def list_screens():

    d = display.Display()
    s = d.screen()
    window = s.root.create_window(0, 0, 1, 1, 1, s.root_depth)

    outputs = randr.get_screen_resources(window).outputs
    screen_names = []
    for output_id in outputs:
        output = randr.get_output_info(window, output_id, 0)
        if output.num_preferred:
            screen_names.append(output.name)

    return screen_names

def get_xresources_variables() -> Dict[str,str]:
    res_prop = Display().screen().root.get_full_property(RESOURCE_MANAGER, STRING)
    res_kv = (line.split(':', 1) for line in res_prop.value.decode().split('\n'))
    res_dict = {kv[0]: kv[1].strip() for kv in res_kv if len(kv) == 2}
    return res_dict

def group_by_name(qtile, gname):
    return [group for group in qtile.groups if group.name == gname][0]


class GroupToDisplayMapper:
    def __init__(self, groups: Sequence[Group]):
        logger.warning("loading mapper")
        self.map = {}
        self.calculate_initial_config(groups)

    def calculate_initial_config(self, groups: Sequence[Group]):
        screens = list_screens()
        n_screens = len(screens)
        n_groups = len(groups)
        groups_per_screen = int(n_groups / n_screens)
        for index, group in enumerate(groups):
            screen_index = int(index / groups_per_screen)
            logger.warning(
                f"Assigning group {group.name}" f"to screen {screens[screen_index]}"
            )
            self.map[group.name] = screen_index

    def go_to_group(self, qtile, group: Group):
        index = self.map.get(group.name, 0)
        qtile.cmd_to_screen(index)
        group_by_name(qtile, group.name).cmd_toscreen(toggle=False)

    def go_to_group_func(self, group: Group):
        def f(qtile):
            self.go_to_group(qtile, group)

        return f

    def shift_group_display(self):
        def f(qtile):
            screens = list_screens()
            g = qtile.current_group
            index = self.map.get(g.name, 0)
            self.map[g.name] = (index + 1) % len(screens)
            self.go_to_group(g)

        return f
