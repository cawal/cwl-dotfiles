import os
import subprocess
from libqtile.log_utils import logger
from libqtile.config import (
    Key,
    Screen,
    Group,
    Drag,
    Click,
    KeyChord,
    ScratchPad,
    DropDown,
    Match,
)
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook, qtile
from host import GroupToDisplayMapper
from cwllayouts import CWLTreeTab
from qtile_vim_marks.manager import VimMarksManager

# from libqtile.command_client import CommandClient

font = "Hack"
color_highlight = "#F7941E"
color_urgent = color_highlight
color_white = "#DDDDDD"
color_grey = "#777777"
color_dark_grey = "#555555"
color_black = "#222222"


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/bin/cwl-startup-processes.sh")
    subprocess.call([home])


mod = "mod4"


def open_calendar():  # spawn calendar widget
    qtile.cmd_spawn("gnome-calendar")


def close_calendar():  # kill calendar widget
    qtile.cmd_spawn("killall -q gnome-calendar")


def add_group(name):
    def f(qtile):
        qtile.cmd_addgroup(name)

    return f


def remove_group(name):
    def f(qtile):
        qtile.groupMap.remove(name)

    return f


groups = [Group(i, persist=True) for i in "1234567890"]
mapper = GroupToDisplayMapper(groups)
marksManager = VimMarksManager(mapper.go_to_group)

keys = [
    Key(
        [mod],
        "j",
        lazy.layout.down(),
        lazy.layout.left().when(layout="columns"),
    ),
    Key(
        [mod],
        "k",
        lazy.layout.up(),
        lazy.layout.right().when(layout="columns"),
    ),
    Key(
        [mod],
        "h",
        lazy.layout.left().when(layout="columns"),
    ),
    Key(
        [mod],
        "l",
        lazy.layout.right().when(layout="columns"),
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.swap_column_left().when(layout="columns"),
    ),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.swap_column_right().when(layout="columns"),
    ),
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.grow_left().when(layout="columns"),
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.grow_right().when(layout="columns"),
    ),
    # Move windows up or down in current stack
    Key([mod, "control"], "j", lazy.layout.shuffle_down()),
    Key([mod, "control"], "k", lazy.layout.shuffle_up()),
    Key([mod], "z", lazy.group["scratchpad"].dropdown_toggle("Obsidian")),
    Key([mod], "b", lazy.group["scratchpad"].dropdown_toggle("blueman-manager")),
    Key([mod], "v", lazy.group["scratchpad"].dropdown_toggle("pavucontrol")),
    Key([mod], "l", lazy.group["scratchpad"].dropdown_toggle("qtile log")),
    Key([mod], "s", lazy.group["scratchpad"].dropdown_toggle("qtile shell")),
    # Switch window focus to other pane(s) of stack
    Key([mod], "space", lazy.layout.next()),
    # Swap panes of split stack
    Key([mod, "shift"], "space", lazy.layout.rotate()),
    Key(
        [mod, "control"],
        "space",
        lazy.window.toggle_floating(),
        desc="Toggles floating state of window",
    ),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "control"], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn("cwl-sensible-terminal")),
    Key([mod, "shift"], "Return", lazy.spawn("cwl-sensible-terminal -e ranger")),
    Key(
        [mod],
        "d",
        lazy.spawn(
            "rofi -show-icons -modi combi -show combi -combi-modi window,run,drun"
        ),
    ),
    Key([mod], "bracketleft", lazy.spawn("amixer -q -D pulse sset Master 5%+")),
    Key([mod], "bracketright", lazy.spawn("amixer -q -D pulse sset Master 5%-")),
    Key([mod], "BackSpace", lazy.spawn("amixer -q -D pulse sset Master toggle")),
    Key(
        [mod], "XF86AudioRaiseVolume", lazy.spawn("amixer -q -D pulse sset Master 5%+")
    ),
    Key(
        [mod], "XF86AudioLowerVolume", lazy.spawn("amixer -q -D pulse sset Master 5%-")
    ),
    Key([mod], "XF86AudioMute", lazy.spawn("amixer -q -D pulse sset Master toggle")),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod, "shift"], "Tab", lazy.prev_layout()),
    Key([mod, "shift"], "q", lazy.window.kill()),
    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),
    Key([], "Print", lazy.spawn("flameshot gui")),
    KeyChord(
        [mod],
        "w",
        # "personal databases"
        [
            Key([], "h", lazy.spawn("dmenu-http-status-codes")),
            Key([], "e", lazy.spawn("dmenu-emoticons")),
            Key([], "s", lazy.spawn("dmenu-change-sound-output")),
            Key([], "b", lazy.spawn("dmenu-display-control")),
            Key(
                [],
                "c",
                lazy.spawn(
                    "rofi -modi 'clipboard:greenclip print'"
                    " -show clipboard -run-command '{cmd}'"
                ),
            ),
        ],
        name="Personal databases",
    ),
    KeyChord(
        [mod, "shift"],
        "BackSpace",
        [
            Key(
                [],
                "l",
                lazy.spawn("i3exit lock"),
            ),
            Key(
                [],
                "s",
                lazy.spawn("i3exit suspend"),
            ),
            Key(
                ["shift"],
                "h",
                lazy.spawn("i3exit hibernate"),
            ),
        ],
        name="Desktop: l => lock, s=> suspend, H => hibernate",
        mode=False,
    ),
    KeyChord(
        [mod, "shift"],
        "n",
        [
            Key(
                [],
                "p",
                lazy.spawn("notify-send Dunst stopped"),
                lazy.spawn("notify-send DUNST_COMMAND_PAUSE"),
            ),
            Key(
                [],
                "r",
                lazy.spawn("notify-send DUNST_COMMAND_RESUME"),
                lazy.spawn("notify-send Dunst resumed"),
            ),
        ],
        name="<b>Notifications:</b> p => pause, r=> resume",
        mode=False,
    ),
    Key(
        [mod],
        "a",
        lazy.function(mapper.shift_group_display()),
    ),
    KeyChord([mod], "m", marksManager.get_mark_window_keys()),
    KeyChord([mod], "g", marksManager.get_goto_window_keys()),
]


