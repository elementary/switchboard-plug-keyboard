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
    private Gtk.ListBox list;

    construct {
        settings = SourceSettings.get_instance ();

        var cell = new Gtk.CellRendererText () {
            ellipsize_set = true,
            ellipsize = Pango.EllipsizeMode.END
        };

        list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.BROWSE,
            hexpand = true,
            vexpand = true,
        };

        var scroll = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            expand = true
        };
        scroll.add (list);

        var add_button = new Gtk.Button.with_label (_("Add keyboard Layout…")) {
            always_show_image = true,
            image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR)
        };
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var actionbar = new Gtk.ActionBar () {
            child = add_button
        };
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

        var box = new Gtk.Box (VERTICAL, 0);
        box.add (scroll);
        box.add (actionbar);

        add (box);

        add_button.clicked.connect (() => {
            var dialog = new AddLayoutDialog ();
            dialog.transient_for = (Gtk.Window) get_toplevel ();
            dialog.show_all ();

            dialog.layout_added.connect ((layout, variant) => {
                settings.add_layout (InputSource.new_xkb (layout, variant));
                rebuild_list ();
            });
        });

        list.row_activated.connect (() => {
            warning ("Row activated");

            var new_index = get_cursor_index ();
            if (new_index >= 0) {
                settings.active_index = new_index;
            }
        });

        settings.notify["active-index"].connect (update_cursor);

        settings.external_layout_change.connect (rebuild_list);

        rebuild_list ();
    }

    /**
     * Returns the index of the selected (xkb) layout in the list of (all) input sources.
     * In case the list contains no layouts, it returns -1.
     */
    private int get_cursor_index () {
        unowned var selected_row = list.get_selected_row ();

        if (selected_row == null) {
            return 0;
        }

        return (int) selected_row.get_data<uint> ("index");
    }

    private void update_cursor () {
        if (settings.active_input_source == null) {
            return;
        }

        foreach (unowned var child in list.get_children ()) {
            unowned var row = (Gtk.ListBoxRow) child;
            var row_index = row.get_data<uint> ("index");

            if (settings.active_index == row_index) {
                list.select_row (row);
                break;
            }
        }
    }

    private void rebuild_list () {
        foreach (unowned var child in list.get_children ()) {
            list.remove (child);
        }

        uint i = 0;
        settings.foreach_layout ((input_source) => {
            if (input_source.layout_type == LayoutType.XKB) {
                var label = new Gtk.Label (XkbLayoutHandler.get_instance ().get_display_name (input_source.name)) {
                    hexpand = true,
                    halign = START,
                    margin_top = 6,
                    margin_bottom = 6,
                    margin_start = 6,
                    margin_end = 6,
                };

                var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic") {
                    tooltip_text = _("Remove"),
                    halign = END
                };
        
                var up_button = new Gtk.Button.from_icon_name ("go-up-symbolic") {
                    tooltip_text = _("Move up"),
                    halign = END
                };
        
                var down_button = new Gtk.Button.from_icon_name ("go-down-symbolic") {
                    tooltip_text = _("Move down"),
                    halign = END
                };

                var box = new Gtk.Box (HORIZONTAL, 0);
                box.add (label);
                box.add (remove_button);
                box.add (up_button);
                box.add (down_button);

                var listboxrow = new Gtk.ListBoxRow () {
                    child = box
                };
                listboxrow.set_data<string> ("input-source-name", input_source.name);

                var index = i; // we need to copy the value
                listboxrow.set_data<uint> ("index", index);

                list.add (listboxrow);

                remove_button.clicked.connect (() => {
                    settings.remove_layout (index);
                    rebuild_list ();
                });

                up_button.clicked.connect (() => {
                    settings.switch_items (index, true);
                    rebuild_list ();
                });
        
                down_button.clicked.connect (() => {
                    settings.switch_items (index, false);
                    rebuild_list ();
                });
            }

            i++;
        });

        list.show_all ();

        update_cursor ();
    }
}
