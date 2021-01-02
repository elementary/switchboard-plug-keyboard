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

/**
 * Represents a list of layouts.
 */
public class Pantheon.Keyboard.SourcesList : Object {
    public static SourcesList? instance = null;
    public static SourcesList get_instance () {
        if (instance == null) {
            instance = new SourcesList ();
            if (instance.length == 0) {
                instance.add_default_keyboard ();
            }
        }

        return instance;
    }

    private SourcesList () {} //Need to make this private so singleton used.

    private GLib.List<InputSource> layouts = new GLib.List<InputSource> ();

    // signals
    public signal void layouts_changed ();
    public signal void active_changed ();

    public uint length {
        get {
            return layouts.length ();
        }
    }

    uint _active;
    public uint active {
        get {
            return _active;
        }
        set {
            if (length == 0)
                return;

            if (_active == value)
                return;

            _active = value;
            if (_active >= length)
                _active = length - 1;
            active_changed ();
        }

    }

    private void switch_items (uint pos1, uint pos2) {
        unowned List<InputSource> container1 = layouts.nth (pos1);
        unowned List<InputSource> container2 = layouts.nth (pos2);
        InputSource tmp = container1.data;
        container1.data = container2.data;
        container2.data = tmp;

        if (active == pos1)
            active = pos2;
        else if (active == pos2)
            active = pos1;

        layouts_changed ();
    }

    public void move_active_layout_up () {
        if (length == 0)
            return;

        // check that the active item is not the first one
        if (active > 0) {
            switch_items (active, active - 1);
        }
    }

    public void move_active_layout_down () {
        if (length == 0)
            return;

        // check that the active item is not the last one
        if (active < length - 1) {
            switch_items (active, active + 1);
        }
    }

    public bool add_layout (InputSource? new_layout, bool signal_change = true) {
        if (new_layout == null) {
            return false;
        }

        int i = 0;
        foreach (InputSource l in layouts) {
            if (l.equal (new_layout)) {
                return false;
            }

            i++;
        }

        layouts.append (new_layout);
        if (signal_change) {
            layouts_changed ();
        }
        return true;
    }

    public void remove_active_layout () {
        layouts.remove (get_layout (active));

        if (active >= length) {
            active = length - 1;
        }

        layouts_changed ();
    }

    public void reset (LayoutType? layout_type) {
        var remove_layouts = new GLib.List<InputSource> ();
        layouts.@foreach ((source) => {
            if (layout_type == null || layout_type == source.layout_type) {
                remove_layouts.append (source);
            }
        });

        remove_layouts.@foreach ((layout) => {
            layouts.remove (layout);
        });

        if (layouts.length () == 0) {
            add_default_keyboard ();
        }

        layouts_changed ();
    }

    private void add_default_keyboard () {
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
                add_layout (new InputSource (LayoutType.XKB, xkb_layouts[i] + "+" + variants[i]));
            } else {
                add_layout (new InputSource (LayoutType.XKB, xkb_layouts[i]));
            }
        }
    }

    /**
     * This method does not need call layouts_changed in any situation
     * as a InputSource-Object is immutable.
     */
    public InputSource? get_layout (uint index) {
        if (index >= length)
            return null;

        return layouts.nth_data (index);
    }
}