for i in groups:
    # mod1 + letter of group = switch to group
    keys.append(Key([mod], i.name, lazy.function(mapper.go_to_group_func(i))))

    # mod1 + shift + letter of group = switch to & move focused window to group
    keys.append(
        Key(
            [mod, "shift"],
            i.name,
            lazy.window.togroup(i.name),
        )
    )
    # mod1 + ctrl + letter of group = switch to & move focused window to group
    keys.append(
        Key(
            [mod, "control"],
            i.name,
            lazy.window.togroup(i.name),
            lazy.function(mapper.go_to_group_func(i)),
        )
    )

dropdown_config = {
    "x": 0.2,
    "y": 0.0,
    "width": 0.6,
    "height": 0.4,
    "opacity": 1,
    "on_focus_lost_hide": True,
}

groups.append(
    ScratchPad(
        "scratchpad",
        [
            DropDown(
                "VimWiki",
                f"cwl-sensible-terminal -hold -e vi +VimwikiIndex",
                **{
                    **dropdown_config,
                    "x": 0.1,
                    "height": 1,
                    "width": 0.8,
                    "on_focus_lost_hide": False,
                },
            ),
            DropDown(
                "Obsidian",
                f"Obsidian.AppImage",
                **{
                    **dropdown_config,
                    "x": 0,
                    "height": 1,
                    "width": 1,
                    "on_focus_lost_hide": False,
                },
            ),
            DropDown(
                "pavucontrol",
                f"pavucontrol",
                **{
                    **dropdown_config,
                    "x": 0,
                    "height": 1,
                    "width": 0.5,
                    "on_focus_lost_hide": True,
                },
            ),
            DropDown(
                "qtile shell",
                "cwl-sensible-terminal -hold -e qtile shell",
                **dropdown_config,
            ),
            DropDown(
                "qtile log",
                f"cwl-sensible-terminal -hold -e tail -f {os.path.expanduser('~/.local/share/qtile/qtile.log')}",
                **dropdown_config,
            ),
            DropDown(
                "blueman-manager",
                f"blueman-manager",
                **{
                    **dropdown_config,
                    "x": 0,
                    "height": 1,
                    "width": 0.5,
                    "on_focus_lost_hide": True,
                },
            ),
        ],
    )
)

