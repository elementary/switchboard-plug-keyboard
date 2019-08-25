/*
* Copyright 2019 elementary, Inc. (https://elementary.io)
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

private class Pantheon.Keyboard.Shortcuts.ShortcutListBox : Gtk.ListBox, DisplayTree {
    public SectionID group { get; construct; }

    private string[] actions;
    private Schema[] schemas;
    private string[] keys;

    public ShortcutListBox (SectionID group) {
        Object (group: group);
    }

    construct {
        list.get_group (group, out actions, out schemas, out keys);

        load_and_display_shortcuts ();
    }

    private void load_and_display_shortcuts () {
        var sizegroup = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);

        for (int i = 0; i < actions.length; i++) {
            var row = new ShortcutRow (actions[i], schemas[i], keys[i]);
            add (row);

            sizegroup.add_widget (row);
        }

        show_all ();
    }

    public bool shortcut_conflicts (Shortcut shortcut, out string name) {
        string[] actions, keys;
        Schema[] schemas;

        name = "";

        list.get_group (group, out actions, out schemas, out keys);

        for (int i = 0; i < actions.length; i++) {
            if (shortcut.is_equal (settings.get_val (schemas[i], keys[i]))) {
                name = actions[i];
                return true;
            }
        }

        return false;
    }

    public void reset_shortcut (Shortcut shortcut) {
        string[] actions, keys;
        Schema[] schemas;
        var empty_shortcut = new Shortcut ();

        list.get_group (group, out actions, out schemas, out keys);

        for (int i = 0; i < actions.length; i++) {
            if (shortcut.is_equal (settings.get_val (schemas[i], keys[i]))) {
                settings.set_val (schemas[i], keys[i], empty_shortcut);
            }
        }

        load_and_display_shortcuts ();
    }

    private class ShortcutRow : Gtk.ListBoxRow {
        public string action { get; construct; }
        public Schema schema { get; construct; }
        public string key { get; construct; }

        public ShortcutRow (string action, Schema schema, string key) {
            Object (
                action: action,
                schema: schema,
                key: key
            );
        }

        construct {
            var label = new Gtk.Label (action);
            label.hexpand = true;
            label.halign = Gtk.Align.START;

            var shortcut = settings.get_val (schema, key);

            string[] accels = shortcut.to_readable ().split (" + ");

            var keycap_grid = new Gtk.Grid ();
            keycap_grid.column_spacing = 6;

            if (accels[0] != "" && accels[0] != _("Disabled")) {
                foreach (unowned string accel in accels) {
                    if (accel == "") {
                        continue;
                    }
                    var keycap_label = new Gtk.Label (accel);
                    keycap_label.get_style_context ().add_class ("keycap");
                    keycap_grid.add (keycap_label);
                }
            } else {
                var keycap_label = new Gtk.Label (_("Disabled"));
                keycap_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
                keycap_grid.add (keycap_label);
            }

            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.margin = 3;
            grid.margin_start = grid.margin_end = 6;
            grid.valign = Gtk.Align.CENTER;
            grid.add (label);
            grid.add (keycap_grid);

            add (grid);
        }
    }
}
