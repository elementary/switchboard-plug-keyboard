/*
* Copyright 2017-2020 elementary, Inc. (https://elementary.io)
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

// widget to display/add/remove/move keyboard layouts
public class Pantheon.Keyboard.LayoutPage.Display : Gtk.Frame {
    private SourceSettings settings;
    private Gtk.TreeView tree;
    private Gtk.Button up_button;
    private Gtk.Button down_button;
    private Gtk.Button add_button;
    private Gtk.Button remove_button;

    /*
     * Set to true when the user has just clicked on the list to prevent
     * layouts.active_changed triggering update_cursor
     */
    private bool cursor_changing = false;

    construct {
        settings = SourceSettings.get_instance ();

        var cell = new Gtk.CellRendererText () {
            ellipsize_set = true,
            ellipsize = Pango.EllipsizeMode.END
        };

        tree = new Gtk.TreeView () {
            headers_visible = false,
            expand = true,
            tooltip_column = 0
        };
        tree.insert_column_with_attributes (-1, null, cell, "text", 0);

        var scroll = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            expand = true
        };
        scroll.add (tree);

        add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON) {
            tooltip_text = _("Add…")
        };

        remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON) {
            sensitive = false,
            tooltip_text = _("Remove")
        };

        up_button = new Gtk.Button.from_icon_name ("go-up-symbolic", Gtk.IconSize.BUTTON) {
            sensitive = false,
            tooltip_text = _("Move up")
        };

        down_button = new Gtk.Button.from_icon_name ("go-down-symbolic", Gtk.IconSize.BUTTON) {
            sensitive = false,
            tooltip_text = _("Move down")
        };

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        actionbar.add (add_button);
        actionbar.add (remove_button);
        actionbar.add (up_button);
        actionbar.add (down_button);

        var grid = new Gtk.Grid ();
        grid.attach (scroll, 0, 0);
        grid.attach (actionbar, 0, 1);

        add (grid);

        add_button.clicked.connect (() => {
            var dialog = new AddLayoutDialog ();
            dialog.transient_for = (Gtk.Window) get_toplevel ();
            dialog.show_all ();

            dialog.layout_added.connect ((layout, variant) => {
                settings.add_layout (InputSource.new_xkb (layout, variant));
                rebuild_list ();
            });
        });

        remove_button.clicked.connect (() => {
            settings.remove_active_layout ();
            rebuild_list ();
        });

        up_button.clicked.connect (() => {
            settings.move_active_layout_up ();
            rebuild_list ();
        });

        down_button.clicked.connect (() => {
            settings.move_active_layout_down ();
            rebuild_list ();
        });

        tree.cursor_changed.connect_after (() => {
            cursor_changing = true;

            int new_index = get_cursor_index ();
            if (new_index >= 0) {
                settings.active_index = new_index;
            }

            update_buttons ();

            cursor_changing = false;
        });

        settings.notify["active-index"].connect (() => {
            update_cursor ();
        });

        settings.external_layout_change.connect (rebuild_list);

        rebuild_list ();
    }

    private void update_buttons () {
        int rows = tree.model.iter_n_children (null);
        int index = get_cursor_index ();


        up_button.sensitive = (rows > 1 && index != 0);
        down_button.sensitive = (rows > 1 && index < rows - 1);
        remove_button.sensitive = (rows > 0);
    }

    /**
     * Returns the index of the selected (xkb) layout in the list of (all) input sources.
     * In case the list contains no layouts, it returns -1.
     */
    private int get_cursor_index () {
        Gtk.TreePath path;

        tree.get_cursor (out path, null);

        if (path == null) {
            return -1;
        }

        Gtk.TreeIter iter;
        tree.model.get_iter (out iter, path);
        uint index;
        tree.model.get (iter, 2, out index, -1);
        return (int)index;
    }

    private void update_cursor () {
        if (cursor_changing || settings.active_input_source == null) {
            return;
        }

        tree.set_cursor (new Gtk.TreePath (), null, false);
        if (settings.active_input_source.layout_type == LayoutType.XKB) {
            uint index = 0;
            tree.model.foreach ((model, path, iter) => {
                tree.model.get (iter, 2, out index);
                if (index == settings.active_index) {
                    tree.set_cursor (path, null, false);
                    return true;
                }

                return false;
            });
        }
    }

    private void rebuild_list () {
        var list_store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (uint));
        Gtk.TreeIter? iter = null;
        uint index = 0;
        settings.foreach_layout ((input_source) => {
            if (input_source.layout_type == LayoutType.XKB) {
                list_store.append (out iter);
                list_store.set (iter, 0, XkbLayoutHandler.get_instance ().get_display_name (input_source.name));
                list_store.set (iter, 1, input_source.name);
                list_store.set (iter, 2, index);
            }

            index++;
        });


        tree.model = list_store;
        update_cursor ();
        update_buttons ();
    }
}
