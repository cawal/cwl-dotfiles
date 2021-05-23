import socket

hostname = socket.gethostname()


def list_screens():
    from Xlib import X, display
    from Xlib.ext import randr

    d = display.Display()
    s = d.screen()
    window = s.root.create_window(0, 0, 1, 1, 1, s.root_depth)

    res = randr.get_screen_resources(window)

    outputs = randr.get_screen_resources(window).outputs
    screen_names = []
    for output_id in outputs:
        output = (randr.get_output_info(window,output_id,0))
        if output.num_preferred:
            screen_names.append(output.name)

    return screen_names
