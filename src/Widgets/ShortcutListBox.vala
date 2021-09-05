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

    public void reset_shortcut (Shortcut shortcut) {}

    private class ShortcutRow : Gtk.ListBoxRow {
        public string action { get; construct; }
        public Schema schema { get; construct; }
        public string gsettings_key { get; construct; }

        private bool editing = false;
        private Gtk.ModelButton clear_button;
        private Gtk.ModelButton reset_button;
        private Gtk.Grid keycap_grid;
        private Gtk.Label status_label;
        private Gtk.Stack keycap_stack;

        public ShortcutRow (string action, Schema schema, string gsettings_key) {
            Object (
                action: action,
                schema: schema,
                gsettings_key: gsettings_key
            );
        }

        construct {
            var label = new Gtk.Label (action);
            label.hexpand = true;
            label.halign = Gtk.Align.START;

            status_label = new Gtk.Label (_("Disabled"));
            status_label.halign = Gtk.Align.END;
            status_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            keycap_grid = new Gtk.Grid ();
            keycap_grid.column_spacing = 6;
            keycap_grid.valign = Gtk.Align.CENTER;
            keycap_grid.halign = Gtk.Align.END;

            keycap_stack = new Gtk.Stack ();
            keycap_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            keycap_stack.add (keycap_grid);
            keycap_stack.add (status_label);

            var set_accel_button = new Gtk.ModelButton ();
            set_accel_button.text = _("Set New Shortcut");

            reset_button = new Gtk.ModelButton ();
            reset_button.text = _("Reset to Default");

            clear_button = new Gtk.ModelButton ();
            clear_button.text = _("Disable");
            clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var action_grid = new Gtk.Grid ();
            action_grid.margin_top = action_grid.margin_bottom = 3;
            action_grid.orientation = Gtk.Orientation.VERTICAL;
            action_grid.add (set_accel_button);
            action_grid.add (reset_button);
            action_grid.add (clear_button);
            action_grid.show_all ();

            var popover = new Gtk.Popover (null);
            popover.add (action_grid);

            var menubutton = new Gtk.MenuButton ();
            menubutton.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
            menubutton.popover = popover;
            menubutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.margin = 3;
            grid.margin_start = grid.margin_end = 6;
            grid.valign = Gtk.Align.CENTER;
            grid.add (label);
            grid.add (keycap_stack);
            grid.add (menubutton);
            grid.show_all ();

            add (grid);

            render_keycaps ();

            settings.schemas[schema].changed[gsettings_key].connect (render_keycaps);

            clear_button.clicked.connect (() => {
                var key_value = settings.schemas[schema].get_value (gsettings_key);
                if (key_value.is_of_type (VariantType.ARRAY)) {
                    settings.schemas[schema].set_strv (gsettings_key, {""});
                } else {
                    settings.schemas[schema].set_string (gsettings_key, "");
                }
            });

            reset_button.clicked.connect (() => {
                settings.schemas[schema].reset (gsettings_key);
            });

            set_accel_button.clicked.connect (() => {
                keycap_stack.visible_child = status_label;
                status_label.label = _("Enter new shortcut…");
                editing = true;
            });

            key_release_event.connect (on_key_pressed);
        }

        private bool on_key_pressed (Gdk.EventKey key) {
            if (!editing) {
                return Gdk.EVENT_STOP;
            }

            var key_state = key.state;
            Gdk.Keymap.get_for_display (Gdk.Display.get_default ()).add_virtual_modifiers (ref key_state);

            var shortcut = new Pantheon.Keyboard.Shortcuts.Shortcut (key.keyval, key_state).to_gsettings ();

            var key_value = settings.schemas[schema].get_value (gsettings_key);
            if (key_value.is_of_type (VariantType.ARRAY)) {
                settings.schemas[schema].set_strv (gsettings_key, {shortcut});
            } else {
                settings.schemas[schema].set_string (gsettings_key, shortcut);
            }

            editing = false;
            render_keycaps ();

            return Gdk.EVENT_STOP;
        }

        private void render_keycaps () {
            var key_value = settings.schemas[schema].get_value (gsettings_key);

            string[] accels = {""};
            if (key_value.is_of_type (VariantType.ARRAY)) {
                var key_value_strv = key_value.get_strv ();
                if (key_value_strv.length > 0 && key_value_strv[0] != "") {
                    accels = Granite.accel_to_string (key_value_strv[0]).split (" + ");
                }
            } else {
                var value_string = key_value.dup_string ();
                if (value_string != "") {
                    accels = Granite.accel_to_string (value_string).split (" + ");
                }
            }

            if (accels[0] != "") {
                foreach (unowned Gtk.Widget child in keycap_grid.get_children ()) {
                    child.destroy ();
                };

                foreach (unowned string accel in accels) {
                    if (accel == "") {
                        continue;
                    }
                    var keycap_label = new Gtk.Label (accel);
                    keycap_label.get_style_context ().add_class ("keycap");
                    keycap_grid.add (keycap_label);
                }

                clear_button.sensitive = true;
                keycap_grid.show_all ();
                keycap_stack.visible_child = keycap_grid;
            } else {
                clear_button.sensitive = false;
                keycap_stack.visible_child = status_label;
                status_label.label = _("Disabled");
            }

            if (settings.schemas[schema].get_user_value (gsettings_key) == null) {
                reset_button.sensitive = false;
            } else {
                reset_button.sensitive = true;
            }
        }
    }
}