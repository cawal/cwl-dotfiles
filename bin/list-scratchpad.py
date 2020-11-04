#!/usr/bin/env python3
import i3ipc

i3 = i3ipc.Connection()
for leaf in i3.get_tree().scratchpad().leaves():
    print(leaf.window_class)
