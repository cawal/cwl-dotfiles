import os
import re
import subprocess
from functools import partial

from libqtile import bar, hook, layout, qtile, widget
from libqtile.command import lazy
from libqtile.config import (Click, Drag, DropDown, Group, Key, KeyChord,EzKey,
                             Match, ScratchPad, Screen)
from libqtile.log_utils import logger
from libqtile.widget import base as widget_base

# https://patorjk.com/software/taag/#p=display&f=miniwi&t=CaWaL%20Qtile%20Config
load_config_banner = """
====================================
▄▖  ▖  ▖  ▖   ▄▖▗ ▘▜     ▄▖    ▐▘▘  
▌ ▀▌▌▞▖▌▀▌▌   ▌▌▜▘▌▐ █▌  ▌ ▛▌▛▌▜▘▌▛▌
▙▖█▌▛ ▝▌█▌▙▖  █▌▐▖▌▐▖▙▖  ▙▖▙▌▌▌▐ ▌▙▌
               ▘                  ▄▌
====================================
Starting config loading...
====================================
"""

load_complete_config_banner = """
===================================
Config loaded.
===================================
"""

logger.warning(load_config_banner)




from group_to_display_mapper import GroupToDisplayMapper
from host import get_xresources_variables, get_monitors
from qtile_vim_marks.manager import VimMarksManager

xresources = get_xresources_variables()
logger.warning(xresources)
monitors = get_monitors()
logger.warning(monitors)

###############################################
# MODIFIERS
###############################################
mod = "mod4"
___ = [] 
win_key = ["mod4"]
shift = ["shift"]
control = ["control"]
super = ["super"]
alt = ["Alt"]







font = "Hack"
font = "Noto Sans"
font_size = 12
color_highlight = "#F7941E"
color_urgent = color_highlight
color_white = "#DDDDDD"
color_grey = "#777777"
color_dark_grey = "#555555"
color_black = "#222222"


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

groups = [
    Group("1", persist=True),
    Group("2", persist=True),
    Group("3", persist=True),
    Group("4", persist=True),
    Group("5", persist=True),
    Group("6", persist=True),
    Group("7", persist=True),
    Group("8", persist=True),
    Group("9", persist=True),
    Group("0", persist=True),
]
mapper = GroupToDisplayMapper(groups)
marksManager = VimMarksManager(mapper.go_to_group)


search_bindings_config = "<b>Databases:</b> [h]ttp status codes, [b]ancos, [e]moticons, [c]lipboard, [t]imestamp from epoch, [d] display-controls"
search_bindings = [
    Key(___, "t", lazy.spawn("epoch-converter.sh")),
    Key(___, "h", lazy.spawn("dmenu-http-status-codes")),
    Key(___, "e", lazy.spawn("dmenu-emoticons")),
    Key(___, "s", lazy.spawn("dmenu-change-sound-output")),
    Key(___, "d", lazy.spawn("dmenu-display-control")),
    Key(___, "b", lazy.spawn("dmenu-bancos-brasileiros")),
    Key(___, "c",
        lazy.spawn(
            "rofi -modi 'clipboard:greenclip print'"
            " -show clipboard -run-command '{cmd}'"
        ),
    ),
]

