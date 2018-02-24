/*
* Copyright (c) 2017-2018 elementary, LLC. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Pantheon.Keyboard.Shortcuts {
    struct Group {
        public string[] actions;
        public Schema[] schemas;
        public string[] keys;
    }

    class List : GLib.Object {
        public Group[] groups;

        public List () {
            init_goups ();
        }

        public void get_group (SectionID group, out string[] a, out Schema[] s, out string[] k) {
            a = groups[group].actions;
            s = groups[group].schemas;
            k = groups[group].keys;
            return;
        }

        private void init_goups () {

            Group windows_group = {};
            add_action (ref windows_group, Schema.WM, _("Lower"), "lower");
            add_action (ref windows_group, Schema.WM, _("Maximize"), "maximize");
            add_action (ref windows_group, Schema.WM, _("Unmaximize"), "unmaximize");
            add_action (ref windows_group, Schema.WM, _("Toggle Maximized"), "toggle-maximized");
            add_action (ref windows_group, Schema.WM, _("Minimize"), "minimize");
            add_action (ref windows_group, Schema.WM, _("Toggle Fullscreen"), "toggle-fullscreen");
            add_action (ref windows_group, Schema.WM, _("Toggle on all Workspaces"), "toggle-on-all-workspaces");
            add_action (ref windows_group, Schema.WM, _("Toggle always on Top"), "toggle-above");
            add_action (ref windows_group, Schema.WM, _("Switch Windows"), "switch-windows");
            add_action (ref windows_group, Schema.WM, _("Switch Windows backwards"), "switch-windows-backward");
            add_action (ref windows_group, Schema.MUTTER, _("Tile Left"), "toggle-tiled-left");
            add_action (ref windows_group, Schema.MUTTER, _("Tile Right"), "toggle-tiled-right");
            add_action (ref windows_group, Schema.GALA, _("Window Overview"), "expose-windows");
            add_action (ref windows_group, Schema.GALA, _("Show All Windows"), "expose-all-windows");

            Group workspaces_group = {};
            add_action (ref workspaces_group, Schema.WM, _("Show Workspace Switcher"), "show-desktop");
            add_action (ref workspaces_group, Schema.GALA, _("Switch to first"), "switch-to-workspace-first");
            add_action (ref workspaces_group, Schema.GALA, _("Switch to new"), "switch-to-workspace-last");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 1"), "switch-to-workspace-1");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 2"), "switch-to-workspace-2");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 3"), "switch-to-workspace-3");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 4"), "switch-to-workspace-4");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 5"), "switch-to-workspace-5");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 6"), "switch-to-workspace-6");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 7"), "switch-to-workspace-7");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 8"), "switch-to-workspace-8");
            add_action (ref workspaces_group, Schema.WM, _("Switch to workspace 9"), "switch-to-workspace-9");
            add_action (ref workspaces_group, Schema.WM, _("Switch to left"), "switch-to-workspace-left");
            add_action (ref workspaces_group, Schema.WM, _("Switch to right"), "cycle-workspaces-previous");
            add_action (ref workspaces_group, Schema.GALA, _("Cycle workspaces"), "cycle-workspaces-next");
            add_action (ref workspaces_group, Schema.GALA, _("Cycle workspaces backwards"), "show-desktop");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 1"), "move-to-workspace-1");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 2"), "move-to-workspace-2");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 3"), "move-to-workspace-3");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 4"), "move-to-workspace-4");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 5"), "move-to-workspace-5");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 6"), "move-to-workspace-6");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 7"), "move-to-workspace-7");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 8"), "move-to-workspace-8");
            add_action (ref workspaces_group, Schema.WM, _("Move to workspace 9"), "move-to-workspace-9");
            add_action (ref workspaces_group, Schema.WM, _("Move to left"), "move-to-workspace-left");
            add_action (ref workspaces_group, Schema.WM, _("Move to right"), "move-to-workspace-right");

            Group screenshot_group = {};
            add_action (ref screenshot_group, Schema.MEDIA, _("Take a Screenshot"), "screenshot");
            add_action (ref screenshot_group, Schema.MEDIA, _("Save Screenshot to Clipboard"), "screenshot-clip");
            add_action (ref screenshot_group, Schema.MEDIA, _("Take a Screenshot of a Window"), "window-screenshot");
            add_action (ref screenshot_group, Schema.MEDIA, _("Save Window-Screenshot to Clipboard"), "window-screenshot-clip");
            add_action (ref screenshot_group, Schema.MEDIA, _("Take a Screenshot of an Area"), "area-screenshot");
            add_action (ref screenshot_group, Schema.MEDIA, _("Save Area-Screenshot to Clipboard"), "area-screenshot-clip");

            Group launchers_group = {};
            add_action (ref launchers_group, Schema.MEDIA, _("Calculator"), "calculator");
            add_action (ref launchers_group, Schema.MEDIA, _("Email"), "email");
            add_action (ref launchers_group, Schema.MEDIA, _("Help"), "help");
            add_action (ref launchers_group, Schema.MEDIA, _("Home Folder"), "home");
            add_action (ref launchers_group, Schema.MEDIA, _("File Search"), "search");
            add_action (ref launchers_group, Schema.MEDIA, _("Terminal"), "terminal");
            add_action (ref launchers_group, Schema.MEDIA, _("Internet Browser"), "www");
            add_action (ref launchers_group, Schema.WM, _("Applications Launcher"), "panel-main-menu");

            Group media_group = {};
            add_action (ref media_group, Schema.MEDIA, _("Volume Up"), "volume-up");
            add_action (ref media_group, Schema.MEDIA, _("Volume Down"), "volume-down");
            add_action (ref media_group, Schema.MEDIA, _("Mute"), "volume-mute");
            add_action (ref media_group, Schema.MEDIA, _("Launch Media Player"), "media");
            add_action (ref media_group, Schema.MEDIA, _("Play"), "play");
            add_action (ref media_group, Schema.MEDIA, _("Pause"), "pause");
            add_action (ref media_group, Schema.MEDIA, _("Stop"), "stop");
            add_action (ref media_group, Schema.MEDIA, _("Previous Track"), "previous");
            add_action (ref media_group, Schema.MEDIA, _("Next Track"), "next");
            add_action (ref media_group, Schema.MEDIA, _("Stop"), "eject");

            Group a11y_group = {};
            add_action (ref a11y_group, Schema.MEDIA, _("Decrease Text Size"), "decrease-text-size");
            add_action (ref a11y_group, Schema.MEDIA, _("Increase Text Size"), "increase-text-size");
            add_action (ref a11y_group, Schema.MEDIA, _("Magnifier Zoom in"), "zoom-in");
            add_action (ref a11y_group, Schema.MEDIA, _("Magnifier Zoom out"), "zoom-out");
            add_action (ref a11y_group, Schema.MEDIA, _("Toggle On Screen Keyboard"), "on-screen-keyboard");
            add_action (ref a11y_group, Schema.MEDIA, _("Toggle Screenreader"), "screenreader");
            add_action (ref a11y_group, Schema.MEDIA, _("Toggle High Contrast"), "toggle-contrast");

            groups = {
                windows_group,
                workspaces_group,
                screenshot_group,
                launchers_group,
                media_group,
                a11y_group
            };
        }

        public void add_action (ref Group group, Schema schema, string action, string key) {
            group.keys += key;
            group.schemas += schema;
            group.actions += action;
        }
    }
}