treetab_config = {
    "bg_color": color_black,
    "active_bg": color_white,
    "active_fg": color_black,
    "inactive_bg": color_black,
    "inactive_fg": color_white,
    "urgent_bg": color_black,
    "urgent_fg": color_urgent,
    "font": font,
    "fontsize": 12,
    "border_width": 0,
    "padding_left": 0,
    "margin_left": 0,
    "level_shift": 0,
    "section_padding": 0,
    "panel_width": 100,
    "previous_on_rm": True,
    "section_top": 0,
    "section_fg": color_black,
    "sections": [""],
}

columns_config = {
    "border_focus": color_grey,
    "border_normal": color_black,
    "num_columns": 10,
    "insert_position": 1,
    "border_on_single": False,
    "border_width": 1,
    "margin": 2,
}

floating_config = {
    "border_focus": color_urgent,
    "border_normal": color_black,
    "border_width": 2,
    "margin": 0,
}

layouts = [
    layout.Columns(**columns_config),
    CWLTreeTab(**treetab_config),
    #        layout.Max(),
]

widget_defaults = dict(
    font="Hack",
    fontsize=11,
    padding=1,
)

bar_height: int = 20

separator_widget = widget.Sep(foreground=color_black, linewidth=8, **widget_defaults)

pomodoro_widget = widget.Pomodoro(
    length_pomodori=25,
    length_short_break=5,
    num_pomodori=3,
    color_inactive=color_white,
    color_active=color_highlight,
    color_break=color_urgent,
    **widget_defaults,
)

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(),
                separator_widget,
                widget.Chord(
                    background=color_urgent,
                    foreground=color_black,
                    name_transform=lambda t: " " + t.ljust(100),
                ),
                widget.Prompt(),
                separator_widget,
                widget.WindowName(),
                separator_widget,
                widget.Volume(),
                separator_widget,
                pomodoro_widget,
                separator_widget,
                widget.Battery(format=" {char}{percent:2.0%} "),
                separator_widget,
                widget.Clock(
                    format="%Y-%m-%d %H:%M %p",
                    mouse_callbacks={
                        "Button1": open_calendar,
                        "Button2": close_calendar,
                    },
                ),
                separator_widget,
                widget.Systray(),
            ],
            bar_height,
            background=color_black,
            # wallpaper="/home/cawal/Imagens/0-Meus Desenhos/
        ),
    ),
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(),
                separator_widget,
                widget.Prompt(),
                separator_widget,
                widget.WindowName(),
                separator_widget,
                widget.Clock(format="%H:%M %p"),
            ],
            bar_height,
            background=color_black,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
main = None
follow_mouse_focus = False
bring_front_click = "floating_only"
cursor_warp = False
floating_layout = layout.Floating(
    **floating_config,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(
            wm_class="Eclipse",
            title="Find/Replace ",
        ),
        Match(
            wm_class="Eclipse",
            title="Find Actions ",
        ),
        Match(
            wm_class="Eclipse",
            title="Install ",
        ),
    ],
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# Rule objects to send windows to groups
dgroups_app_rules = []

# @hook.subscribe.client_new
# def test1(window):
#    logger.warning("test1 :")
#    logger.warning(dir(window))


#
#
# @hook.subscribe.client_new
# def test2(window):
#    logger.warning("test2 :")


# import psutil
# @hook.subscribe.client_new
# def _swallow(window):
#    """Imported from: https://github.com/GroosL/dotfiles/blob/main/config/qtile/config.py"""
#    pid = window.window.get_net_wm_pid()
#    ppid = psutil.Process(pid).ppid()
#    cpids = {c.window.get_net_wm_pid(): wid for wid, c in window.qtile.windows_map.items()}
#    for i in range(5):
#        if not ppid:
#            return
#        if ppid in cpids:
#            parent = window.qtile.windows_map.get(cpids[ppid])
#            parent.minimized = True
#            window.parent = parent
#            return
#        ppid = psutil.Process(ppid).ppid()
#
# @hook.subscribe.client_killed
# def _unswallow(window):
#    if hasattr(window, 'parent'):
#        window.parent.minimized = False

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
