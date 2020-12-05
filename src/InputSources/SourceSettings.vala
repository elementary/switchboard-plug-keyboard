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

class Pantheon.Keyboard.SourceSettings {
    private SourcesList layouts;

    private XkbModifier [] xkb_options_modifiers;
    private GLib.Settings settings;

    /**
     * True if and only if we are currently writing to gsettings
     * by ourselves.
     */
    private bool currently_writing;

    private static SourceSettings? instance;
    public static SourceSettings get_instance () {
        if (instance == null) {
            instance = new SourceSettings ();
        }
        return instance;
    }

    private SourceSettings () {
        settings = new GLib.Settings ("org.gnome.desktop.input-sources");
        layouts = SourcesList.get_instance ();

        update_list_from_gsettings ();
        update_active_from_gsettings ();
        layouts.layouts_changed.connect (() => {
            write_list_to_gsettings ();
        });

        layouts.active_changed.connect (() => {
            write_active_to_gsettings ();
        });

        settings.changed["sources"].connect (() => {
            update_list_from_gsettings ();
        });

        settings.changed["current"].connect (() => {
            update_active_from_gsettings ();
        });
    }

    private void write_list_to_gsettings () {
        currently_writing = true;
        try {
            Variant[] elements = {};
            for (uint i = 0; i < layouts.length; i++) {
                elements += layouts.get_layout (i).to_variant ();
            }
            GLib.Variant list = new GLib.Variant.array (new VariantType ("(ss)"), elements);
            settings.set_value ("sources", list);
        } finally {
            currently_writing = false;
        }
    }

    private void write_active_to_gsettings () {
        uint active = layouts.active;
        settings.set_uint ("current", active);
    }

    private void update_list_from_gsettings () {
        // We currently write to gsettings, so we caused this signal
        // and therefore don't need to read the list again from dconf
        if (currently_writing) {
            return;
        }

        layouts.reset (null); // Remove all layouts from list

        GLib.Variant sources = settings.get_value ("sources");
        if (sources.is_of_type (VariantType.ARRAY)) {
            for (size_t i = 0; i < sources.n_children (); i++) {
                GLib.Variant child = sources.get_child_value (i);
                layouts.add_layout (InputSource.new_from_variant (child), false);
            }
        } else {
            warning ("Unknown type");
        }

        layouts.layouts_changed ();
    }

    private void update_active_from_gsettings () {
        layouts.active = settings.get_uint ("current");
    }

    public void add_xkb_modifier (XkbModifier modifier) {
        //We assume by this point the modifier has all the options in it.
        modifier.update_from_gsettings ();
        xkb_options_modifiers += modifier;
    }

    public XkbModifier? get_xkb_modifier_by_name (string name) {
        foreach (XkbModifier modifier in xkb_options_modifiers) {
            if (modifier.name == name) {
                return modifier;
            }
        }

        return null;
    }
}
