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

public class Pantheon.Keyboard.LayoutPage.AddLayoutPopover : Gtk.Dialog {
    public signal void layout_added (string language, string layout);
    private Gtk.ListBox input_language_list_box;
    private Gtk.ListBox layout_list_box;
    private GLib.ListStore language_list;
    private GLib.ListStore layout_list;

    private static Gkbd.KeyboardDrawingGroupLevel top_left = { 0, 1 };
    private static Gkbd.KeyboardDrawingGroupLevel top_right = { 0, 3 };
    private static Gkbd.KeyboardDrawingGroupLevel bottom_left = { 0, 0 };
    private static Gkbd.KeyboardDrawingGroupLevel bottom_right = { 0, 2 };
    private static Gkbd.KeyboardDrawingGroupLevel*[] group = { &top_left, &top_right, &bottom_left, &bottom_right };

    construct {
        height_request = 500;
        width_request = 600;

        var search_entry = new Gtk.SearchEntry ();
        search_entry.margin = 12;
        search_entry.margin_bottom = 6;
        search_entry.placeholder_text = _("Search input language");

        language_list = new GLib.ListStore (typeof (ListStoreItem));
        layout_list = new GLib.ListStore (typeof (ListStoreItem));

        update_list_store (language_list, handler.languages);
        var first_lang = language_list.get_item (0) as ListStoreItem;
        update_list_store (layout_list, handler.get_variants_for_language (first_lang.id));

        input_language_list_box = new Gtk.ListBox ();
        for (int i = 0; i < language_list.get_n_items (); i++) {
            var item = language_list.get_item (i) as ListStoreItem;
            var row = new LayoutRow (item.name);

            input_language_list_box.add (row);
        }

        var input_language_scrolled = new Gtk.ScrolledWindow (null, null);
        input_language_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        input_language_scrolled.expand = true;
        input_language_scrolled.add (input_language_list_box);

        var input_language_grid = new Gtk.Grid ();
        input_language_grid.orientation = Gtk.Orientation.VERTICAL;
        input_language_grid.add (search_entry);
        input_language_grid.add (input_language_scrolled);

        var back_button = new Gtk.Button.with_label (_("Input Language"));
        back_button.halign = Gtk.Align.START;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var layout_list_title = new Gtk.Label (null);
        layout_list_title.ellipsize = Pango.EllipsizeMode.END;
        layout_list_title.max_width_chars = 20;
        layout_list_title.use_markup = true;

        layout_list_box = new Gtk.ListBox ();
        layout_list_box.bind_model (layout_list, (item) => {
            return new LayoutRow ((item as ListStoreItem).name);
        });

        var layout_scrolled = new Gtk.ScrolledWindow (null, null);
        layout_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        layout_scrolled.expand = true;
        layout_scrolled.add (layout_list_box);

        var layout_header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        layout_header_box.add (back_button);
        layout_header_box.set_center_widget (layout_list_title);

        var layout_grid = new Gtk.Grid ();
        layout_grid.orientation = Gtk.Orientation.VERTICAL;
        layout_grid.add (layout_header_box);
        layout_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        layout_grid.add (layout_scrolled);

        var gkbd_drawing = new Gkbd.KeyboardDrawing ();
        gkbd_drawing.set_groups_levels (((unowned Gkbd.KeyboardDrawingGroupLevel)[])group);

        var stack = new Gtk.Stack ();
        stack.expand = true;
        stack.margin_top = 3;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.add (input_language_grid);
        stack.add (layout_grid);
        stack.add (gkbd_drawing);

        var frame = new Gtk.Frame (null);
        frame.margin = 10;
        frame.margin_top = 0;
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        frame.add (stack);

        var keyboard_map_button = new Gtk.ToggleButton ();
        keyboard_map_button.image = new Gtk.Image.from_icon_name ("input-keyboard-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        keyboard_map_button.halign = Gtk.Align.START;
        keyboard_map_button.tooltip_text = (_("Show keyboard layout"));
        keyboard_map_button.sensitive = false;

        add_action_widget (keyboard_map_button, Gtk.ResponseType.HELP);

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        var button_add = add_button (_("Add Layout"), Gtk.ResponseType.ACCEPT);
        button_add.sensitive = false;
        button_add.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        deletable = false;
        modal = true;
        get_content_area ().add (frame);
        get_action_area ().margin = 5;

        search_entry.grab_focus ();

        input_language_list_box.set_filter_func ((list_box_row) => {
            var item = language_list.get_item (list_box_row.get_index ()) as ListStoreItem;
            return search_entry.text.down () in item.name.down ();
        });

        search_entry.search_changed.connect (() => {
            input_language_list_box.invalidate_filter ();
        });

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.HELP) {
                return;
            } else if (response_id == Gtk.ResponseType.ACCEPT) {
                layout_added (get_selected_lang ().id, get_selected_layout ().id);
            }
            destroy ();
        });

        back_button.clicked.connect (() => {
            stack.visible_child = input_language_grid;
            layout_list_box.unselect_all ();
        });

        input_language_list_box.row_activated.connect (() => {
            var selected_lang = get_selected_lang ();
            update_list_store (layout_list, handler.get_variants_for_language (selected_lang.id));

            layout_list_title.label = "<b>%s</b>".printf (selected_lang.name);
            layout_list_box.show_all ();
            layout_list_box.select_row (layout_list_box.get_row_at_index (0));
            if (layout_list_box.get_row_at_index (0) != null) {
                layout_list_box.get_row_at_index (0).grab_focus ();
            }

            stack.visible_child = layout_grid;
        });

        keyboard_map_button.clicked.connect (() => {
            if (stack.visible_child == gkbd_drawing) {
                stack.visible_child = layout_grid;
            } else {
                gkbd_drawing.set_layout ("%s\t%s".printf (get_selected_lang ().id, get_selected_layout ().id));
                gkbd_drawing.show_all ();

                stack.visible_child = gkbd_drawing;
            }
        });

        layout_list_box.row_selected.connect ((row) => {
            keyboard_map_button.sensitive = row != null;
            button_add.sensitive = row != null;
        });
    }

    private ListStoreItem get_selected_lang () {
        var selected_lang_row = input_language_list_box.get_selected_row ();
        return language_list.get_item (selected_lang_row.get_index ()) as ListStoreItem;
    }

    private ListStoreItem get_selected_layout () {
        var selected_layout_row = layout_list_box.get_selected_row ();
        return layout_list.get_item (selected_layout_row.get_index ()) as ListStoreItem;
    }

    private void update_list_store (GLib.ListStore store, HashTable<string, string> values) {
        store.remove_all ();

        values.foreach ((key, val) => {
            store.append (new ListStoreItem (key, val));
        });

        store.sort ((a, b) => {
            if (((ListStoreItem)a).name == _("Default")) {
                return -1;
            }

            if (((ListStoreItem)b).name == _("Default")) {
                return 1;
            }

            return ((ListStoreItem)a).name.collate (((ListStoreItem)b).name);
        });
    }

    private class ListStoreItem : Object {
        public string id;
        public string name;

        public ListStoreItem (string id, string name) {
            this.id = id;
            this.name = name;
        }
    }

    private class LayoutRow : Gtk.ListBoxRow {
        public LayoutRow (string name) {
            var label = new Gtk.Label (name);
            label.margin = 6;
            label.margin_end = 12;
            label.margin_start = 12;
            label.xalign = 0;
            add (label);
        }
    }
}
