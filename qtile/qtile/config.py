import os
import subprocess
from libqtile.log_utils import logger
from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile import layout, bar, widget,hook
from host import hostname,list_screens
#from libqtile.command_client import CommandClient

#c = CommandClient()

#def print_info():
#    print(c.screen.info()["index"])

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/bin/cwl-startup-processes.sh')
    subprocess.call([home])


mod = "mod4"


def go_to_group(group):
    def f(qtile):
        logger.warning(dir(qtile.groupMap[group.name]))
        screens = list_screens()
        logger.warning(screens)
        if group.name in "12345":
            qtile.cmd_to_screen(0)
            qtile.groupMap[group.name].cmd_toscreen()
        elif group.name in "67890" and len(screens) > 1:
            qtile.cmd_to_screen(1)
            qtile.groupMap[group.name].cmd_toscreen()
        else:
            qtile.cmd_to_screen(0)
            qtile.groupMap[group.name].cmd_toscreen()
    return f

def add_group(name):
    def f(qtile):
        qtile.cmd_addgroup(name)
    return f


def remove_group(name):
    def f(qtile):
        qtile.groupMap.remove(name)
    return f



keys = [
        # Switch between windows in current stack pane
        Key(
            [mod], "k",
            lazy.layout.down()
            ),
        Key(
            [mod], "j",
            lazy.layout.up()
            ),

        # Move windows up or down in current stack
        Key(
            [mod, "control"], "k",
            lazy.layout.shuffle_down()
            ),
        Key(
            [mod, "control"], "j",
            lazy.layout.shuffle_up()
            ),

        # Switch window focus to other pane(s) of stack
        Key(
            [mod], "space",
            lazy.layout.next()
            ),

        # Swap panes of split stack
        Key(
            [mod, "shift"], "space",
            lazy.layout.rotate()
            ),

        # Toggle between split and unsplit sides of stack.
        # Split = all windows displayed
        # Unsplit = 1 window displayed, like Max layout, but still with
        # multiple stack panes
        Key(
            [mod, "shift"], "Return",
            lazy.layout.toggle_split()
            ),
        Key([mod], "Return", lazy.spawn("cwl-sensible-terminal")),
        Key([mod, "shift"], "Return", lazy.spawn("cwl-sensible-terminal -e ranger")),
        Key([mod], "d", lazy.spawn("rofi -show-icons -modi combi -show combi -       combi-modi window,run,drun")),

        Key([mod],"bracketleft",lazy.spawn("amixer -q -D pulse sset Master 5%+")),
        Key([mod],"bracketright",lazy.spawn("amixer -q -D pulse sset Master 5%-")),
        Key([mod],"BackSpace",lazy.spawn("amixer -q -D pulse sset Master toggle")),
        Key([mod],"XF86AudioRaiseVolume",lazy.spawn("amixer -q -D pulse sset Master 5%+")),
        Key([mod],"XF86AudioLowerVolume",lazy.spawn("amixer -q -D pulse sset Master 5%-")),
        Key([mod],"XF86AudioMute",lazy.spawn("amixer -q -D pulse sset Master toggle")),

        # Toggle between different layouts as defined below
        Key([mod], "Tab", lazy.next_layout()),
        Key([mod], "w", lazy.window.kill()),

        Key([mod, "control"], "r", lazy.restart()),
        Key([mod, "control"], "q", lazy.shutdown()),
        Key([mod], "r", lazy.spawncmd()),
]

groups = [Group(i, persist=False) for i in "1234567890"]


for i in groups:
    # mod1 + letter of group = switch to group
    keys.append(
            #Key([mod], i.name, lazy.group[i.name].toscreen())
            Key([mod], i.name, lazy.function(go_to_group(i)))
            )

    # mod1 + shift + letter of group = switch to & move focused window to group
    keys.append(
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name))
            )

layouts = [
        layout.Max(),
        layout.Stack(num_stacks=2),
        ]

widget_defaults = dict(
        font='Hack',
        fontsize=11,
        padding=1,
        )

bar_height : int = 20

screens = [
        Screen(
            top=bar.Bar(
                [
                    widget.GroupBox(),
                    widget.Prompt(),
                    widget.WindowName(),
                    # widget.TextBox("default config", name="default"),
                    widget.Volume(),
                    widget.Clock(format='%Y-%m-%d %a %H:%M %p'),
                    widget.Systray(),
                    ],
                bar_height,
                background='#222222',
                #wallpaper='/home/cawal/Imagens/0-Meus Desenhos/
                ),
            ),
        Screen(
            top=bar.Bar(
                [
                    widget.GroupBox(),
                    widget.Prompt(),
                    widget.WindowName(),
                    # widget.TextBox("default config", name="default"),
                    widget.Clock(format='%H:%M %p'),
                    ],
                bar_height,
                background='#222222',
                ),
            ),
        ]

# Drag floating layouts.
mouse = [
        Drag([mod], "Button1", lazy.window.set_position_floating(),
            start=lazy.window.get_position()),
        Drag([mod], "Button3", lazy.window.set_size_floating(),
            start=lazy.window.get_size()),
        Click([mod], "Button2", lazy.window.bring_to_front())
        ]

dgroups_key_binder = None
dgroups_app_rules = []
main = None
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating()
auto_fullscreen = False
focus_on_window_activation = "smart"
extentions = []
reconfigure_screens = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"