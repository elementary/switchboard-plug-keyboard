private class Pantheon.Keyboard.Shortcuts.CustomTree : Gtk.TreeView {

    Gtk.CellRendererText cell_desc;
    Gtk.CellRendererAccel cell_edit;

    enum Column {
        COMMAND,
        SHORTCUT,
        SCHEMA,
        COUNT
    }

    public CustomTree () {
        setup_gui ();
        load_and_display_custom_shortcuts ();
        connect_signals ();
    }

    void setup_gui () {
        var store = new Gtk.ListStore (Column.COUNT , typeof (string),
                                                      typeof (string),
                                                      typeof (string));

        cell_desc = new Gtk.CellRendererText ();
        cell_edit = new Gtk.CellRendererAccel ();

        cell_desc.editable = true;
        cell_edit.editable = true;
        cell_edit.accel_mode = Gtk.CellRendererAccelMode.OTHER;

        this.set_model (store);

        this.insert_column_with_attributes (-1, "Command", cell_desc, "markup", Column.COMMAND);
        this.insert_column_with_attributes (-1, "Shortcut", cell_edit, "text", Column.SHORTCUT);

        this.expand = true;
        this.get_column (0).expand = true;
    }

    void load_and_display_custom_shortcuts () {
        Gtk.TreeIter iter;
        var store = model as Gtk.ListStore;

        foreach (var custom_shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
            var shortcut = new Shortcut.parse (custom_shortcut.shortcut);

            store.append (out iter);
            store.set (iter,
                Column.COMMAND, command_to_display (custom_shortcut.command),
                Column.SHORTCUT, shortcut.to_readable (),
                Column.SCHEMA, custom_shortcut.relocatable_schema
            );
        }
    }

    void connect_signals () {
        this.button_press_event.connect ((event) => {
            if (event.window != this.get_bin_window ())
                return false;

            Gtk.TreePath path;
            Gtk.TreeViewColumn col;

            if (this.get_path_at_pos ((int) event.x,
                                      (int) event.y,
                                      out path, out col,
                                      null, null)) {
                this.grab_focus ();
                this.set_cursor (path, col, true);
            }

            return true;
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
        var store = model as Gtk.ListStore;
        Gtk.TreeIter iter;

        var relocatable_schema = CustomShortcutSettings.create_shortcut ();

        store.append (out iter);
        store.set (iter, Column.COMMAND, command_to_display (null));
        store.set (iter, Column.SHORTCUT, (new Shortcut.parse ("")).to_readable ());
        store.set (iter, Column.SCHEMA, relocatable_schema);
    }

    public void on_remove_clicked () {
        Gtk.TreeIter iter;
        Gtk.TreePath path;
        GLib.Value key, relocatable_schema;

        get_cursor (out path, null);
        model.get_iter (out iter, path);
        model.get_value (iter, Column.SCHEMA, out relocatable_schema);

        CustomShortcutSettings.remove_shortcut ((string) relocatable_schema);
        (model as Gtk.ListStore).remove (iter);
    }

    private void change_command (string path, string new_text) {
        Gtk.TreeIter iter;
        GLib.Value key, relocatable_schema;
        var display_new_text = command_to_display (new_text);

        model.get_iter (out iter, new Gtk.TreePath.from_string (path));
        model.get_value (iter, Column.SCHEMA, out relocatable_schema);

        CustomShortcutSettings.edit_command ((string) relocatable_schema, new_text);
        (model as Gtk.ListStore).set (iter, Column.COMMAND, display_new_text);
    }

    private bool change_shortcut (string path, Shortcut? shortcut) {
        Gtk.TreeIter iter;
        GLib.Value key, relocatable_schema;

        model.get_iter (out iter, new Gtk.TreePath.from_string (path));
        model.get_value (iter, Column.SCHEMA, out relocatable_schema);

        var not_null_shortcut = shortcut ?? new Shortcut.parse ("");

        CustomShortcutSettings.edit_shortcut
            ((string) relocatable_schema, not_null_shortcut.to_gsettings ());
        (model as Gtk.ListStore).set (iter, Column.SHORTCUT, not_null_shortcut.to_readable ());
        return true;
    }
}