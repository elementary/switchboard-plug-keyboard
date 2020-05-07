/*
* Copyright 2019-2020 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class Pantheon.Keyboard.InputMethodPage.AddEnginesPopover : Gtk.Popover {
    private GLib.ListStore liststore;
    private Gtk.ListBox listbox;
    public signal void add_engine (string new_engine);

    public AddEnginesPopover (Gtk.Widget relative_object) {
        Object (
            relative_to: relative_object
        );
    }

    construct {
        var search_entry = new Gtk.SearchEntry ();
        search_entry.margin = 6;
        ///TRANSLATORS: This text appears in a search entry and tell users to type some search word
        ///to look for a input method engine they want to add.
        ///It does not mean search engines in web browsers.
        search_entry.placeholder_text = _("Search engine");

        liststore = new GLib.ListStore (Type.OBJECT);

        listbox = new Gtk.ListBox ();

#if IBUS_1_5_19
        List<IBus.EngineDesc> engines = new IBus.Bus ().list_engines ();
#else
        List<weak IBus.EngineDesc> engines = new IBus.Bus ().list_engines ();
#endif

        foreach (var engine in engines) {
            liststore.append (new Pantheon.Keyboard.InputMethodPage.AddEnginesList (engine));
        }

        liststore.sort ((a, b) => {
            return ((Pantheon.Keyboard.InputMethodPage.AddEnginesList) a).engine_full_name.collate (((Pantheon.Keyboard.InputMethodPage.AddEnginesList) b).engine_full_name);
        });

        for (int i = 0; i < liststore.get_n_items (); i++) {
            var listboxrow = new Gtk.ListBoxRow ();

            var label = new Gtk.Label (((Pantheon.Keyboard.InputMethodPage.AddEnginesList) liststore.get_item (i)).engine_full_name);
            label.margin = 6;
            label.halign = Gtk.Align.START;

            listboxrow.add (label);
            listbox.add (listboxrow);
        }

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.height_request = 300;
        scrolled.width_request = 500;
        scrolled.expand = true;
        scrolled.add (listbox);

        var install_button = new Gtk.Button.with_label (_("Install unlisted engines…"));

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));

        var add_button = new Gtk.Button.with_label (_("Add Engine"));
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var buttons_grid = new Gtk.Grid ();
        buttons_grid.margin = 6;
        buttons_grid.column_spacing = 6;
        buttons_grid.hexpand = true;
        buttons_grid.halign = Gtk.Align.END;
        buttons_grid.attach (install_button, 0, 0, 1, 1);
        buttons_grid.attach (cancel_button, 1, 0, 1, 1);
        buttons_grid.attach (add_button, 2, 0, 1, 1);

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.hexpand = true;
        grid.attach (search_entry, 0, 0, 1, 1);
        grid.attach (scrolled, 0, 1, 1, 1);
        grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 2, 1, 1);
        grid.attach (buttons_grid, 0, 3, 1, 1);

        listbox.select_row (listbox.get_row_at_index (0));
        search_entry.grab_focus ();

        add (grid);

        listbox.button_press_event.connect ((event) => {
            if (event.type == Gdk.EventType.DOUBLE_BUTTON_PRESS) {
                trigger_add_engine ();
                return false;
            }

            return false;
        });

        listbox.set_filter_func ((list_box_row) => {
            var item = (Pantheon.Keyboard.InputMethodPage.AddEnginesList) liststore.get_item (list_box_row.get_index ());
            return search_entry.text.down () in item.engine_full_name.down ();
        });

        search_entry.search_changed.connect (() => {
            listbox.invalidate_filter ();
        });

        install_button.clicked.connect (() => {
            popdown ();

            var install_dialog = new InstallEngineDialog ((Gtk.Window) get_toplevel ());
            install_dialog.run ();
            install_dialog.destroy ();
        });

        cancel_button.clicked.connect (() => {
            popdown ();
        });

        add_button.clicked.connect (() => {
            trigger_add_engine ();
        });
    }

    private void trigger_add_engine () {
        int index = listbox.get_selected_row ().get_index ();

        // If the engine trying to add is already active, do not add it
        foreach (var active_engine in Pantheon.Keyboard.InputMethodPage.Utils.active_engines) {
            if (active_engine == (((Pantheon.Keyboard.InputMethodPage.AddEnginesList) liststore.get_item (index)).engine_id)) {
                popdown ();
                return;
            }
        }
        add_engine (((Pantheon.Keyboard.InputMethodPage.AddEnginesList) liststore.get_item (index)).engine_id);
    }
}
