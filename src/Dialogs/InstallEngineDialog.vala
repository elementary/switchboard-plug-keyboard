/*
* Copyright 2019-2022 elementary, Inc. (https://elementary.io)
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
            hexpand = true,
            vexpand = true,
            selection_mode = Gtk.SelectionMode.NONE
        };

        foreach (var language in InstallList.get_all ()) {
            var lang = new LanguagesRow (language);
            languages_list.append (lang);
        }

        var back_button = new Gtk.Button.with_label (_("Languages")) {
            halign = Gtk.Align.START,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        back_button.add_css_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var language_title = new Gtk.Label ("") {
            halign = Gtk.Align.CENTER
        };

        var language_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        language_header.append (back_button);
        language_header.append (language_title);

        var listbox = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        listbox.set_filter_func (filter_function);
        listbox.set_sort_func (sort_function);

        foreach (var language in InstallList.get_all ()) {
            foreach (var engine in language.get_components ()) {
                listbox.append (new EnginesRow (engine));
            }
        }

        var scrolled = new Gtk.ScrolledWindow ();
        scrolled.set_child (listbox);

        var engine_list_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        engine_list_grid.add_css_class (Granite.STYLE_CLASS_VIEW);
        engine_list_grid.append (language_header);
        engine_list_grid.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        engine_list_grid.append (scrolled);

        var stack = new Gtk.Stack () {
            height_request = 200,
            width_request = 300,
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };
        stack.add_child (languages_list);
        stack.add_child (engine_list_grid);

        var frame = new Gtk.Frame (null);
        frame.set_child (stack);

        custom_bin.append (frame);

        var install_button = add_button (_("Install"), Gtk.ResponseType.OK);
        install_button.sensitive = false;
        install_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        languages_list.row_activated.connect ((row) => {
            stack.visible_child = engine_list_grid;
            language_title.label = ((LanguagesRow) row).language.get_name ();
            engines_filter = ((LanguagesRow) row).language;
            listbox.invalidate_filter ();
            var adjustment = scrolled.get_vadjustment ();
            adjustment.value = adjustment.lower;
        });

        back_button.clicked.connect (() => {
            stack.visible_child = languages_list;
            install_button.sensitive = false;
        });

        listbox.selected_rows_changed.connect (() => {
            var children = listbox.observe_children ();
            for (int i = 0; i < children.get_n_items (); i++) {
                var engines_row = (EnginesRow) children.get_item (i);
                engines_row.selected = false;
            }

            ((EnginesRow) listbox.get_selected_row ()).selected = true;
            install_button.sensitive = true;
        });

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.OK) {
                string engine_to_install = ((EnginesRow) listbox.get_selected_row ()).engine_name;
                UbuntuInstaller.get_default ().install (engine_to_install);
            }
        });
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
