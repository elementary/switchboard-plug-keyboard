/*
* Copyright 2017-2022 elementary, Inc. (https://elementary.io)
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

class Pantheon.Keyboard.Shortcuts.CustomShortcutListBox : Gtk.ListBox, ShortcutDisplayInterface {
    public Page shortcut_page { get; construct; } // Object with access to all shortcut views

    public CustomShortcutListBox (Page shortcut_page) {
        Object (shortcut_page: shortcut_page);
    }

    construct {
        hexpand = true;
        load_and_display_custom_shortcuts ();
        selection_mode = Gtk.SelectionMode.BROWSE;

        realize.connect (() => {
            select_row (get_row_at_index (0));
        });
    }

    public void load_and_display_custom_shortcuts () {
        var children = observe_children ();
        for (int i = 0; i < children.get_n_items (); i ++) {
            var child = (Gtk.Widget) children.get_item (i);
            child.destroy ();
        }

        foreach (var custom_shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
            append (new CustomShortcutRow (custom_shortcut));
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

        append (new_row);
        select_row (new_row);
    }

    public void on_add_clicked () {
        add_row (null);
        unselect_all ();
    }

    // ShortcutDisplayInterface method
    public bool shortcut_conflicts (Shortcut shortcut, out string name, out string group) {
        name = "";
        group = SectionID.CUSTOM.to_string ();
        return CustomShortcutSettings.shortcut_conflicts (shortcut, out name, null);
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

        private Gtk.ModelButton clear_button;
        private Gtk.Box keycap_box;
        private Gtk.EventBox keycap_eventbox;
        private Gtk.EventBox status_eventbox;
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
            status_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            status_label.add_events (Gdk.EventMask.ALL_EVENTS_MASK);

            status_eventbox = new Gtk.EventBox ();
            status_eventbox.add (status_label);

            keycap_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END
            };
            keycap_eventbox = new Gtk.EventBox ();
            keycap_eventbox.add (keycap_box);

            // We create a dummy grid representing a long four key accelerator to force the stack in each row to the same size
            // This seems a bit hacky but it is hard to find a solution across rows not involving a hard-coded width value
            // (which would not take into account internationalization). This grid is never shown but controls the size of
            // of the homogeneous stack.
            var four_key_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) { // must have same format as keycap_box
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END
            };

            build_keycap_box ("<Shift><Alt><Control>F10", ref four_key_grid);

            keycap_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.CROSSFADE,
                hhomogeneous = true,
            };

            keycap_stack.add_child (four_key_grid); // This ensures sufficient space is allocated for longest reasonable shortcut
            keycap_stack.add_child (keycap_eventbox);
            keycap_stack.add_child (status_eventbox); // This becomes initial visible child

            var set_accel_button = new Gtk.ModelButton () {
                text = _("Set New Shortcut")
            };

            clear_button = new Gtk.ModelButton () {
                text = _("Disable")
            };
            clear_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var remove_button = new Gtk.ModelButton () {
                text = _("Remove")
            };
            remove_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var action_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                margin_top = 3,
                margin_bottom = 3
            };
            action_box.append (set_accel_button);
            action_box.append (clear_button);
            action_box.append (remove_button);

            var popover = new Gtk.Popover () {
                child = action_box
            };

            var menubutton = new Gtk.MenuButton () {
                icon_name = "open-menu-symbolic",
                popover = popover
            };
            menubutton.add_css_class (Granite.STYLE_CLASS_FLAT);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
                margin_top = 3,
                margin_bottom = 3,
                margin_start = 6,
                margin_end = 12, // Allow space for scrollbar to expand
                valign = Gtk.Align.CENTER
            };
            box.append (command_entry);
            box.append (keycap_stack);
            box.append (menubutton);
            child = box;

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

            keycap_eventbox.button_release_event.connect (() => {
                if (!is_editing_shortcut) {
                    edit_shortcut (true);
                }
            });

            status_eventbox.button_release_event.connect (() => {
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

            key_release_event.connect (on_key_released);

            focus_out_event.connect (() => {
                cancel_editing_shortcut ();
                return Gdk.EVENT_PROPAGATE;
            });
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

            keycap_stack.visible_child = is_editing_shortcut ? status_eventbox : keycap_eventbox;
            if (!is_editing_shortcut) {
                render_keycaps ();
            } else {
                status_label.label = _("Enter new shortcut…");
            }
        }

        private bool on_key_released (Gdk.EventKey event) {
            // For a custom shortcut, require modifier key(s) and one non-modifier key
            if (!is_editing_shortcut || event.is_modifier == 1) {
                return Gdk.EVENT_PROPAGATE;
            }

            var mods = event.state & Gtk.accelerator_get_default_mod_mask ();
            var keyval = event.keyval;
            if (mods > 0) {
                // Accept any key with a modifier (not all may work)
                Gdk.Keymap.get_for_display (Gdk.Display.get_default ()).add_virtual_modifiers (ref mods); // Not sure why this is needed

                var shortcut = new Pantheon.Keyboard.Shortcuts.Shortcut (keyval, mods);
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
                        // Accept certain keys as single key accelerators
                        var shortcut = new Pantheon.Keyboard.Shortcuts.Shortcut (keyval, mods);
                        update_binding (shortcut);
                        break;
                    default:
                        return Gdk.EVENT_STOP;
                }
            }

            edit_shortcut (false);

            return Gdk.EVENT_STOP;
         }

        private void update_binding (Shortcut shortcut) {
            string conflict_name = "";
            string group = "";
            string relocatable_schema = "";
            if (((CustomShortcutListBox)parent).system_shortcut_conflicts (shortcut, out conflict_name, out group)) {
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

                dialog.transient_for = (Gtk.Window) get_toplevel ();
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
                build_keycap_box (value_string, ref keycap_box);
                keycap_stack.visible_child = keycap_eventbox;
                clear_button.sensitive = true;
            } else {
                clear_button.sensitive = false;
                keycap_stack.visible_child = status_eventbox;
                status_label.label = _("Disabled");
            }
         }

        private void build_keycap_box (string value_string, ref Gtk.Box box) {
            var accels = Granite.accel_to_string (value_string).split (" + ");
            var children = box.observe_children ();
            for (int i = 0; i < children.get_n_items (); i++) {
                var child = (Gtk.Widget) children.get_item (i);
                child.destroy ();
            };

            foreach (unowned string accel in accels) {
                if (accel == "") {
                    continue;
                }
                var keycap_label = new Gtk.Label (accel);
                keycap_label.add_css_class ("keycap");
                box.append (keycap_label);
            }
        }
    }
}