keys = [
    Key(win_key, "Down", lazy.screen.next_group()),
    Key(win_key, "Up", lazy.screen.prev_group()),
    KeyChord( ___, "XF86Tools",
        [
            Key( ___, "p",
                lazy.spawn("notify-send Dunst stopped"),
                lazy.spawn("notify-send DUNST_COMMAND_PAUSE"),
            ),
            Key( ___, "r",
                lazy.spawn("notify-send DUNST_COMMAND_RESUME"),
                lazy.spawn("notify-send Dunst resumed"),
            ),
            Key(___, "s", lazy.spawn("dmenu-change-sound-output")),
            Key(___, "d", lazy.spawn("dmenu-display-control")),
        ],
        name="<b>Controls:</b> [p]ause notifications, [r]esume notifications, [s]ound outputs, [d]isplay light",
        mode=False,
    ),
    Key(___, "XF86AudioRaiseVolume", lazy.spawn("amixer -q -D pulse sset Master 5%+")),
    Key(___, "XF86AudioLowerVolume", lazy.spawn("amixer -q -D pulse sset Master 5%-")),
    Key(___, "XF86AudioMute", lazy.spawn("amixer -q -D pulse sset Master toggle")),
    Key(___, "XF86HomePage", lazy.group["scratchpad"].dropdown_toggle("Obsidian")),
    Key(___, "XF86Calculator", lazy.group["scratchpad"].dropdown_toggle("Python")),
    KeyChord(___, "XF86Search",
        search_bindings,
        name=search_bindings_config
    ),
    KeyChord(win_key, "c",
        search_bindings,
        name=search_bindings_config
    ),
    Key(win_key, "j",
        lazy.layout.down(),
        lazy.layout.left().when(layout="columns"),
    ),
    Key(win_key, "k",
        lazy.layout.up(),
        lazy.layout.right().when(layout="columns"),
    ),
    Key(win_key, "h",
        lazy.layout.left().when(layout="columns"),
    ),
    Key(win_key, "l",
        lazy.layout.right().when(layout="columns"),
    ),
    Key(win_key+shift, "j",
        lazy.layout.swap_column_left().when(layout="columns"),
    ),
    Key(win_key+shift, "k",
        lazy.layout.swap_column_right().when(layout="columns"),
    ),
    Key(win_key+shift, "h",
        lazy.layout.grow_left().when(layout="columns"),
    ),
    Key(win_key+shift, "l",
        lazy.layout.grow_right().when(layout="columns"),
    ),
    # Move windows up or down in current stack
    Key(win_key+control, "j",
        lazy.layout.shuffle_down(),
        desc="Move window down in the current stack",
    ),
    Key(win_key+control, "k",
        lazy.layout.shuffle_up(),
        desc="Move window up in the current stack",
    ),
    Key(win_key, "b",
        lazy.group["scratchpad"].dropdown_toggle("blueman-manager"),
        desc="Show bluetooth manager",
    ),
    Key(win_key, "v",
        lazy.group["scratchpad"].dropdown_toggle("pavucontrol"),
        desc="Show audio manager",
    ),
    Key(win_key, "l",
        lazy.group["scratchpad"].dropdown_toggle("qtile log"),
        desc="Show qtile logs",
    ),
    Key(win_key, "s",
        lazy.group["scratchpad"].dropdown_toggle("qtile shell"),
        desc="Show qtile shell",
    ),
    Key(win_key, "z",
        lazy.group["scratchpad"].dropdown_toggle("Obsidian"),
        desc="Show qtile shell",
    ),
    # Switch window focus to other pane(s) of stack
    Key(win_key, "space", lazy.layout.next()),
    # Swap panes of split stack
    Key(win_key+shift, "space", lazy.layout.rotate()),
    Key(win_key+control, "space",
        lazy.window.toggle_floating(),
        desc="Toggles floating state of window",
    ),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(win_key+control, "Return", lazy.layout.toggle_split()),
    Key(win_key, "Return", lazy.spawn("cwl-sensible-terminal")),
    Key(win_key+shift, "Return", lazy.spawn("cwl-sensible-terminal -e ranger")),
    Key(win_key, "d",
        lazy.spawn(
            "rofi -show-icons -modi combi -show combi -combi-modi window,run,drun"
        ),
    ),
    Key(win_key, "bracketleft", lazy.spawn("amixer -q -D pulse sset Master 5%+")),
    Key(win_key, "bracketright", lazy.spawn("amixer -q -D pulse sset Master 5%-")),
    Key(win_key, "BackSpace", lazy.spawn("amixer -q -D pulse sset Master toggle")),
    # Toggle between different layouts as defined below
    Key(win_key, "Tab", lazy.next_layout()),
    Key(win_key+shift, "Tab", lazy.prev_layout()),
    Key(win_key+shift, "q", lazy.window.kill()),
    Key(win_key, "r", lazy.spawncmd()),
    Key(___, "Print", lazy.spawn("flameshot gui")),
    KeyChord(win_key+control, "BackSpace",
        [
            Key(___, "l", lazy.spawn("i3exit lock")),
            Key(___, "s", lazy.spawn("i3exit suspend")),
            Key(shift, "h", lazy.spawn("i3exit hibernate")),
            Key(___, "r", lazy.restart()),
            Key(shift, "q", lazy.shutdown()),
        ],
        name="<b>Desktop:</b> [l]ock, [s]uspend, [H]ibernate, [r]estart, [Q]uit",
        mode=False,
    ),
    Key(win_key, "a",
        lazy.function(mapper.shift_group_display),
    ),
    Key(win_key, "q",
        lazy.function(mapper.rotate_all_groups_to_next_screen),
    ),
    KeyChord(win_key, "m",
        marksManager.get_mark_window_keys(),
        name="<b>Mark window</b> <i>Press a letter key</i>",
    ),
    KeyChord(win_key, "g",
        marksManager.get_goto_window_keys(),
        name="<b>Go to marked window</b> <i>Press a letter key</i>",
    ),
]


