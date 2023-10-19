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

namespace Keyboard.Shortcuts {
    // array of shortcut views, one for each section
    private Gtk.ListBox[] shortcut_views;

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

    class Page : Gtk.Box {
        private Gtk.ListBox section_switcher;
        private SwitcherRow custom_shortcuts_row;

        construct {
            CustomShortcutSettings.init ();

            unowned var list = Shortcuts.ShortcutsList.get_default ();

            section_switcher = new Gtk.ListBox ();
            section_switcher.add (new SwitcherRow (list.windows_group));
            section_switcher.add (new SwitcherRow (list.workspaces_group));
            section_switcher.add (new SwitcherRow (list.screenshot_group));
            section_switcher.add (new SwitcherRow (list.launchers_group));
            section_switcher.add (new SwitcherRow (list.media_group));
            section_switcher.add (new SwitcherRow (list.a11y_group));
            section_switcher.add (new SwitcherRow (list.system_group));

            custom_shortcuts_row = new SwitcherRow (list.custom_group);
            section_switcher.add (custom_shortcuts_row);

            var switcher_scrolled = new Gtk.ScrolledWindow (null, null) {
                child = section_switcher,
                hscrollbar_policy = NEVER
            };

            var switcher_frame = new Gtk.Frame (null) {
                child = switcher_scrolled
            };

            var stack = new Gtk.Stack () {
                homogeneous = false, // Prevents extra scrollbar in short lists
                vexpand = true
            };

            var stack_scrolled = new Gtk.ScrolledWindow (null, null) {
                child = stack
            };

            var add_button_label = new Gtk.Label (_("Add Shortcut"));

            var add_button_box = new Gtk.Box (HORIZONTAL, 0);
            add_button_box.add (new Gtk.Image.from_icon_name ("list-add-symbolic", BUTTON));
            add_button_box.add (add_button_label);

            var add_button = new Gtk.Button () {
                child = add_button_box,
                margin_top = 3,
                margin_bottom = 3
            };
            add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            add_button_label.mnemonic_widget = add_button;

            var actionbar = new Gtk.ActionBar () {
                hexpand = true
            };
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            actionbar.pack_start (add_button);

            var action_box = new Gtk.Box (VERTICAL, 0);
            action_box.add (stack_scrolled);
            action_box.add (actionbar);

            var frame = new Gtk.Frame (null) {
                child = action_box
            };

            spacing = 12;
            margin_start = 12;
            margin_end = 12;
            margin_bottom = 12;
            add (switcher_frame);
            add (frame);

            for (int id = 0; id < SectionID.CUSTOM; id++) {
                shortcut_views += new ShortcutListBox ((SectionID) id);
            }

            if (CustomShortcutSettings.available) {
                var custom_tree = new CustomShortcutListBox ();
                add_button.clicked.connect (() => custom_tree.on_add_clicked ());

                shortcut_views += custom_tree;
            }

            foreach (unowned Gtk.Widget view in shortcut_views) {
                stack.add (view);
            }

            section_switcher.row_selected.connect ((row) => {
                var index = row.get_index ();
                stack.visible_child = shortcut_views[index];

                actionbar.visible = stack.visible_child is CustomShortcutListBox;
            });

            // Doing this too early makes the actionbar show by default
            realize.connect (() => {
                section_switcher.select_row (section_switcher.get_row_at_index (0));
            });
        }

        public void open_custom_shortcuts () {
            section_switcher.select_row (custom_shortcuts_row);
        }

        private class SwitcherRow : Gtk.ListBoxRow {
            public Keyboard.Shortcuts.Group group { get; construct; }

            public SwitcherRow (Keyboard.Shortcuts.Group group) {
                Object (group: group);
            }

            construct {
                var icon = new Gtk.Image.from_icon_name (group.icon_name, Gtk.IconSize.DND);

                var label = new Gtk.Label (group.label) {
                    xalign = 0
                };

                var box = new Gtk.Box (HORIZONTAL, 6) {
                    margin = 6
                };
                box.add (icon);
                box.add (label);

                child = box;
            }
        }
    }
}
