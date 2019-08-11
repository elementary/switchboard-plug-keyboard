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

    private class ApplicationTree : Gtk.Viewport, DisplayTree {
        Gtk.CellRendererText cell_desc;
        Gtk.CellRendererAccel cell_edit;
        Gtk.CellRendererPixbuf cell_icon;
        Gtk.TreeView tv;
        Gtk.TreeView tv2;

        enum Column {
            NAME,
            DESKTOP_ID,
            SHORTCUT,
            ICON,
            KEY,
            COUNT,
        }

        Gtk.ListStore list_store {
            get { return tv.model as Gtk.ListStore; }
        }

        public signal void row_selected ();
        public signal void row_unselected ();

        public ApplicationTree () {
            setup_gui ();
            load_and_display_shortcuts ();
            connect_signals ();
        }

        void setup_gui () {
            var container = new Gtk.Grid ();

            tv = new Gtk.TreeView ();

            var store = new Gtk.ListStore (Column.COUNT,
                                           typeof (string),
                                           typeof (string),
                                           typeof (string),
                                           typeof (GLib.Icon),
                                           typeof (string));

            cell_desc = new Gtk.CellRendererText ();
            cell_edit = new Gtk.CellRendererAccel ();
            cell_icon = new Gtk.CellRendererPixbuf ();

            cell_desc.editable = false;
            cell_edit.editable = true;
            cell_edit.accel_mode = Gtk.CellRendererAccelMode.OTHER;

            tv.set_model (store);

            tv.insert_column_with_attributes (-1, _("Icon"), cell_icon, "gicon", Column.ICON);
            tv.insert_column_with_attributes (-1, _("Command"), cell_desc, "markup", Column.NAME);
            tv.insert_column_with_attributes (-1, _("Shortcut"), cell_edit, "text", Column.SHORTCUT);

            tv.headers_visible = false;
            tv.expand = true;
            tv.get_column (1).expand = true;

            container.attach (tv, 0, 1, 1, 1);

            add (container);
        }

        public void load_and_display_shortcuts () {
            Gtk.TreeIter iter;
            var store = list_store;

            store.clear ();

            foreach (var default_shortcut in ApplicationShortcutSettings.list_default_shortcuts ()) {
                var shortcut = new Shortcut.parse (default_shortcut.shortcut);

                if (shortcut == null)
                    continue;

                debug ("before");
                var desktop_id = default_shortcut.desktop_id;
                debug ("after %s", desktop_id);
                var desktop_appinfo = new DesktopAppInfo (desktop_id);
                debug ("after2");
                store.append (out iter);
                store.set (iter,
                           Column.NAME, default_shortcut.name,
                           Column.DESKTOP_ID, default_shortcut.desktop_id,
                           Column.SHORTCUT, shortcut.to_readable (),
                           Column.ICON, desktop_appinfo.get_icon (),
                           Column.KEY, default_shortcut.key
                    );
            }

            foreach (var custom_shortcut in ApplicationShortcutSettings.list_custom_shortcuts ()) {
                var shortcut = new Shortcut.parse (custom_shortcut.shortcut);

                //  var icon = Gtk.IconTheme.get_default ().load_icon ("folder", 16, 0);
                var desktop_appinfo = new DesktopAppInfo (custom_shortcut.desktop_id);
                store.append (out iter);
                store.set (iter,
                           Column.NAME, custom_shortcut.name,
                           Column.DESKTOP_ID, custom_shortcut.desktop_id,
                           Column.SHORTCUT, shortcut.to_readable (),
                           Column.ICON, desktop_appinfo.get_icon (),
                           Column.KEY, custom_shortcut.key
                    );
            }
        }

        void connect_signals () {
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
        }


        AppInfo? get_app_info_dialog () {
            Gtk.AppChooserDialog dialog = new Gtk.AppChooserDialog.for_content_type ((Gtk.Window) this.get_toplevel (), 0, "");
            ((Gtk.AppChooserWidget) dialog.get_widget ()).show_all = true;
            AppInfo? info = null;
            if (dialog.run () == Gtk.ResponseType.OK) {
                info = dialog.get_app_info ();
            }
            dialog.close ();
            return info;
        }

        public void on_add_clicked () {
            var info = get_app_info_dialog ();
            if (info == null)
                return;

            var store = tv.model as Gtk.ListStore;
            Gtk.TreeIter iter;
            var key = ApplicationShortcutSettings.create_shortcut (info);
            debug ("the key is %s", key);

            if (key == null)
                return;

            store.append (out iter);
            store.set (iter, Column.DESKTOP_ID, info.get_name ());
            store.set (iter, Column.SHORTCUT, (new Shortcut.parse ("")).to_readable ());
            store.set (iter,  Column.KEY, key);

            load_and_display_shortcuts ();
        }

        public void on_remove_clicked () {
            Gtk.TreeIter iter;
            Gtk.TreePath path;

            tv.get_cursor (out path, null);
            tv.model.get_iter (out iter, path);
            remove_shortcut_for_iter (iter);
        }

        public bool shortcut_conflicts (Shortcut shortcut, out string name) {
            return ApplicationShortcutSettings.shortcut_conflicts (shortcut, out name, null);
        }

        public void reset_shortcut (Shortcut shortcut) {
            string key;
            CustomShortcutSettings.shortcut_conflicts (shortcut, null, out key);
            CustomShortcutSettings.edit_shortcut (key, "");
            load_and_display_shortcuts ();
        }

        public bool change_shortcut (string path, Shortcut? shortcut) {
            Gtk.TreeIter  iter;
            GLib.Value    key, name;

            tv.model.get_iter (out iter, new Gtk.TreePath.from_string (path));

            tv.model.get_value (iter, Column.NAME, out name);
            tv.model.get_value (iter, Column.KEY, out key);

            string conflict_name;

            if (shortcut != null) {
                foreach (var tree in trees) {
                    if (tree.shortcut_conflicts (shortcut, out conflict_name) == false || conflict_name == (string) name) {
                        continue;
                    }

                    var dialog = new ConflictDialog (shortcut.to_readable (), conflict_name, (string) name);
                    dialog.reassign.connect (() => {
                        tree.reset_shortcut (shortcut);
                        ApplicationShortcutSettings.edit_shortcut ((string) key, shortcut);
                        load_and_display_shortcuts ();
                    });
                    dialog.transient_for = (Gtk.Window) this.get_toplevel ();
                    dialog.present ();
                    return false;
                }
            }

            ApplicationShortcutSettings.edit_shortcut ((string) key, shortcut ?? new Shortcut ());
            load_and_display_shortcuts ();
            return true;
        }

        void remove_shortcut_for_iter (Gtk.TreeIter iter) {
            GLib.Value key;
            tv.model.get_value (iter,  Column.KEY, out key);

            ApplicationShortcutSettings.remove_shortcut ((string) key);
#if VALA_0_36
            list_store.remove (ref iter);
#else
            list_store.remove (iter);
#endif
        }
    }
}
