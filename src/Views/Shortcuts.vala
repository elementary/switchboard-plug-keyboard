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
    // array of tree views, one for each section
    private DisplayTree[] trees;

    private enum SectionID {
        WINDOWS,
        WORKSPACES,
        SCREENSHOTS,
        APPS,
        MEDIA,
        A11Y,
        SYSTEM,
        CUSTOM,
        COUNT
    }

    class Page : Gtk.Grid {
        private Gtk.Button add_button;
        private Gtk.Button remove_button;

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

            add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            add_button.tooltip_text = _("Add");

            remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            remove_button.sensitive = false;
            remove_button.tooltip_text = _("Remove");

            var actionbar = new Gtk.ActionBar ();
            actionbar.hexpand = true;
            actionbar.no_show_all = true;
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            actionbar.add (add_button);
            actionbar.add (remove_button);

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
                trees += new Tree ((SectionID) id);
            }

            if (CustomShortcutSettings.available) {
                var custom_tree = new CustomTree ();
                custom_tree.row_selected.connect (row_selected);
                custom_tree.row_unselected.connect (row_unselected);

                custom_tree.command_editing_started.connect (disable_add);
                custom_tree.command_editing_ended.connect (enable_add);

                add_button.clicked.connect (() => custom_tree.on_add_clicked ());
                remove_button.clicked.connect (() => custom_tree.on_remove_clicked ());

                trees += custom_tree;
            }

            foreach (unowned Gtk.Widget tree in trees) {
                stack.add (tree);
            }

            section_switcher.row_selected.connect ((row) => {
                var index = row.get_index ();
                stack.visible_child = trees[index];

                actionbar.no_show_all = index != SectionID.CUSTOM;
                actionbar.visible = index == SectionID.CUSTOM;
                show_all ();
            });
        }

        private void row_selected () {
            remove_button.sensitive = true;
        }

        private void row_unselected () {
            remove_button.sensitive = false;
        }

        private void disable_add () {
            add_button.sensitive = false;
        }

        private void enable_add () {
            add_button.sensitive = true;
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
