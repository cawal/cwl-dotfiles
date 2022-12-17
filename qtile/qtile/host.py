import socket
from Xlib import X, display
from Xlib.ext import randr
from Xlib.Xatom import RESOURCE_MANAGER, STRING
from Xlib.display import Display
from typing import Dict

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
