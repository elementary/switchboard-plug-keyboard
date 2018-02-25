/*
* Copyright (c) 2017-2018 elementary, LLC. (https://elementary.io)
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

class Pantheon.Keyboard.Shortcuts.SectionSwitcher : Gtk.ScrolledWindow {
    public signal bool changed (int i);

    construct {
        var listbox = new Gtk.ListBox ();

        var max_section_id = CustomShortcutSettings.available
                             ? SectionID.COUNT
                             : SectionID.CUSTOM;

        for (int id = 0; id < max_section_id; id++) {
            var grid = new Gtk.Grid ();

            var icon = get_icon_for_index (id);
            icon.margin_top = icon.margin_bottom = 4;
            icon.margin_left = 2;

            var label = new Gtk.Label (section_names[id]);
            label.margin = 3;
            label.margin_start = label.margin_end = 6;
            label.xalign = 0;

            grid.attach (icon, 0, 0);
            grid.attach (label, 1, 0);

            listbox.add (grid);
        }

        var frame = new Gtk.Frame (null);
        frame.add (listbox);

        add (frame);
        vexpand = true;

        listbox.row_selected.connect ((row) => {
            changed (row.get_index ());
        });
    }

    private Gtk.Image get_icon_for_index (int i) {
        switch (i) {
            case 0:
                return new Gtk.Image.from_icon_name ("multimedia-audio-player", Gtk.IconSize.DND);
            case 1:
                return new Gtk.Image.from_icon_name ("preferences-desktop-wallpaper", Gtk.IconSize.DND);
            case 2:
                return new Gtk.Image.from_icon_name ("accessories-screenshot", Gtk.IconSize.DND);
            case 3:
                return new Gtk.Image.from_icon_name ("preferences-desktop-applications", Gtk.IconSize.DND);
            case 4:
                return new Gtk.Image.from_icon_name ("applications-multimedia", Gtk.IconSize.DND);
            case 5:
                return new Gtk.Image.from_icon_name ("preferences-desktop-accessibility", Gtk.IconSize.DND);
            default:
                return new Gtk.Image.from_icon_name ("applications-other", Gtk.IconSize.DND);        }
    }
}
