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
    public signal void command_editing_started ();
    public signal void command_editing_ended ();

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

    public void on_add_clicked () {
        var relocatable_schema = CustomShortcutSettings.create_shortcut ();
        var new_custom_shortcut = new CustomShortcut ("", "", relocatable_schema);
        var new_row = new CustomShortcutRow (new_custom_shortcut);
        add (new_row);
        select_row (new_row);
    }

    public void on_remove_clicked () {
        var selected_row = get_selected_row ();
        if (selected_row != null) {
            selected_row.destroy ();
        }
    }

    void change_command (string path, string new_text) {
        // Gtk.TreeIter iter;
        // GLib.Value relocatable_schema;

        // model.get_iter (out iter, new Gtk.TreePath.from_string (path));

        // if (new_text == enter_command) {
        //     debug (new_text);
        //     // no changes were made, remove row
        //     remove_shorcut_for_iter (iter);

        // } else {
        //     tv.model.get_value (iter, Column.SCHEMA, out relocatable_schema);
        //     CustomShortcutSettings.edit_command ((string) relocatable_schema, new_text);
        //     load_and_display_custom_shortcuts ();
        // }
    }

    void command_editing_canceled () {
        // var selection = tv.get_selection ();
        // Gtk.TreeModel model;
        // Gtk.TreeIter iter;
        // Gtk.Entry entry = command_editable as Gtk.Entry;

        // if (selection.get_selected (out model, out iter)) {

        //     // if command is same as the default text, remove it
        //     if (entry.text == enter_command) {
        //         remove_shorcut_for_iter (iter);
        //     } else {
        //     Gtk.TreePath path;
        //     tv.get_cursor (out path, null);

        //     cell_desc.edited (path.to_string (), entry.text);
        //     }
        // }
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

    bool change_shortcut (string path, Shortcut? shortcut) {
        // Gtk.TreeIter iter;
        // GLib.Value command, relocatable_schema;

        // tv.model.get_iter (out iter, new Gtk.TreePath.from_string (path));
        // tv.model.get_value (iter, Column.SCHEMA, out relocatable_schema);
        // tv.model.get_value (iter, Column.COMMAND, out command);

        // var not_null_shortcut = shortcut ?? new Shortcut ();

        // string conflict_name;

        // if (shortcut != null) {
        //     foreach (var tree in trees) {
        //         if (tree.shortcut_conflicts (shortcut, out conflict_name) == false)
        //             continue;

        //         var dialog = new ConflictDialog (shortcut.to_readable (), conflict_name, (string) command);
        //         dialog.reassign.connect (() => {
        //                 tree.reset_shortcut (shortcut);
        //                 CustomShortcutSettings.edit_shortcut ((string) relocatable_schema, not_null_shortcut.to_gsettings ());
        //                 load_and_display_custom_shortcuts ();
        //             });
        //         dialog.transient_for = (Gtk.Window) this.get_toplevel ();
        //         dialog.present ();
        //         return false;
        //     }
        // }

        // CustomShortcutSettings.edit_shortcut ((string) relocatable_schema, not_null_shortcut.to_gsettings ());
        // load_and_display_custom_shortcuts ();
        return true;
    }

    private class CustomShortcutRow : Gtk.ListBoxRow {
        private const string BINDING_KEY = "binding";
        public CustomShortcut custom_shortcut { get; construct; }
        public GLib.Settings gsettings { get; construct; }
        private bool editing = false;
        private Gtk.ModelButton clear_button;
        // private Gtk.ModelButton reset_button;
        private Gtk.Grid keycap_grid;
        private Gtk.Label status_label;
        private Gtk.Stack keycap_stack;

        public CustomShortcutRow (CustomShortcut _custom_shortcut) {
            Object (
                custom_shortcut: _custom_shortcut,
                gsettings: CustomShortcutSettings.get_gsettings_for_relocatable_schema (_custom_shortcut.relocatable_schema)
            );
        }

        construct {
            var command_entry = new Gtk.Entry () {
                max_width_chars = 500,
                hexpand = true,
                halign = Gtk.Align.START,
                text = custom_shortcut.command,
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

            clear_button.clicked.connect (() => {
                gsettings.set_string (BINDING_KEY, "");
            });


            set_accel_button.clicked.connect (() => {
                keycap_stack.visible_child = status_label;
                status_label.label = _("Enter new shortcut…");
                editing = true;
            });
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
