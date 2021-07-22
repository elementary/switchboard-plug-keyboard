/*
* Copyright (c) 2017 elementary, LLC. (https://elementary.io)
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

class Pantheon.Keyboard.Shortcuts.CustomTree : Gtk.ListBox, DisplayTree {
    public signal void row_unselected ();
    public signal void editing_started ();
    public signal void editing_ended ();

    construct {
        hexpand = true;
        selection_mode = Gtk.SelectionMode.SINGLE;
        load_and_display_custom_shortcuts ();
        // Connect signals
    }

    public void load_and_display_custom_shortcuts () {
        foreach (Gtk.Widget child in get_children ()) {
            child.destroy ();
        }

        foreach (var custom_shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
            add (new CustomShortcutRow (custom_shortcut));
        }
    }

    private void add_row (CustomShortcut? shortcut) {
        CustomShortcutRow new_row;
        if (shortcut != null) {
            new_row = new CustomShortcutRow (shortcut);
        } else {
            var relocatable_schema = CustomShortcutSettings.create_shortcut ();
            var new_custom_shortcut = new CustomShortcut ("", "", relocatable_schema);
            new_row = new CustomShortcutRow (new_custom_shortcut);
        }

        new_row.notify["editing"].connect (() => {
            if (new_row.editing) {
                editing_started ();
            } else {
                editing_ended ();
            }
        });

        add (new_row);
        select_row (new_row);
    }

    public void on_add_clicked () {
        add_row (null);
    }

    public void on_remove_clicked () {
        var selected_row = get_selected_row ();
        if (selected_row != null) {
            var custom_shortcut_row = (CustomShortcutRow)selected_row;
            CustomShortcutSettings.remove_shortcut (custom_shortcut_row.relocatable_schema);
            selected_row.destroy ();
        }
    }

    public bool shortcut_conflicts (Shortcut shortcut, out string name) {
        return CustomShortcutSettings.shortcut_conflicts (shortcut, out name, null);
    }

    public void reset_shortcut (Shortcut shortcut) {
        string relocatable_schema;
        CustomShortcutSettings.shortcut_conflicts (shortcut, null, out relocatable_schema);
        CustomShortcutSettings.edit_shortcut (relocatable_schema, "");
        load_and_display_custom_shortcuts ();
    }

    private class CustomShortcutRow : Gtk.ListBoxRow {
        private const string BINDING_KEY = "binding";
        private const string COMMAND_KEY = "command";
        private const string NAME_KEY = "name";
        private Gtk.Entry command_entry;
        private Variant previous_binding;

        public string relocatable_schema { get; construct; }
        public GLib.Settings gsettings { get; construct; }
        public bool editing { get; set; default = false; }
        private Gtk.ModelButton clear_button;
        private Gtk.Grid keycap_grid;
        private Gtk.Label status_label;
        private Gtk.Stack keycap_stack;
        public CustomShortcutRow (CustomShortcut _custom_shortcut) {
            Object (
                relocatable_schema: _custom_shortcut.relocatable_schema,
                gsettings: CustomShortcutSettings.get_gsettings_for_relocatable_schema (_custom_shortcut.relocatable_schema)
            );

            command_entry.text = _custom_shortcut.command;
        }

        ~CustomShortcutRow () {
critical ("CustomShortcutRow destruct");
        }

        construct {
            command_entry = new Gtk.Entry () {
                max_width_chars = 500,
                hexpand = true,
                halign = Gtk.Align.START,
                placeholder_text = _("Enter a command here")
            };

            status_label = new Gtk.Label (_("Disabled")) {
                halign = Gtk.Align.END
            };
            status_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            keycap_grid = new Gtk.Grid () {
                column_spacing = 6,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END
            };

            keycap_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.CROSSFADE
            };
            keycap_stack.add (keycap_grid);
            keycap_stack.add (status_label);

            var set_accel_button = new Gtk.ModelButton () {
                text = _("Set New Shortcut")
            };

            clear_button = new Gtk.ModelButton () {
                text = _("Disable")
            };
            clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var action_grid = new Gtk.Grid () {
                margin_top = 3,
                margin_bottom = 3,
                orientation = Gtk.Orientation.VERTICAL
            };
            action_grid.add (set_accel_button);
            action_grid.add (clear_button);
            action_grid.show_all ();

            var popover = new Gtk.Popover (null);
            popover.add (action_grid);

            var menubutton = new Gtk.MenuButton () {
                image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU),
                popover = popover
            };
            menubutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var grid = new Gtk.Grid () {
                column_spacing = 12,
                margin = 3,
                margin_start = 6,
                margin_end = 6,
                valign = Gtk.Align.CENTER
            };
            grid.add (command_entry);
            grid.add (keycap_stack);
            grid.add (menubutton);
            grid.show_all ();

            add (grid);

            render_keycaps ();

            gsettings.changed[BINDING_KEY].connect (render_keycaps);
            gsettings.changed[COMMAND_KEY].connect (() => {
                var new_text = gsettings.get_string (COMMAND_KEY);
                if (new_text != command_entry.text) {
                    command_entry.text = new_text;
                }
            });

            clear_button.clicked.connect (() => {
                gsettings.set_string (BINDING_KEY, "");
            });

            set_accel_button.clicked.connect (() => {
                // Stop app triggering if same shortcut entered
                disable_binding ();
                keycap_stack.visible_child = status_label;
                status_label.label = _("Enter new shortcut…");
                grab_focus ();
                editing = true;
            });

            command_entry.changed.connect (() => {
                var command = command_entry.text;
                gsettings.set_string (COMMAND_KEY, command);
                gsettings.set_string (NAME_KEY, command);
            });

            command_entry.focus_in_event.connect (() => {
                editing = true;
                return Source.CONTINUE;
            });

            key_release_event.connect (on_key_pressed);

            focus_out_event.connect (() => {
                editing = false;
                return Source.CONTINUE;
            });

            show_all ();
        }

        private bool on_key_pressed (Gdk.EventKey key) {
            if (!editing) {
                return Gdk.EVENT_STOP;
            }

            if (key.keyval != Gdk.Key.Escape) {
                var key_state = key.state;
                Gdk.Keymap.get_for_display (Gdk.Display.get_default ()).add_virtual_modifiers (ref key_state);

                var shortcut = new Pantheon.Keyboard.Shortcuts.Shortcut (key.keyval, key_state);

                update_binding (shortcut);
            } else {
                restore_previous_binding ();
            }

            editing = false;
            render_keycaps ();

            return Gdk.EVENT_STOP;
         }

        private void disable_binding () {
            previous_binding = gsettings.get_value (BINDING_KEY);
            gsettings.set_string (BINDING_KEY, "");
        }

        private void restore_previous_binding () {
            gsettings.set_value (BINDING_KEY, previous_binding);
        }

        private void update_binding (Shortcut shortcut) {
            string conflict_name, relocatable_schema;
            if (CustomShortcutSettings.shortcut_conflicts (shortcut, out conflict_name, out relocatable_schema)) {
                var dialog = new ConflictDialog (shortcut.to_readable (), conflict_name, command_entry.text);
                dialog.reassign.connect (() => {
                    gsettings.set_string (BINDING_KEY, shortcut.to_gsettings ());
                });
                dialog.transient_for = (Gtk.Window) this.get_toplevel ();
                dialog.present ();
            }

            gsettings.set_string (BINDING_KEY, shortcut.to_gsettings ());
            // load_and_display_custom_shortcuts ();
        }

        private void render_keycaps () {
            var key_value = gsettings.get_value (BINDING_KEY);

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
         }
    }
}
