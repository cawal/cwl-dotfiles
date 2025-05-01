from Xlib import display
from Xlib.ext import randr

def get_monitor_info():
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
            monitors.append({
                "name": monitor_info.name,
                "x": crtc_info.x,
                "y": crtc_info.y,
                "width": crtc_info.width,
                "height": crtc_info.height,
                "is_primary": (output == primary_output),
            })

    # Sort monitors left to right (by x position)
    monitors.sort(key=lambda m: m["x"])

    return monitors

if __name__ == "__main__":
    monitor_list = get_monitor_info()
    print(f"Detected {len(monitor_list)} monitor(s):")
    for i, m in enumerate(monitor_list):
        primary_label = " [PRIMARY]" if m["is_primary"] else ""
        print(f"Monitor {i+1}: {m['name']} at ({m['x']}, {m['y']}) size {m['width']}x{m['height']}{primary_label}")
