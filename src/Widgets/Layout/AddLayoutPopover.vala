class Pantheon.Keyboard.LayoutPage.AddLayout : Gtk.Popover {
    public signal void layout_added (string language, string layout);

    public AddLayout()
    {
        height_request = 400;

        var lang_list = new GLib.ListStore (typeof (ListStoreItem));
        var layout_list = new GLib.ListStore (typeof (ListStoreItem));

        update_list_store (lang_list, handler.languages);
        var first_lang = lang_list.get_item (0) as ListStoreItem;
        update_list_store (layout_list, handler.get_variants_for_language (first_lang.id));

        var input_language_list_box = new Gtk.ListBox ();
        input_language_list_box.bind_model (lang_list, (item) => {
            return new LayoutRow ((item as ListStoreItem).name);
        });

        var input_language_scrolled = new Gtk.ScrolledWindow (null, null);
        input_language_scrolled.add (input_language_list_box);

        var back_button = new Gtk.Button.with_label (_("Input Language"));
        back_button.halign = Gtk.Align.START;
        back_button.margin = 6;
        back_button.get_style_context ().add_class ("back-button");

        var keyboard_layout_list_title = new Gtk.Label ("");
        keyboard_layout_list_title.use_markup = true;

        var keyboard_layout_list_box = new Gtk.ListBox ();
        keyboard_layout_list_box.vexpand = true;
        keyboard_layout_list_box.bind_model (layout_list, (item) => {
            return new LayoutRow ((item as ListStoreItem).name);
        });

        var keyboard_layout_scrolled = new Gtk.ScrolledWindow (null, null);
        keyboard_layout_scrolled.add (keyboard_layout_list_box);

        var keyboard_layout_grid = new Gtk.Grid ();
        keyboard_layout_grid.column_homogeneous = true;
        keyboard_layout_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        keyboard_layout_grid.attach (back_button, 0, 0, 1, 1);
        keyboard_layout_grid.attach (keyboard_layout_list_title, 1, 0, 1, 1);
        keyboard_layout_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 3, 1);
        keyboard_layout_grid.attach (keyboard_layout_scrolled, 0, 2, 3, 1);

        var stack = new Gtk.Stack ();
        stack.expand = true;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.add (input_language_scrolled);
        stack.add (keyboard_layout_grid);

        var keyboard_map_button = new Gtk.Button.from_icon_name ("input-keyboard-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        keyboard_map_button.tooltip_text = (_("Show keyboard layout"));

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        action_bar.add (keyboard_map_button);

        var selection_grid = new Gtk.Grid ();
        selection_grid.orientation = Gtk.Orientation.VERTICAL;
        selection_grid.add (stack);
        selection_grid.add (action_bar);

        var frame = new Gtk.Frame (null);
        frame.add (selection_grid);

        var button_add = new Gtk.Button.with_label (_("Add Layout"));
        var button_cancel = new Gtk.Button.with_label (_("Cancel"));

        var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        button_box.layout_style = Gtk.ButtonBoxStyle.END;
        button_box.margin_top = 12;
        button_box.spacing = 6;
        button_box.add (button_cancel);
        button_box.add (button_add);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.margin = 12;
        grid.attach (frame, 0, 0, 1, 1);
        grid.attach (button_box, 0, 1, 1, 1);

        add (grid);

        button_cancel.clicked.connect (() => {
            this.hide ();
        });

        button_add.clicked.connect (() => {
            this.hide ();

            var selected_lang_row = input_language_list_box.get_selected_row ();
            var selected_lang = lang_list.get_item (selected_lang_row.get_index ()) as ListStoreItem;

            var selected_layout_row = keyboard_layout_list_box.get_selected_row ();
            var selected_layout = layout_list.get_item (selected_layout_row.get_index ()) as ListStoreItem;

            layout_added (selected_lang.id, selected_layout.id);
        });

        back_button.clicked.connect (() => {
            stack.visible_child = input_language_scrolled;
        });

        input_language_list_box.row_activated.connect (() => {
            var selected = input_language_list_box.get_selected_row ();
            var selected_lang = lang_list.get_item (selected.get_index ()) as ListStoreItem;
            update_list_store (layout_list, handler.get_variants_for_language (selected_lang.id));

            keyboard_layout_list_title.label = "<b>%s</b>".printf (selected_lang.name);
            keyboard_layout_list_box.show_all ();

            stack.visible_child = keyboard_layout_grid;
        });
    }

    void update_list_store (GLib.ListStore store, HashTable<string, string> values)
    {
        store.remove_all ();

        values.foreach ((key, val) => {
            store.append (new ListStoreItem (key, val));
        });

        store.sort ((a, b) => {
            var val_a = a as ListStoreItem;
            var val_b = b as ListStoreItem;

            if (val_a.name == _("Default")) {
                return -1;
            }

            if (val_b.name == _("Default")) {
                return 1;
            }

            return val_a.name.collate (val_b.name);
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
            label.xalign = 0;
            add (label);
        }
	}
}
