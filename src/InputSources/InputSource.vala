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

namespace Keyboard {

    /**
     * Type of a keyboard-InputSource as described in the description of
     * "org.gnome.desktop.input-sources sources".
     */
    public enum LayoutType { IBUS, XKB }

    /**
     * Immutable class that respresents a keyboard-InputSource according to
     * "org.gnome.desktop.input-sources sources".
     * This means that the enum parameter @layout_type equals the first string in the
     * tupel of strings, and the @name parameter equals the second string.
     */
    public class InputSource : Object {
        public static InputSource? new_xkb (string name, string? xkb_variant) {
            if (name == "") {
                critical ("Ignoring attempt to create invalid Xkb InputSource name %s", name);
                return null;
            }

            string full_name = name;
            if (xkb_variant != null && xkb_variant != "") {
                full_name += "+" + xkb_variant;
            }

            return new InputSource (LayoutType.XKB, full_name);
        }

        public static InputSource? new_ibus (string engine_name) {
            if (engine_name == "") {
                critical ("Ignoring attempt to create invalid IBus InputSource name %s", engine_name);
                return null;
            }

            return new InputSource (LayoutType.IBUS, engine_name);
        }

        public static InputSource? new_from_variant (Variant? variant) {
            if (variant.is_of_type (new VariantType ("(ss)"))) {
                unowned string type;
                unowned string name;

                variant.get ("(&s&s)", out type, out name);

                if (name != "") {
                    if (type == "xkb") {
                        return new InputSource (LayoutType.XKB, name);
                    } else if (type == "ibus") {
                        return new InputSource (LayoutType.IBUS, name);
                    }
                } else {
                    critical ("Attempt to create invalid InputSource name %s", name);
                }

            } else {
                critical ("Ignoring attempt to create InputSource from invalid VariantType");
            }

            return null;
        }

        public LayoutType layout_type { get; construct; }
        // Name of input source as stored in settings e.g. "gb" (xkb) or "xkb:gb:extd:eng" (ibus) or "mozc-jp" (ibus)
        // These names are used both in org/gnome/desktop/input-sources and desktop/ibus/general/preload-engines
        public string name { get; construct; }

        private InputSource (LayoutType layout_type, string name) {
            Object (
                layout_type: layout_type,
                name: name
            );
        }

        public bool equal (InputSource other) {
            return this.layout_type == other.layout_type && this.name == other.name;
        }

        /**
         * GSettings saves values in the form of GLib.Variant and this
         * function creates a Variant representing this object.
         */
        public GLib.Variant to_variant () requires (name != "") {
            string type_name = "";
            switch (layout_type) {
                case LayoutType.IBUS:
                    type_name = "ibus";
                    break;
                case LayoutType.XKB:
                    type_name = "xkb";
                    break;
                default:
                    assert_not_reached ();
            }
            GLib.Variant first = new GLib.Variant.string (type_name);
            GLib.Variant second = new GLib.Variant.string (name);
            GLib.Variant result = new GLib.Variant.tuple ({first, second});

            return result;
        }
    }
}
