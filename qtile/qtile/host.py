import socket
from dataclasses import dataclass
from typing import Dict, Sequence

from Xlib import X, display
from Xlib.ext import randr
from Xlib.Xatom import RESOURCE_MANAGER, STRING
from Xlib.display import Display

from libqtile.log_utils import logger


logger.warning("==========================================")

hostname = socket.gethostname()
logger.warning(f"Hostname: {hostname}")


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

@dataclass
class MonitorInfo:
    name: str
    x: int
    y: int
    width: int
    height: int
    is_primary: bool


def get_monitors() -> Sequence[MonitorInfo]:
    d = display.Display()
    screen = d.screen()
    window = screen.root

    res = randr.get_screen_resources(window)
    primary_output = randr.get_output_primary(window).output
    monitors = []

    for output in res.outputs:
        monitor_info = randr.get_output_info(window, output, res.config_timestamp)
        if monitor_info.crtc:
            crtc_info = randr.get_crtc_info(window, monitor_info.crtc, res.config_timestamp)
            monitors.append(
                MonitorInfo(
                    name= monitor_info.name,
                    x= crtc_info.x,
                    y= crtc_info.y,
                    width= crtc_info.width,
                    height= crtc_info.height,
                    is_primary= (output == primary_output),
                )
            )

    # Sort monitors left to right (by x position)
    monitors.sort(key=lambda m: m.x)
    logger.warning(monitors)

    return monitors

get_monitors()

def get_xresources_variables() -> Dict[str,str]:
    res_prop = Display().screen().root.get_full_property(RESOURCE_MANAGER, STRING)
    res_kv = (line.split(':', 1) for line in res_prop.value.decode().split('\n'))
    res_dict = {kv[0]: kv[1].strip() for kv in res_kv if len(kv) == 2}
    return res_dict
