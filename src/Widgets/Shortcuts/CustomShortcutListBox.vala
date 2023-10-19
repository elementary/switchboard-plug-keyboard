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

class Keyboard.Shortcuts.CustomShortcutListBox : Gtk.ListBox {
    construct {
        hexpand = true;
        load_and_display_custom_shortcuts ();
        selection_mode = Gtk.SelectionMode.BROWSE;

        realize.connect (() => {
            select_row (get_row_at_index (0));
        });
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
            CustomShortcut new_custom_shortcut = {"", "", relocatable_schema};
            new_row = new CustomShortcutRow (new_custom_shortcut);
        }

        add (new_row);
        select_row (new_row);
    }

    public void on_add_clicked () {
        add_row (null);
        unselect_all ();
    }

    private class CustomShortcutRow : Gtk.ListBoxRow {
        private const string BINDING_KEY = "binding";
        private const string COMMAND_KEY = "command";
        private const string NAME_KEY = "name";
        private Gtk.Entry command_entry;
        private Variant previous_binding;
        private Gdk.Device? keyboard_device = null;

        public string relocatable_schema { get; construct; }
        public GLib.Settings gsettings { get; construct; }
        private bool is_editing_shortcut = false;

        private Gtk.EventControllerKey key_controller;
        private Gtk.GestureMultiPress keycap_controller;
        private Gtk.GestureMultiPress status_controller;

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

        construct {
            var display = Gdk.Display.get_default ();
            if (display != null) {
                var seat = display.get_default_seat ();
                if (seat != null) {
                    keyboard_device = seat.get_keyboard ();
                }
            }

            command_entry = new Gtk.Entry () {
                max_width_chars = 500,
                has_frame = false,
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

            // We create a dummy grid representing a long four key accelerator to force the stack in each row to the same size
            // This seems a bit hacky but it is hard to find a solution across rows not involving a hard-coded width value
            // (which would not take into account internationalization). This grid is never shown but controls the size of
            // of the homogeneous stack.
            var four_key_grid = new Gtk.Grid () { // must have same format as keycap_grid
                column_spacing = 6,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END
            };

            build_keycap_grid ("<Shift><Alt><Control>F10", ref four_key_grid);

            keycap_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.CROSSFADE,
                homogeneous = true
            };

            keycap_stack.add (four_key_grid); // This ensures sufficient space is allocated for longest reasonable shortcut
            keycap_stack.add (keycap_grid);
            keycap_stack.add (status_label); // This becomes initial visible child

            var set_accel_button = new Gtk.ModelButton () {
                text = _("Set New Shortcut")
            };

            clear_button = new Gtk.ModelButton () {
                text = _("Disable")
            };
            clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var remove_button = new Gtk.ModelButton () {
                text = _("Remove")
            };
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var action_grid = new Gtk.Grid () {
                margin_top = 3,
                margin_bottom = 3,
                orientation = Gtk.Orientation.VERTICAL
            };
            action_grid.add (set_accel_button);
            action_grid.add (clear_button);
            action_grid.add (remove_button);
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
                margin_end = 12, // Allow space for scrollbar to expand
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
                if (!is_editing_shortcut) {
                    gsettings.set_string (BINDING_KEY, "");
                }
            });

            remove_button.clicked.connect (() => {
                CustomShortcutSettings.remove_shortcut (relocatable_schema);
                destroy ();
            });

            set_accel_button.clicked.connect (() => {
                if (!is_editing_shortcut) {
                    edit_shortcut (true);
                }
            });

            keycap_controller = new Gtk.GestureMultiPress (keycap_stack);
            keycap_controller.released.connect (() => {
                if (!is_editing_shortcut) {
                    edit_shortcut (true);
                }
            });

            status_controller = new Gtk.GestureMultiPress (status_label);
            status_controller.released.connect (() => {
                if (!is_editing_shortcut) {
                    edit_shortcut (true);
                }
            });

            command_entry.focus_in_event.connect (() => {
                cancel_editing_shortcut ();
                ((Gtk.ListBox)parent).select_row (this);
                return Gdk.EVENT_PROPAGATE;
            });

            command_entry.changed.connect (() => {
                assert (is_editing_shortcut == false);
                var command = command_entry.text;
                gsettings.set_string (COMMAND_KEY, command);
                gsettings.set_string (NAME_KEY, command);
            });

            key_controller = new Gtk.EventControllerKey (this);
            key_controller.key_released.connect (on_key_released);

            focus_out_event.connect (() => {
                cancel_editing_shortcut ();
                return Gdk.EVENT_PROPAGATE;
            });

            show_all ();
        }

        private void cancel_editing_shortcut () {
            if (is_editing_shortcut) {
                gsettings.set_value (BINDING_KEY, previous_binding);
                edit_shortcut (false);
            }
        }

        private void edit_shortcut (bool start_editing) {
            //Ensure device grabs are paired
            if (start_editing && !is_editing_shortcut) {
                ((Gtk.ListBox)parent).select_row (this);
                grab_focus ();
                // Grab keyboard on this row's window
                if (keyboard_device != null) {
                    Gtk.device_grab_add (this, keyboard_device, true);
                    keyboard_device.get_seat ().grab (get_window (), Gdk.SeatCapabilities.KEYBOARD,
                                             true, null, null, null);
                } else {
                    return;
                }

                previous_binding = gsettings.get_value (BINDING_KEY);
                gsettings.set_string (BINDING_KEY, "");
            } else if (!start_editing && is_editing_shortcut) {
                // Stop grabbing keyboard on this row's window
                if (keyboard_device != null) {
                    keyboard_device.get_seat ().ungrab ();
                    Gtk.device_grab_remove (this, keyboard_device);
                } else {
                    return;
                }
            }

            is_editing_shortcut = start_editing;

            if (is_editing_shortcut) {
                keycap_stack.visible_child = status_label;
                status_label.label = _("Enter new shortcut…");
            } else {
                keycap_stack.visible_child = keycap_grid;
                render_keycaps ();
            }
        }

        private void on_key_released (Gtk.EventControllerKey controller, uint keyval, uint keycode, Gdk.ModifierType state) {
            // For a custom shortcut, require modifier key(s) and one non-modifier key
            if (!is_editing_shortcut) {
                return;
            }

            var mods = state & Gtk.accelerator_get_default_mod_mask ();
            if (mods > 0) {
                // Accept any key with a modifier (not all may work)
                Gdk.Keymap.get_for_display (Gdk.Display.get_default ()).add_virtual_modifiers (ref mods); // Not sure why this is needed

                var shortcut = new Keyboard.Shortcuts.Shortcut (keyval, mods);
                update_binding (shortcut);
            } else {
                switch (keyval) {
                    case Gdk.Key.Escape:
                        // Cancel editing
                        gsettings.set_value (BINDING_KEY, previous_binding);
                        break;
                    // case Gdk.Key.F1: May be used for system help
                    case Gdk.Key.F2:
                    case Gdk.Key.F3:
                    case Gdk.Key.F4:
                    case Gdk.Key.F5:
                    case Gdk.Key.F6:
                    case Gdk.Key.F7:
                    case Gdk.Key.F8:
                    case Gdk.Key.F9:
                    case Gdk.Key.F10:
                    // case Gdk.Key.F11: Already used for fullscreen
                    case Gdk.Key.F12:
                    case Gdk.Key.Menu:
                    case Gdk.Key.Print:
                        // Accept certain keys as single key accelerators
                        var shortcut = new Keyboard.Shortcuts.Shortcut (keyval, mods);
                        update_binding (shortcut);
                        break;
                    default:
                        return;
                }
            }

            edit_shortcut (false);

            return ;
         }

        private void update_binding (Shortcut shortcut) {
            string conflict_name = "";
            string group = "";
            string relocatable_schema = "";
            if (ConflictsManager.shortcut_conflicts (shortcut, out conflict_name, out group)) {
                var message_dialog = new Granite.MessageDialog (
                    _("Unable to set new shortcut due to conflicts"),
                    _("“%s” is already used for “%s → %s”.").printf (
                        shortcut.to_readable (), group, conflict_name
                    ),
                    new ThemedIcon ("preferences-desktop-keyboard"),
                    Gtk.ButtonsType.CLOSE
                ) {
                    badge_icon = new ThemedIcon ("dialog-error"),
                    modal = true,
                    transient_for = (Gtk.Window) get_toplevel ()
                };

                message_dialog.response.connect (() => {
                    message_dialog.destroy ();
                });

                message_dialog.present ();
                gsettings.set_value (BINDING_KEY, previous_binding);
                return;
            } else if (CustomShortcutSettings.shortcut_conflicts (shortcut, out conflict_name, out relocatable_schema)) {
                var dialog = new ConflictDialog (shortcut.to_readable (), conflict_name, command_entry.text);
                dialog.responded.connect ((response_id) => {
                    if (response_id == Gtk.ResponseType.ACCEPT) {
                        gsettings.set_string (BINDING_KEY, shortcut.to_gsettings ());
                        var conflict_gsettings = CustomShortcutSettings.get_gsettings_for_relocatable_schema (relocatable_schema);
                        conflict_gsettings.set_string (BINDING_KEY, "");
                    } else {
                        gsettings.set_value (BINDING_KEY, previous_binding);
                    }
                });

                dialog.transient_for = (Gtk.Window) this.get_toplevel ();
                dialog.present ();
            } else {
                gsettings.set_string (BINDING_KEY, shortcut.to_gsettings ());
            }
        }

        private void render_keycaps () {
            var key_value = gsettings.get_value (BINDING_KEY);
            var value_string = "";

            if (key_value.is_of_type (VariantType.ARRAY)) {
                var key_value_strv = key_value.get_strv ();
                if (key_value_strv.length > 0) {
                    value_string = key_value_strv[0];
                }
            } else {
                value_string = key_value.dup_string ();
            }

            if (value_string != "") {
                build_keycap_grid (value_string, ref keycap_grid);
                keycap_stack.visible_child = keycap_grid;
                clear_button.sensitive = true;
            } else {
                clear_button.sensitive = false;
                keycap_stack.visible_child = status_label;
                status_label.label = _("Disabled");
            }
         }

        private void build_keycap_grid (string value_string, ref Gtk.Grid grid) {
            var accels_string = Granite.accel_to_string (value_string);

            string[] accels = {};
            if (accels_string != null) {
                accels = accels_string.split (" + ");
            }
            foreach (unowned Gtk.Widget child in grid.get_children ()) {
                child.destroy ();
            };

            foreach (unowned string accel in accels) {
                if (accel == "") {
                    continue;
                }
                var keycap_label = new Gtk.Label (accel);
                keycap_label.get_style_context ().add_class ("keycap");
                grid.add (keycap_label);
            }

            grid.show_all ();
        }
    }
}
