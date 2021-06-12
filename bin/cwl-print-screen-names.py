#!/usr/bin/env python3
# based on https://stackoverflow.com/questions/8705814/get-display-count-and-resolution-for-each-display-in-python-without-xrandr
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
print(outputs)

for output_id in outputs:
    print(randr.get_output_info(window,output_id,0))
    print(randr.get_output_info(window,output_id,0).name)
