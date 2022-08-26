/*
* Copyright 2022 elementary, Inc. (https://elementary.io)
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

private class Pantheon.Keyboard.Shortcuts.ShortcutListBox : Gtk.ListBox, ShortcutDisplayInterface {
    public Page shortcut_page { get; construct; } // Object with access to all shortcut views
    public SectionID group { get; construct; }

    private string[] actions;
    private Schema[] schemas;
    private string[] keys;

    public ShortcutListBox (SectionID group, Page shortcut_page) {
        Object (group: group, shortcut_page: shortcut_page);
    }

    construct {
        list.get_group (group, out actions, out schemas, out keys);

        var sizegroup = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);

        for (int i = 0; i < actions.length; i++) {
            var row = new ShortcutRow (actions[i], schemas[i], keys[i]);
            append (row);

            sizegroup.add_widget (row);
        }
    }

    public bool shortcut_conflicts (Shortcut shortcut, out string name, out string group) {
        string[] actions, keys;
        Schema[] schemas;

        name = "";
        group = this.group.to_string ();
        list.get_group (this.group, out actions, out schemas, out keys);

        // For every action in group there is a corresponding schema and key entry
        // so only need to iterate actions
        for (int i = 0; i < actions.length; i++) {
            var action_shortcut = settings.get_val (schemas[i], keys[i]);
            if (shortcut.is_equal (action_shortcut)) {
                name = actions[i];
                return true;
            }
        }

        return false;
    }

    private class ShortcutRow : Gtk.ListBoxRow {
        public string action { get; construct; }
        public Schema schema { get; construct; }
        public string gsettings_key { get; construct; }

        private Gtk.ModelButton clear_button;
        private Gtk.ModelButton reset_button;
        private Gtk.Box keycap_box;
        private Gtk.Label status_label;
        private Gtk.Stack keycap_stack;
        private bool is_editing_shortcut = false;
        private Gdk.Device? keyboard_device = null;

        public ShortcutRow (string action, Schema schema, string gsettings_key) {
            Object (
                action: action,
                schema: schema,
                gsettings_key: gsettings_key
            );
        }

        construct {
            var display = Gdk.Display.get_default ();
            if (display != null) {
                var seat = display.get_default_seat ();
                if (seat != null) {
                    keyboard_device = seat.get_keyboard ();
                }
            }
            var label = new Gtk.Label (action) {
                halign = Gtk.Align.START,
                hexpand = true
            };

            status_label = new Gtk.Label (_("Disabled")) {
                halign = Gtk.Align.END
            };
            status_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

            keycap_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END
            };

            keycap_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.CROSSFADE
            };
            keycap_stack.add_child (keycap_box);
            keycap_stack.add_child (status_label);


            var set_accel_button = new Gtk.ModelButton () {
                text = _("Set New Shortcut")
            };

            reset_button = new Gtk.ModelButton () {
                text = _("Reset to Default")
            };

            clear_button = new Gtk.ModelButton () {
                text = _("Disable")
            };
            clear_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var action_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                margin_top = 3,
                margin_bottom = 3
            };
            action_box.append (set_accel_button);
            action_box.append (reset_button);
            action_box.append (clear_button);

            var popover = new Gtk.Popover ();
            popover.set_child (action_box);

            var menubutton = new Gtk.MenuButton () {
                icon_name = "open-menu-symbolic",
                popover = popover,
            };
            menubutton.add_css_class (Granite.STYLE_CLASS_FLAT);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
                margin_top = 3,
                margin_end = 12, // Allow space for scrollbar to expand
                margin_bottom = 3,
                margin_start = 6,
                valign = Gtk.Align.CENTER
            };
            box.append (label);
            box.append (keycap_stack);
            box.append (menubutton);

            set_child (box);

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
                edit_shortcut (true);
            });

            keykcap_stack.button_release_event.connect (() => {
                edit_shortcut (true);
            });

            key_release_event.connect (on_key_released);

            focus_out_event.connect (() => {
                edit_shortcut (false);
                return Gdk.EVENT_PROPAGATE;
            });
        }

        private void edit_shortcut (bool start_editing) {
            //Ensure device grabs are paired
            if (start_editing && !is_editing_shortcut) {
                keycap_stack.visible_child = status_label;
                status_label.label = _("Enter new shortcut…");

                ((Gtk.ListBox)parent).select_row (this);
                grab_focus ();
                // Grab keyboard on this row's window
                if (keyboard_device != null) {
                    Gtk.device_grab_add (this, keyboard_device, true);
                    keyboard_device.get_seat ().grab (
                        get_window (), Gdk.SeatCapabilities.KEYBOARD, true, null, null, null
                    );
                } else {
                    return;
                }

                // previous_binding = gsettings.get_value (BINDING_KEY);
                // gsettings.set_string (BINDING_KEY, "");
            } else if (!start_editing && is_editing_shortcut) {
                // Stop grabbing keyboard on this row's window
                if (keyboard_device != null) {
                    keyboard_device.get_seat ().ungrab ();
                    Gtk.device_grab_remove (this, keyboard_device);
                }

                render_keycaps ();
            }

            is_editing_shortcut = start_editing;
        }

        private bool on_key_released (Gdk.EventKey event) {
            if (!is_editing_shortcut) {
                return Gdk.EVENT_STOP;
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
            render_keycaps ();

            return Gdk.EVENT_STOP;
        }

        private void update_binding (Shortcut shortcut) {
            string conflict_name = "";
            string group = "";
            var shortcut_listbox = (ShortcutListBox)parent;
            if (shortcut_listbox.custom_shortcut_conflicts (shortcut, out conflict_name, out group) ||
                shortcut_listbox.system_shortcut_conflicts (shortcut, out conflict_name, out group)) {

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
                    //  transient_for = (Gtk.Window) get_toplevel ()
                };

                message_dialog.response.connect (() => {
                    message_dialog.destroy ();
                });

                message_dialog.present ();
            } else {
                var key_value = settings.schemas[schema].get_value (gsettings_key);
                if (key_value.is_of_type (VariantType.ARRAY)) {
                    settings.schemas[schema].set_strv (gsettings_key, {shortcut.to_gsettings ()});
                } else {
                    settings.schemas[schema].set_string (gsettings_key, shortcut.to_gsettings ());
                }
            }
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
                var children = keycap_box.observe_children ();
                for (int i = 0; i < children.get_n_items (); i++) {
                    ((Gtk.Widget) children.get_item (i)).destroy ();
                }

                foreach (unowned string accel in accels) {
                    if (accel == "") {
                        continue;
                    }
                    var keycap_label = new Gtk.Label (accel);
                    keycap_label.add_css_class ("keycap");
                    keycap_box.append (keycap_label);
                }

                clear_button.sensitive = true;
                keycap_stack.visible_child = keycap_box;
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
