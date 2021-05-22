#!/usr/bin/env python3

from Xlib import X, display
from Xlib.ext import randr

d = display.Display()
s = d.screen()
window = s.root.create_window(0, 0, 1, 1, 1, s.root_depth)

res = randr.get_screen_resources(window)

# print modes
#for mode in res.modes:
#    w, h = mode.width, mode.height
#    print("Width: {}, height: {}".format(w, h))

outputs = randr.get_screen_resources(window).outputs

for output_id in outputs:
    print(randr.get_output_info(window,output_id,0).name)
