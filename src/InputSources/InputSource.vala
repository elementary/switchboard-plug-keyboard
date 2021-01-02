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

namespace Pantheon.Keyboard {

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
        public static InputSource new_xkb (string name, string? xkb_variant) {
            string full_name = name;
            if (xkb_variant != null && xkb_variant != "") {
                full_name += "+" + xkb_variant;
            }

            return new InputSource (LayoutType.XKB, full_name);
        }

        public static InputSource? new_from_variant (Variant? variant) {
            if (variant.is_of_type (new VariantType ("(ss)"))) {
                unowned string type;
                unowned string name;

                variant.get ("(&s&s)", out type, out name);

                if (type == "xkb") {
                    return new InputSource (LayoutType.XKB, name);
                } else if (type == "ibus") {
                    return new InputSource (LayoutType.IBUS, name);
                }
            }

            return null;
        }

        public LayoutType layout_type { get; construct; }
        public string name { get; construct; }

        public InputSource (LayoutType layout_type, string name) {
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
        public GLib.Variant to_variant () {
            string type_name = "";
            switch (layout_type) {
                case LayoutType.IBUS:
                    type_name = "ibus";
                    break;
                case LayoutType.XKB:
                    type_name = "xkb";
                    break;
                default:
                    error ("You need to implemnt this for all possible values of"
                           + "the LayoutType-enum");
            }
            GLib.Variant first = new GLib.Variant.string (type_name);
            GLib.Variant second = new GLib.Variant.string (name);
            GLib.Variant result = new GLib.Variant.tuple ({first, second});

            return result;
        }
    }
}
