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

namespace Pantheon.Keyboard.Shortcuts {

    private class CustomTree : Gtk.Viewport, DisplayTree {
        private static string enter_command = _("Enter Command");

        Gtk.Grid container;
        // Gtk.CellRendererText cell_desc;
        // Gtk.CellRendererAccel cell_edit;
        Gtk.ListBox tv;

        // Gtk.CellEditable command_editable;

        // enum Column {
        //     COMMAND,
        //     SHORTCUT,
        //     SCHEMA,
        //     COUNT
        // }

        ListStore list_store;

        public signal void row_selected ();
        public signal void row_unselected ();

        public signal void command_editing_started ();
        public signal void command_editing_ended ();

        public CustomTree () {
            setup_gui ();
            load_and_display_custom_shortcuts ();
            connect_signals ();
        }

        void setup_gui () {
            container = new Gtk.Grid ();
            list_store = new ListStore (typeof (CustomShortcut));

            tv = new Gtk.ListBox () {
                hexpand = true
            };
            tv.bind_model (list_store, create_custom_row);

            container.attach (tv, 0, 1, 1, 1);

            add (container);
        }

        public void load_and_display_custom_shortcuts () {
            list_store.remove_all ();

            foreach (var custom_shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
                list_store.append (custom_shortcut);
            }
        }

        void connect_signals () {
            // tv.button_press_event.connect ((event) => {
            //     if (event.window != tv.get_bin_window ())
            //         return false;
            //     Gtk.TreePath path;
            //     Gtk.TreeViewColumn col;

            //     if (tv.get_path_at_pos ((int) event.x, (int) event.y,
            //                             out path, out col, null, null)) {
            //         tv.grab_focus ();
            //         tv.set_cursor (path, col, true);
            //     }

            //     return true;
            // });

            // var selection = tv.get_selection ();
            // selection.changed.connect (() => {
            //     if (selection.count_selected_rows () > 0) {
            //         row_selected ();
            //     } else {
            //         row_unselected ();
            //     }
            // });

            // tv.key_press_event.connect (tree_key_press);

            // cell_edit.accel_edited.connect ((path, key, mods) => {
            //     var shortcut = new Shortcut (key, mods);
            //     change_shortcut (path, shortcut);
            // });

            // cell_edit.accel_cleared.connect ((path) => {
            //     change_shortcut (path, (Shortcut) null);
            // });

            // cell_desc.edited.connect ((path, new_text) => {
            //     change_command (path, new_text);
            //     command_editing_ended ();
            // });
            // cell_desc.editing_canceled.connect (() => {
            //     command_editing_ended ();
            //     command_editing_canceled ();
            // });

            // cell_desc.editing_started.connect ((cell_editable, path) => {
            //     // store a referene to retreve text later
            //     command_editable = cell_editable;
            //     command_editing_started ();
            // });
        }

        string command_to_display (string? command) {
            if (command == null || command.strip () == "")
                return "<i>" + enter_command + "</i>";
            return GLib.Markup.escape_text (command);
        }

        public void on_add_clicked () {
            // var store = tv.model as Gtk.ListStore;
            // Gtk.TreeIter iter;

            // var relocatable_schema = CustomShortcutSettings.create_shortcut ();

            // store.append (out iter);
            // store.set (iter, Column.COMMAND, command_to_display (null));
            // store.set (iter, Column.SHORTCUT, (new Shortcut.parse ("")).to_readable ());
            // store.set (iter, Column.SCHEMA, relocatable_schema);

            // var path = tv.model.get_path (iter);
            // var col = tv.get_column (Column.COMMAND);
            // tv.set_cursor (path, col, true);
        }

        public void on_remove_clicked () {
            // Gtk.TreeIter iter;
            // Gtk.TreePath path;

            // tv.get_cursor (out path, null);
            // tv.model.get_iter (out iter, path);
            // remove_shorcut_for_iter (iter);
        }

        void change_command (string path, string new_text) {
            // Gtk.TreeIter iter;
            // GLib.Value relocatable_schema;

            // tv.model.get_iter (out iter, new Gtk.TreePath.from_string (path));

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

        void remove_shorcut_for_iter (Gtk.TreeIter iter) {
//             GLib.Value relocatable_schema;
//             tv.model.get_value (iter, Column.SCHEMA, out relocatable_schema);

//             CustomShortcutSettings.remove_shortcut ((string) relocatable_schema);
// #if VALA_0_36
//             list_store.remove (ref iter);
// #else
//             list_store.remove (iter);
// #endif
//         }

//         bool tree_key_press (Gdk.EventKey ev) {
//             bool handled = false;
//             Gtk.Entry entry = command_editable as Gtk.Entry;

//             if (ev.keyval == Gdk.Key.Tab) {
//                 Gtk.TreePath path;
//                 tv.get_cursor (out path, null);

//                 cell_desc.edited (path.to_string (), entry.text);

//                 var col = tv.get_column (Column.SHORTCUT);
//                 tv.set_cursor (path, col, true);

//                 handled = true;
//             }

//             return handled;
        }

        public Gtk.Widget create_custom_row (Object item) {
            var custom_shortcut = (CustomShortcut)item;
            var row = new Gtk.ListBoxRow ();
            var grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                hexpand = true
            };

            var command_label = new Gtk.Label (custom_shortcut.command) { hexpand = true };
            var shortcut_label = new Gtk.Label (custom_shortcut.shortcut.to_readable ()) { hexpand = false };
            grid.add (command_label);
            grid.add (shortcut_label);
            row.add (grid);
            return row;
        } 
    }
}
