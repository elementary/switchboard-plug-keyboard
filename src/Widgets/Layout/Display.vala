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
    private SourceSettings source_settings;
    private Gtk.TreeView tree;
    private Gtk.Button up_button;
    private Gtk.Button down_button;
    private Gtk.Button add_button;
    private Gtk.Button remove_button;

    /*
     * Set to true when the user has just clicked on the list to prevent
     * that source_settings.layouts.active_changed triggers update_cursor
     */
    private bool cursor_changing = false;

    construct {
        source_settings = SourceSettings.get_instance ();

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
                source_settings.layouts.add_layout (InputSource.new_xkb (layout, variant));
                rebuild_list ();
            });
        });

        remove_button.clicked.connect (() => {
            source_settings.layouts.remove_active_layout ();
            rebuild_list ();
        });

        up_button.clicked.connect (() => {
            source_settings.layouts.move_active_layout_up ();
            rebuild_list ();
        });

        down_button.clicked.connect (() => {
            source_settings.layouts.move_active_layout_down ();
            rebuild_list ();
        });

        tree.cursor_changed.connect (() => {
            cursor_changing = true;
            int new_index = get_cursor_index ();
            if (new_index != -1) {
                source_settings.layouts.active = new_index;
            }
            update_buttons ();

            cursor_changing = false;
        });

        source_settings.layouts.active_changed.connect (() => {
            if (cursor_changing) {
                return;
            }

            update_cursor ();
        });

        source_settings.layouts.layouts_changed.connect_after (() => {
            rebuild_list ();
        });

        rebuild_list ();
    }

    public void reset_all () {
        source_settings.reset_all ();
        rebuild_list ();
    }

    private void update_buttons () {
        int index = get_cursor_index ();

        // if empty list
        if (index == -1) {
            up_button.sensitive = false;
            down_button.sensitive = false;
            remove_button.sensitive = false;
        } else {
            up_button.sensitive = (index != 0);
            down_button.sensitive = (index != source_settings.layouts.length - 1);
            remove_button.sensitive = (source_settings.layouts.length > 1);
        }
    }

    /**
     * Returns the index of the selected layout in the UI.
     * In case the list contains no layouts, it returns -1.
     */
    private int get_cursor_index () {
        Gtk.TreePath path;

        tree.get_cursor (out path, null);

        if (path == null) {
            return -1;
        }

        return (path.get_indices ())[0];
    }

    private void update_cursor () {
        var path = new Gtk.TreePath.from_indices (source_settings.layouts.active);
        tree.set_cursor (path, null, false);
    }

    private void rebuild_list () {
        var list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        Gtk.TreeIter iter;
        for (uint i = 0; i < source_settings.layouts.length; i++) {
            var layout = source_settings.layouts.get_layout (i);
            if (layout.layout_type == LayoutType.XKB) {
                list_store.append (out iter);
                list_store.set (iter, 0, XkbLayoutHandler.get_instance ().get_display_name (layout.name));
                list_store.set (iter, 1, layout.name);
            }
        }

        tree.model = list_store;
        update_cursor ();
        update_buttons ();
    }
}
