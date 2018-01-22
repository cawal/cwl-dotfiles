# -*- coding: utf-8 -*-

from i3pystatus import Status, Module
from i3pystatus.updates import pacman, cower

status = Status(standalone=True, interval=1)

nosep = {"separator": False, "separator_block_width": 0}

status.register("clock", format="%a %-d %b %H:%M ", interval=30,
                on_leftclick = "gsimplecal")

status.register("pulseaudio", format="{volume} ♪")

status.register("battery", format="{status} {remaining}  ", alert=True,
                interval=5, full_color="#FFFFFF", color="#FFFF00")

#status.register("updates", format = "Updates: {count}",
#                format_no_updates = "No updates",
#                format_working = "Checking updates...",
#                color = "#FFFF00", color_no_updates = "#FFFFFF",
#                color_working = "#00FF00", interval = 3600,
#                backends = [pacman.Pacman()])

status.register("temp", format="{temp}°C ⛄", alert_temp=60, interval=5)

status.register("cpu_usage",
                format=(" {{usage_cpu{}:3}}%" * 4).format(*range(4)),
                interval=2)
status.register("cpu_usage_bar", interval=2, hints=nosep)

status.register("mem", format=" {percent_used_mem}% ", color="#FFFFFF",
                interval=5)
#status.register("mem_bar", interval=5, hints=nosep)

status.run()
