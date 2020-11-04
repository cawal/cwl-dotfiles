#!/usr/bin/env python3

from i3ipc import Connection, Event

i3 = Connection()

workspaces = i3.get_workspaces();

for w in workspaces:
    print(w.name)
