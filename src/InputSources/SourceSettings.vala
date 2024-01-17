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

class Keyboard.SourceSettings : Object {
    public signal void external_layout_change ();

    public uint active_index { get; set; }

    public InputSource? active_input_source {
        get {
            if (active_index >= input_sources.length ()) {
                active_index = 0;
            }

            return input_sources.nth_data (active_index); //May be null if input source list empty
        }
    }

    // The ibus settings take precedence over the input-sources settings. On opening the plug, the input-sources are
    // synchronized with the ibus settings (which may have been changed by e.g. the IBus preferences app).
    private string[] _active_engines;
    public string[] active_engines {
        get {
            _active_engines = Keyboard.Plug.ibus_general_settings.get_strv ("preload-engines");
            return _active_engines;
        }

        set {
            Keyboard.Plug.ibus_general_settings.set_strv ("preload-engines", value);
            Keyboard.Plug.ibus_general_settings.set_strv ("engines-order", value);
            update_input_sources_ibus ();
        }
    }

    private GLib.List<InputSource> input_sources;

    private XkbModifier [] xkb_options_modifiers;
    private GLib.Settings settings;

    /**
     * True if and only if we are currently writing to gsettings
     * by ourselves.
     */
    private bool currently_writing;

    private static GLib.Once<SourceSettings> instance;
    public static SourceSettings get_instance () {
        return instance.once (() => {
            return new SourceSettings ();
        });
    }

    construct {
        input_sources = new GLib.List<InputSource> ();
    }

    private SourceSettings () {
        settings = new GLib.Settings ("org.gnome.desktop.input-sources");

        settings.changed["sources"].connect (() => {
            update_list_from_gsettings ();
            external_layout_change ();
        });

        settings.bind ("current", this, "active-index", SettingsBindFlags.DEFAULT);

        update_list_from_gsettings ();
    }

    private void update_list_from_gsettings () {
        // If we are currentlyly writing to gsettings, we don't need to read the list again from dconf
        if (currently_writing) {
            return;
        }

        reset (null);

        GLib.Variant sources = settings.get_value ("sources");
        if (sources.get_type ().dup_string () == "a(ss)") {
            for (size_t i = 0; i < sources.n_children (); i++) {
                GLib.Variant child = sources.get_child_value (i);
                add_layout_internal (InputSource.new_from_variant (child));
            }

            external_layout_change ();
        } else {
            warning ("GSettings sources of unexpected type");
        }

        add_default_keyboard_if_required ();
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

    public void switch_items (uint pos1, bool move_up) {
        var max_pos = input_sources.length () - 1;

        var pos2 = move_up ? pos1 - 1 : pos1 + 1;
        if (pos2 < 0 || pos2 > max_pos) {
            return;
        }

        unowned List<InputSource> container1 = input_sources.nth (pos1);
        unowned List<InputSource> container2 = input_sources.nth (pos2);
        /* We want to move the source relative to its own kind */
        while (container1.data.layout_type != container2.data.layout_type) {
            pos2 = move_up ? pos2 - 1 : pos2 + 1;
            if (pos2 < 0 || pos2 > max_pos) {
                return;
            }

            container2 = input_sources.nth (pos2);
        }

        InputSource tmp = container1.data;
        container1.data = container2.data;
        container2.data = tmp;

        if (active_index == pos1) {
            active_index = pos2;
        } else if (active_index == pos2) {
            active_index = pos1;
        }

        write_to_gsettings ();
    }

    public void foreach_layout (GLib.Func<InputSource> func) {
        input_sources.foreach (func);
    }

    private void add_default_keyboard_if_required () {
        bool have_xkb = false;
        input_sources.@foreach ((source) => {
            if (source.layout_type == LayoutType.XKB) {
                have_xkb = true;
            }
        });

        if (!have_xkb) {
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

            for (int i = 0; i < xkb_layouts.length; i++) {
                if (variants[i] != null && variants[i] != "") {
                    add_layout_internal (InputSource.new_xkb (xkb_layouts[i], variants[i]));
                } else {
                    add_layout_internal (InputSource.new_xkb (xkb_layouts[i], null));
                }
            }

            write_to_gsettings ();
        }
    }

    public bool add_layout (InputSource? new_layout) {
        if (add_layout_internal (new_layout)) {
            write_to_gsettings ();
            return true;
        }

        return false;
    }

    public bool add_layout_internal (InputSource? new_layout) {
        if (new_layout == null) {
            return false;
        }

        int i = 0;
        foreach (InputSource l in input_sources) {
            if (l.equal (new_layout)) {
                return false;
            }

            i++;
        }

        input_sources.append (new_layout);
        return true;
    }

    public void remove_layout (uint index) {
        if (index >= input_sources.length ()) {
            index = 0;
        }

        var source = input_sources.nth_data (index); // May be null if input source list empty
        input_sources.remove (source);

        if (index >= 1) {
            active_index = input_sources.length () - 1;
        }

        add_default_keyboard_if_required ();

        write_to_gsettings ();
    }

    public void reset (LayoutType? layout_type, bool signal_changed = true) {
        var remove_layouts = new GLib.List<InputSource> ();
        input_sources.@foreach ((source) => {
            if (layout_type == null || layout_type == source.layout_type) {
                remove_layouts.append (source);
            }
        });

        remove_layouts.@foreach ((layout) => {
            input_sources.remove (layout);
        });
    }

    private void update_input_sources_ibus () {
        reset (LayoutType.IBUS, false);
        foreach (string engine_name in active_engines) {
            add_layout (InputSource.new_ibus (engine_name));
        }

        write_to_gsettings ();
    }

    public bool add_active_engine (string engine_name) {
        foreach (string active_engine in active_engines) {
            if (engine_name == active_engine) {
                return false;
            }
        }

        //Cannot concatenate a public string array property so need intermediate.
        string[] new_engine_list = active_engines;
        new_engine_list += engine_name;
        active_engines = new_engine_list;

        return true;
    }

    public void set_active_engine_name (string engine_name) {
        update_input_sources_ibus ();
        uint index = 0;
        foreach_layout ((input_source) => {
            if (input_source.layout_type == LayoutType.IBUS && input_source.name == engine_name) {
                active_index = index;
                return;
            }

            index++;
        });
    }

    private void write_to_gsettings () {
        currently_writing = true;
        try {
            Variant[] elements = {};
            List<InputSource> xkb_sources = null;
            List<InputSource> ibus_sources = null;
            input_sources.foreach ((input_source) => {
                if (input_source.layout_type == LayoutType.XKB) {
                    xkb_sources.append (input_source);
                } else {
                    ibus_sources.append (input_source);
                }
            });

            /* We want xkb sorted before ibus so as to match the layout of the wingpanel indicator and so <Alt><Shift>
             * cycles in the expected order. */

            xkb_sources.foreach ((input_source) => {elements += input_source.to_variant ();});
            ibus_sources.foreach ((input_source) => {elements += input_source.to_variant ();});

            GLib.Variant list = new GLib.Variant.array (new VariantType ("(ss)"), elements);
            settings.set_value ("sources", list);
        } finally {
            currently_writing = false;
        }
    }
}
