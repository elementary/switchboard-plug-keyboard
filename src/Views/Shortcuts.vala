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

    class Page : Pantheon.Keyboard.AbstractPage {
        construct {
            CustomShortcutSettings.init ();

            list = new List ();
            settings = new Shortcuts.Settings ();

            for (int id = 0; id < SectionID.CUSTOM; id++) {
                trees += new ShortcutListBox ((SectionID) id);
            }

            if (CustomShortcutSettings.available) {
                trees += new CustomTree ();
            }

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

            var shortcut_display = new ShortcutDisplay (trees);

            var frame = new Gtk.Frame (null);
            frame.add (shortcut_display);

            column_homogeneous = true;
            attach (switcher_frame, 0, 0);
            attach (frame, 1, 0, 2, 1);

            section_switcher.row_selected.connect ((row) => {
                shortcut_display.change_selection (row.get_index ());
            });
        }

        public override void reset () {
            for (int i = 0; i < SectionID.COUNT; i++) {
                var g = list.groups[i];

                for (int k = 0; k < g.actions.length; k++) {
                    settings.reset (g.schemas[k], g.keys[k]);
                }
            }
            return;
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