for i in groups:
    # mod1 + letter of group = switch to group
    keys.append(
        Key(win_key, i.name,
            lazy.function(
                partial(mapper.go_to_group, group=i.name),
            ),
        )
    )

    # mod1 + control + letter of group = switch to & move focused window to group
    keys.append(
        Key(win_key+shift, i.name,
            lazy.window.togroup(i.name),
        )
    )
    # mod1 + shift + letter of group = switch to & move focused window to group
    keys.append(
        Key(win_key+control, i.name,
            lazy.window.togroup(i.name),
            lazy.function(partial(mapper.go_to_group, group=i.name)),
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
                "Python",
                "cwl-sensible-terminal -e ipython",
                **{
                    **dropdown_config,
                    "x": 0.01,
                    "height": 0.98,
                    "width": 0.98,
                    "on_focus_lost_hide": False,
                },
            ),
            DropDown(
                "Ruby",
                "cwl-sensible-terminal -e irb",
                **{
                    **dropdown_config,
                    "x": 0.01,
                    "height": 0.98,
                    "width": 0.98,
                    "on_focus_lost_hide": False,
                },
            ),
            DropDown(
                "Obsidian",
                f"Obsidian.AppImage",
                **{
                    **dropdown_config,
                    "x": 0.01,
                    "height": 0.98,
                    "width": 0.98,
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
    # CWLTreeTab(**treetab_config),
    layout.Max(),
]

widget_defaults = dict(
    font=font,
    fontsize=font_size,
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

group_box_config = {
    "disable_drag": True,
    "highlight_method": "line",
    "highlight_color": [
        color_highlight,
        color_highlight,
    ],  # Active group highlight color when using 'line' highlight method
    "hide_unused": True,
}

task_list_config = {
    "borderwidth": 0,
    "border": color_black,
    "icon_size": 0,
    "markup_floating": f'<span foreground="{color_white}">[{{}}]</span>',
    "markup_focused": f'<span foreground="{color_white}">[{{}}]</span>',
    "markup_maximized": f'<span foreground="{color_grey}">{{}}</span>',
    "markup_minimized": f'<span foreground="{color_grey}">{{}}</span>',
    "markup_normal": f'<span foreground="{color_grey}">{{}}</span>',
    "highlight_method": "block",  # border|block
    "rounded": False,
}

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(**group_box_config),
                # TestCounterWidget(),
                separator_widget,
                widget.Chord(
                    background=color_urgent,
                    foreground=color_black,
                    name_transform=lambda t: " " + t.ljust(100),
                ),
                widget.Prompt(),
                separator_widget,
                # widget.WindowName(),
                # separator_widget,
                widget.TaskList(**task_list_config),
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
                widget.GroupBox(**group_box_config),
                separator_widget,
                widget.Prompt(),
                separator_widget,
                # widget.WindowName(),
                widget.TaskList(**task_list_config),
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
        win_key,
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        win_key, "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click(win_key, "Button2", lazy.window.bring_to_front()),
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

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

# ===========================================
# HOOKS
# ===========================================

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/bin/cwl-startup-processes.sh")
    subprocess.call([home])


@hook.subscribe.screens_reconfigured
def screens_reconfigured():
    mapper.calculate_initial_config()


@hook.subscribe.addgroup
def group_added(group_name: str):
    logger.warning(f"Group added: {group_name}")
    mapper.add_group(group_name)


@hook.subscribe.delgroup
def group_deleted(group_name: str):
    logger.warning(f"Group deleted: {group_name}")
    mapper.remove_group(group_name)


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




logger.warning(load_complete_config_banner)
