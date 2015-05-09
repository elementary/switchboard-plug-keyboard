namespace Pantheon.Keyboard.Shortcuts {

    private class CustomTree : Gtk.Viewport, DisplayTree {
        Gtk.Grid container;
        Gtk.CellRendererText cell_desc;
        Gtk.CellRendererAccel cell_edit;
        Gtk.InfoBar infobar;
        Gtk.TreeView tv;
        bool change_made = false;

        enum Column {
            COMMAND,
            SHORTCUT,
            SCHEMA,
            COUNT
        }

        Gtk.ListStore list_store {
            get { return tv.model as Gtk.ListStore; }
        }

        public signal void row_selected ();
        public signal void row_unselected ();

        public CustomTree () {
            setup_gui ();
            load_and_display_custom_shortcuts ();
            connect_signals ();
        }

        void setup_gui () {
            container = new Gtk.Grid ();

            infobar = new Gtk.InfoBar ();
            infobar.no_show_all = true;
            infobar.message_type = Gtk.MessageType.INFO;
            infobar.set_show_close_button (true);

            var info_container = infobar.get_content_area () as Gtk.Container;
            var info_label = new Gtk.Label (_("You need to logout and login for the changes to take effect"));
            info_container.add (info_label);

            tv = new Gtk.TreeView ();

            var store = new Gtk.ListStore (Column.COUNT , typeof (string),
                                           typeof (string),
                                           typeof (string));

            cell_desc = new Gtk.CellRendererText ();
            cell_edit = new Gtk.CellRendererAccel ();

            cell_desc.editable = true;
            cell_edit.editable = true;
            cell_edit.accel_mode = Gtk.CellRendererAccelMode.OTHER;

            tv.set_model (store);

            tv.insert_column_with_attributes (-1, _("Command"), cell_desc, "markup", Column.COMMAND);
            tv.insert_column_with_attributes (-1, _("Shortcut"), cell_edit, "text", Column.SHORTCUT);

            tv.expand = true;
            tv.get_column (0).expand = true;

            container.attach (infobar, 0, 0, 1, 1);
            container.attach (tv, 0, 1, 1, 1);

            add (container);
        }

        public void load_and_display_custom_shortcuts () {
            Gtk.TreeIter iter;
            var store = new Gtk.ListStore (Column.COUNT , typeof (string),
                                           typeof (string),
                                           typeof (string));

            foreach (var custom_shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
                var shortcut = new Shortcut.parse (custom_shortcut.shortcut);

                store.append (out iter);
                store.set (iter,
                           Column.COMMAND, command_to_display (custom_shortcut.command),
                           Column.SHORTCUT, shortcut.to_readable (),
                           Column.SCHEMA, custom_shortcut.relocatable_schema
                    );
            }

            tv.model = store;
        }

        void connect_signals () {
            infobar.response.connect ((id) => { infobar.hide (); });

            tv.button_press_event.connect ((event) => {
                if (event.window != tv.get_bin_window ())
                    return false;
                Gtk.TreePath path;
                Gtk.TreeViewColumn col;

                if (tv.get_path_at_pos ((int) event.x, (int) event.y,
                                        out path, out col, null, null)) {
                    tv.grab_focus ();
                    tv.set_cursor (path, col, true);
                }

                return true;
            });

            var selection = tv.get_selection ();
            selection.changed.connect (() => {
                if (selection.count_selected_rows () > 0) {
                    row_selected ();
                } else {
                    row_unselected ();
                }
            });

            cell_edit.accel_edited.connect ((path, key, mods) => {
                var shortcut = new Shortcut (key, mods);
                change_shortcut (path, shortcut);
            });

            cell_edit.accel_cleared.connect ((path) => {
                change_shortcut (path, (Shortcut) null);
            });

            cell_desc.edited.connect (change_command);
        }

        string command_to_display (string? command) {
            if (command == null || command.strip () == "")
                return "<i>" +_("Enter Command") + "</i>";
            return GLib.Markup.escape_text (command);
        }

        public void on_add_clicked () {
            var store = tv.model as Gtk.ListStore;
            Gtk.TreeIter iter;

            var relocatable_schema = CustomShortcutSettings.create_shortcut ();

            store.append (out iter);
            store.set (iter, Column.COMMAND, command_to_display (null));
            store.set (iter, Column.SHORTCUT, (new Shortcut.parse ("")).to_readable ());
            store.set (iter, Column.SCHEMA, relocatable_schema);
            on_change_made ();
        }

        public void on_remove_clicked () {
            Gtk.TreeIter iter;
            Gtk.TreePath path;
            GLib.Value relocatable_schema;

            tv.get_cursor (out path, null);
            tv.model.get_iter (out iter, path);
            tv.model.get_value (iter, Column.SCHEMA, out relocatable_schema);

            CustomShortcutSettings.remove_shortcut ((string) relocatable_schema);
            list_store.remove (iter);
            on_change_made ();
        }

        void change_command (string path, string new_text) {
            Gtk.TreeIter iter;
            GLib.Value relocatable_schema;

            tv.model.get_iter (out iter, new Gtk.TreePath.from_string (path));
            tv.model.get_value (iter, Column.SCHEMA, out relocatable_schema);

            CustomShortcutSettings.edit_command ((string) relocatable_schema, new_text);
            load_and_display_custom_shortcuts ();
            on_change_made ();
        }

        public bool shortcut_conflicts (Shortcut shortcut, out string name) {
            return CustomShortcutSettings.shortcut_conflicts (shortcut, out name, null);
        }

        public void reset_shortcut (Shortcut shortcut) {
            string relocatable_schema;
            CustomShortcutSettings.shortcut_conflicts (shortcut, null, out relocatable_schema);
            CustomShortcutSettings.edit_shortcut (relocatable_schema, "");
            load_and_display_custom_shortcuts ();
            on_change_made ();
        }

        bool change_shortcut (string path, Shortcut? shortcut) {
            Gtk.TreeIter iter;
            GLib.Value command, relocatable_schema;

            tv.model.get_iter (out iter, new Gtk.TreePath.from_string (path));
            tv.model.get_value (iter, Column.SCHEMA, out relocatable_schema);
            tv.model.get_value (iter, Column.COMMAND, out command);

            var not_null_shortcut = shortcut ?? new Shortcut ();

            string conflict_name;

            if (shortcut != null) {
                foreach (var tree in trees) {
                    if (tree.shortcut_conflicts (shortcut, out conflict_name) == false)
                        continue;

                    var dialog = new ConflictDialog (shortcut.to_readable (), conflict_name, (string) command);
                    dialog.reassign.connect (() => {
                            tree.reset_shortcut (shortcut);
                            CustomShortcutSettings.edit_shortcut ((string) relocatable_schema, not_null_shortcut.to_gsettings ());
                            load_and_display_custom_shortcuts ();
                        });
                    dialog.show ();
                    return false;
                }
            }

            CustomShortcutSettings.edit_shortcut ((string) relocatable_schema, not_null_shortcut.to_gsettings ());
            load_and_display_custom_shortcuts ();
            on_change_made ();
            return true;
        }

        
        void on_change_made () {
            if (!change_made) {
                change_made = true;
                infobar.get_content_area ().show_all ();
                infobar.show_now ();
            }
        }
    }
}