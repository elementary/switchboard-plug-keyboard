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

class Pantheon.Keyboard.LayoutPage.LayoutSettings {
    public LayoutList layouts { get; private set; }

    private XkbModifier [] xkb_options_modifiers;
    private GLib.Settings settings;

    /**
     * True if and only if we are currently writing to gsettings
     * by ourselves.
     */
    private bool currently_writing;

    static LayoutSettings? instance;
    public static LayoutSettings get_instance () {
        if (instance == null) {
            instance = new LayoutSettings ();
        }
        return instance;
    }

    private LayoutSettings () {
        settings = new Settings ("org.gnome.desktop.input-sources");
        layouts = new LayoutList ();

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

        if (layouts.length == 0)
            parse_default ();

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
        if (currently_writing)
            return;

        GLib.Variant sources = settings.get_value ("sources");
        if (sources.is_of_type (VariantType.ARRAY)) {
            for (size_t i = 0; i < sources.n_children (); i++) {
                GLib.Variant child = sources.get_child_value (i);
                layouts.add_layout (new Layout.from_variant (child));
            }
        } else {
            warning ("Unkown type");
        }
    }

    private void update_active_from_gsettings () {
        layouts.active = settings.get_uint ("current");
    }

    private void parse_default () {
        var file = File.new_for_path ("/etc/default/keyboard");

        if (!file.query_exists ()) {
            warning ("File '%s' doesn't exist.\n", file.get_path ());
            return;
        }

        string xkb_layout = "";
        string xkb_variant = "";

        try {
            var dis = new DataInputStream (file.read ());

            string line;

            while ((line = dis.read_line (null)) != null) {
                if (line.contains ("XKBLAYOUT=")) {
                    xkb_layout = line.replace ("XKBLAYOUT=", "").replace ("\"", "");

                    while ((line = dis.read_line (null)) != null) {
                        if (line.contains ("XKBVARIANT=")) {
                            xkb_variant = line.replace ("XKBVARIANT=", "").replace ("\"", "");
                        }
                    }

                    break;
                }
            }
        }
        catch (Error e) {
            warning ("%s", e.message);
            return;
        }

        var variants = xkb_variant.split (",");
        var xkb_layouts = xkb_layout.split (",");

        for (int i = 0; i < layouts.length; i++) {
            if (variants[i] != null && variants[i] != "") {
                layouts.add_layout (new Layout (LayoutType.XKB, xkb_layouts[i] + "+" + variants[i]));
            } else {
                layouts.add_layout (new Layout (LayoutType.XKB, xkb_layouts[i]));
            }
        }
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

    public void reset_all () {
        layouts.remove_all ();
        parse_default ();
    }
}
