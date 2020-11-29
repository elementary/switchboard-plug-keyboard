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
        }

        return instance;
    }

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

    public bool add_layout (InputSource? new_layout) {
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
        layouts_changed ();
        return true;
    }

    public void remove_active_layout () {
        layouts.remove (get_layout (active));

        if (active >= length)
            active = length - 1;
        layouts_changed ();
    }

    public void remove_all () {
        layouts = new GLib.List<InputSource> ();
        layouts_changed ();
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
