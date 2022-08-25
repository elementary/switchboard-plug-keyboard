/*
* Copyright 2017-2019 elementary, Inc. (https://elementary.io)
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
    // list of all shortcuts in gsettings, global object
    private List list;
    // class to interact with gsettings
    private Shortcuts.Settings settings;
    // array of shortcut views, one for each section
    private ShortcutDisplayInterface[] shortcut_views;

    public enum SectionID {
        WINDOWS,
        WORKSPACES,
        SCREENSHOTS,
        APPS,
        MEDIA,
        A11Y,
        SYSTEM,
        CUSTOM,
        COUNT;

        public string to_string () {
            switch (this) {
                case WINDOWS:
                    return (_("Windows"));
                case WORKSPACES:
                    return (_("Workspaces"));
                case SCREENSHOTS:
                    return (_("Screenshots"));
                case APPS:
                    return (_("Applications"));
                case MEDIA:
                    return (_("Media"));
                case A11Y:
                    return (_("Accessibility"));
                case SYSTEM:
                    return (_("System"));
                case CUSTOM:
                    return (_("Custom"));
                default:
                    return "";
            }
        }
    }

    class Page : Gtk.Grid {
        construct {
            CustomShortcutSettings.init ();

            list = new List ();
            settings = new Shortcuts.Settings ();

            var section_switcher = new Gtk.ListBox ();
            section_switcher.add (new SwitcherRow (list.windows_group));
            section_switcher.add (new SwitcherRow (list.workspaces_group));
            section_switcher.add (new SwitcherRow (list.screenshot_group));
            section_switcher.add (new SwitcherRow (list.launchers_group));
            section_switcher.add (new SwitcherRow (list.media_group));
            section_switcher.add (new SwitcherRow (list.a11y_group));
            section_switcher.add (new SwitcherRow (list.system_group));
            section_switcher.add (new SwitcherRow (list.custom_group));

            section_switcher.select_row (section_switcher.get_row_at_index (0));

            var scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.add (section_switcher);

            var switcher_frame = new Gtk.Frame (null);
            switcher_frame.add (scrolled_window);

            var stack = new Gtk.Stack ();
            stack.homogeneous = false;

            var scrolledwindow = new Gtk.ScrolledWindow (null, null);
            scrolledwindow.expand = true;
            scrolledwindow.add (stack);

            var add_button = new Gtk.Button.with_label (_("Add Shortcut")) {
                always_show_image = true,
                image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
                margin_top = 3,
                margin_bottom = 3
            };
            add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var actionbar = new Gtk.ActionBar ();
            actionbar.hexpand = true;
            actionbar.no_show_all = true;
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            actionbar.add (add_button);

            var action_grid = new Gtk.Grid ();
            action_grid.attach (scrolledwindow, 0, 0);
            action_grid.attach (actionbar, 0, 1);

            var frame = new Gtk.Frame (null);
            frame.add (action_grid);

            column_spacing = 12;
            column_homogeneous = true;
            attach (switcher_frame, 0, 0);
            attach (frame, 1, 0, 2, 1);

            for (int id = 0; id < SectionID.CUSTOM; id++) {
                shortcut_views += new ShortcutListBox ((SectionID) id, this);
            }

            if (CustomShortcutSettings.available) {
                var custom_tree = new CustomShortcutListBox (this);
                add_button.clicked.connect (() => custom_tree.on_add_clicked ());

                shortcut_views += custom_tree;
            }

            foreach (unowned Gtk.Widget view in shortcut_views) {
                stack.add (view);
            }

            section_switcher.row_selected.connect ((row) => {
                var index = row.get_index ();
                stack.visible_child = shortcut_views[index];

                actionbar.no_show_all = index != SectionID.CUSTOM;
                actionbar.visible = index == SectionID.CUSTOM;
                show_all ();
            });
        }

        public bool system_shortcut_conflicts (Shortcut shortcut, out string name, out string group) {
            name = "";
            group = "";
            foreach (var view in shortcut_views) {
                if (view is ShortcutListBox) {
                    if (view.shortcut_conflicts (shortcut, out name, out group)) {
                        return true;
                    }
                }
            }

            return false;
        }

        public bool custom_shortcut_conflicts (Shortcut shortcut, out string name, out string group) {
            name = "";
            group = "";
            foreach (var view in shortcut_views) {
                if (view is CustomShortcutListBox) {
                    if (view.shortcut_conflicts (shortcut, out name, out group)) {
                        return true;
                    }
                }
            }

            return false;
        }

        private class SwitcherRow : Gtk.ListBoxRow {
            public Pantheon.Keyboard.Shortcuts.Group group { get; construct; }

            public SwitcherRow (Pantheon.Keyboard.Shortcuts.Group group) {
                Object (group: group);
            }

            construct {
                var icon = new Gtk.Image.from_icon_name (group.icon_name, Gtk.IconSize.DND);

                var label = new Gtk.Label (group.label);
                label.xalign = 0;

                var grid = new Gtk.Grid ();
                grid.margin = 6;
                grid.column_spacing = 6;
                grid.add (icon);
                grid.add (label);

                add (grid);
            }
        }
    }
}
