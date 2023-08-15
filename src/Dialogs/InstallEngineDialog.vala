/*
* Copyright 2019-2020 elementary, Inc. (https://elementary.io)
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

public class Pantheon.Keyboard.InputMethodPage.InstallEngineDialog : Granite.MessageDialog {
    private Gtk.ListBox listbox;
    private InstallList? engines_filter;

    public InstallEngineDialog (Gtk.Window parent) {
        Object (
            primary_text: _("Choose an engine to install"),
            secondary_text: _("Select an engine from the list to install and use."),
            image_icon: new ThemedIcon ("extension"),
            transient_for: parent,
            buttons: Gtk.ButtonsType.CANCEL
        );
    }

    construct {
        var languages_list = new Gtk.ListBox () {
            activate_on_single_click = true,
            expand = true,
            selection_mode = Gtk.SelectionMode.NONE
        };

        foreach (var language in InstallList.get_all ()) {
            var lang = new LanguagesRow (language);
            languages_list.add (lang);
        }

        var back_button = new Gtk.Button.with_label (_("Languages")) {
            halign = Gtk.Align.START,
            margin = 6
        };
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var language_title = new Gtk.Label ("");

        var language_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        language_header.pack_start (back_button);
        language_header.set_center_widget (language_title);

        listbox = new Gtk.ListBox () {
            expand = true
        };
        listbox.set_filter_func (filter_function);
        listbox.set_sort_func (sort_function);

        foreach (var language in InstallList.get_all ()) {
            foreach (var engine in language.get_components ()) {
                listbox.add (new EnginesRow (engine));
            }
        }

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (listbox);

        var engine_list_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };
        engine_list_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        engine_list_grid.add (language_header);
        engine_list_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        engine_list_grid.add (scrolled);

        var deck = new Hdy.Deck () {
            height_request = 200,
            width_request = 300,
            can_swipe_back = true
        };
        deck.add (languages_list);
        deck.add (engine_list_grid);

        var frame = new Gtk.Frame (null);
        frame.add (deck);

        custom_bin.add (frame);
        custom_bin.show_all ();

        var install_button = add_button (_("Install"), Gtk.ResponseType.OK);
        install_button.sensitive = false;
        install_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        languages_list.row_activated.connect ((row) => {
            deck.visible_child = engine_list_grid;
            language_title.label = ((LanguagesRow) row).language.get_name ();
            engines_filter = ((LanguagesRow) row).language;
            listbox.invalidate_filter ();
            var adjustment = scrolled.get_vadjustment ();
            adjustment.set_value (adjustment.lower);
        });

        back_button.clicked.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
            install_button.sensitive = false;
        });

        listbox.selected_rows_changed.connect (() => {
            foreach (var engines_row in listbox.get_children ()) {
                ((EnginesRow) engines_row).selected = false;
            }

            ((EnginesRow) listbox.get_selected_row ()).selected = true;
            install_button.sensitive = true;
        });
    }

    public string get_selected_engine_name () {
        return ((EnginesRow) listbox.get_selected_row ()).engine_name;
    }

    [CCode (instance_pos = -1)]
    private bool filter_function (Gtk.ListBoxRow row) {
        if (InstallList.get_language_from_engine_name (((EnginesRow) row).engine_name) == engines_filter) {
            return true;
        }

        return false;
    }

    [CCode (instance_pos = -1)]
    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        return ((EnginesRow) row1).engine_name.collate (((EnginesRow) row1).engine_name);
    }
}
