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
        Gtk.CellRendererAccel cell_edit_default;
        Gtk.CellRendererAccel cell_edit_custom;
        Gtk.CellRendererPixbuf cell_icon;
        Gtk.TreeView tv_default_apps;
        Gtk.TreeView tv_custom_apps;

        enum Column {
            NAME,
            DESKTOP_ID,
            SHORTCUT,
            ICON,
            KEY,
            COUNT,
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

            var label_default_apps = new Gtk.Label (_("Default Applications"));
            label_default_apps.get_style_context ().add_class ("h4");
            label_default_apps.halign = Gtk.Align.CENTER;

            var label_custom_apps = new Gtk.Label (_("Custom Applications"));
            label_custom_apps.get_style_context ().add_class ("h4");
            label_custom_apps.halign = Gtk.Align.CENTER;

            tv_default_apps = new Gtk.TreeView ();
            tv_custom_apps = new Gtk.TreeView ();

            var store_default_apps = new Gtk.ListStore (Column.COUNT,
                typeof (string), typeof (string), typeof (string), typeof (GLib.Icon), typeof (string));

            var store_custom_apps = new Gtk.ListStore (Column.COUNT,
                typeof (string), typeof (string), typeof (string), typeof (GLib.Icon), typeof (string));

            cell_desc = new Gtk.CellRendererText ();
            cell_edit_default = new Gtk.CellRendererAccel ();
            cell_edit_custom = new Gtk.CellRendererAccel ();
            cell_icon = new Gtk.CellRendererPixbuf ();

            cell_desc.editable = false;
            cell_edit_default.editable = true;
            cell_edit_default.accel_mode = Gtk.CellRendererAccelMode.OTHER;
            cell_edit_custom.editable = true;
            cell_edit_custom.accel_mode = Gtk.CellRendererAccelMode.OTHER;

            tv_default_apps.set_model (store_default_apps);
            tv_default_apps.insert_column_with_attributes (-1, _("Icon"), cell_icon, "gicon", Column.ICON);
            tv_default_apps.insert_column_with_attributes (-1, _("Application"), cell_desc, "markup", Column.NAME);
            tv_default_apps.insert_column_with_attributes (-1, _("Shortcut"), cell_edit_default, "text", Column.SHORTCUT);

            tv_default_apps.headers_visible = false;
            tv_default_apps.hexpand = true;
            tv_default_apps.get_column (1).expand = true;

            tv_custom_apps.set_model (store_custom_apps);
            tv_custom_apps.insert_column_with_attributes (-1, _("Icon"), cell_icon, "gicon", Column.ICON);
            tv_custom_apps.insert_column_with_attributes (-1, _("Application"), cell_desc, "markup", Column.NAME);
            tv_custom_apps.insert_column_with_attributes (-1, _("Shortcut"), cell_edit_custom, "text", Column.SHORTCUT);

            tv_custom_apps.headers_visible = false;
            tv_custom_apps.expand = true;
            tv_custom_apps.get_column (1).expand = true;

            container.attach (label_default_apps, 0, 0, 1, 1);
            container.attach (tv_default_apps, 0, 1, 1, 1);
            container.attach (label_custom_apps, 0, 2, 1, 1);
            container.attach (tv_custom_apps, 0, 3, 1, 1);

            add (container);
        }

        public void load_and_display_shortcuts () {
            Gtk.TreeIter iter;
            var store_default_apps = tv_default_apps.model as Gtk.ListStore;
            store_default_apps.clear ();

            foreach (var default_shortcut in ApplicationShortcutSettings.list_default_shortcuts ()) {
                var shortcut = new Shortcut.parse (default_shortcut.shortcut);

                if (shortcut == null)
                    continue;

                var desktop_appinfo = new DesktopAppInfo (default_shortcut.desktop_id);
                store_default_apps.append (out iter);
                store_default_apps.set (iter,
                                        Column.NAME, default_shortcut.name,
                                        Column.DESKTOP_ID, default_shortcut.desktop_id,
                                        Column.SHORTCUT, shortcut.to_readable (),
                                        Column.ICON, desktop_appinfo.get_icon (),
                                        Column.KEY, default_shortcut.key);
            }

            var store_custom_apps = tv_custom_apps.model as Gtk.ListStore;
            store_custom_apps.clear ();

            foreach (var custom_shortcut in ApplicationShortcutSettings.list_custom_shortcuts ()) {
                var shortcut = new Shortcut.parse (custom_shortcut.shortcut);

                var desktop_appinfo = new DesktopAppInfo (custom_shortcut.desktop_id);
                store_custom_apps.append (out iter);
                store_custom_apps.set (iter,
                                       Column.NAME, custom_shortcut.name,
                                       Column.DESKTOP_ID, custom_shortcut.desktop_id,
                                       Column.SHORTCUT, shortcut.to_readable (),
                                       Column.ICON, desktop_appinfo.get_icon (),
                                       Column.KEY, custom_shortcut.key);
            }
        }

        void connect_signals () {
            var selection = tv_custom_apps.get_selection ();
            selection.changed.connect (() => {
                if (selection.count_selected_rows () > 0) {
                    row_selected ();
                } else {
                    row_unselected ();
                }
            });

            tv_default_apps.focus_in_event.connect (() => {row_unselected (); return false;});

            cell_edit_default.accel_edited.connect ((path, key, mods) => {
                var shortcut = new Shortcut (key, mods);
                change_shortcut (path, shortcut, tv_default_apps);
            });

            cell_edit_default.accel_cleared.connect ((path) => {
                change_shortcut (path, (Shortcut) null, tv_default_apps);
            });

            cell_edit_custom.accel_edited.connect ((path, key, mods) => {
                var shortcut = new Shortcut (key, mods);
                change_shortcut (path, shortcut, tv_custom_apps);
            });

            cell_edit_custom.accel_cleared.connect ((path) => {
                change_shortcut (path, (Shortcut) null, tv_custom_apps);
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

            var store = tv_custom_apps.model as Gtk.ListStore;
            Gtk.TreeIter iter;
            var key = ApplicationShortcutSettings.create_shortcut (info);

            if (key == null)
                return;

            store.append (out iter);
            store.set (iter, Column.DESKTOP_ID, info.get_name ());
            store.set (iter, Column.SHORTCUT, (new Shortcut.parse ("")).to_readable ());
            store.set (iter, Column.KEY, key);

            load_and_display_shortcuts ();
        }

        public void on_remove_clicked () {
            Gtk.TreeIter iter;
            Gtk.TreePath path;

            tv_custom_apps.get_cursor (out path, null);
            tv_custom_apps.model.get_iter (out iter, path);
            remove_shortcut_for_iter (iter);
        }

        public bool shortcut_conflicts (Shortcut shortcut, out string name) {
            return ApplicationShortcutSettings.shortcut_conflicts (shortcut, out name, null);
        }

        public void reset_shortcut (Shortcut shortcut) {
            string key;
            ApplicationShortcutSettings.shortcut_conflicts (shortcut, null, out key);
            ApplicationShortcutSettings.edit_shortcut (key, new Shortcut ());
            load_and_display_shortcuts ();
        }

        public bool change_shortcut (string path, Shortcut? shortcut, Gtk.TreeView tv) {
            Gtk.TreeIter iter;
            GLib.Value key, name;

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
            tv_custom_apps.model.get_value (iter, Column.KEY, out key);
            var store = tv_custom_apps.model as Gtk.ListStore;

            ApplicationShortcutSettings.remove_shortcut ((string) key);
#if VALA_0_36
            store.remove (ref iter);
#else
            store.remove (iter);
#endif
        }
    }
}
