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

namespace Pantheon.Keyboard.LayoutPage {

    /**
     * Type of a keyboard-layout as described in the description of
     * "org.gnome.desktop.input-sources sources".
     */
    enum LayoutType { IBUS, XKB }

    /**
     * Immutable class that respresents a keyboard-layout according to
     * "org.gnome.desktop.input-sources sources".
     * This means that the enum parameter @layout_type equals the first string in the
     * tupel of strings, and the @name parameter equals the second string.
     */
    class Layout : Object {
        public LayoutType layout_type { get; construct; }
        public string name { get; construct; }

        public Layout (LayoutType layout_type, string name) {
            Object (
                layout_type: layout_type,
                name: name
            );
        }

        public Layout.XKB (string layout, string? variant) {
            string full_name = layout;
            if (variant != null && variant != "") {
                full_name += "+" + variant;
            }

            Object (
                layout_type: LayoutType.XKB,
                name: full_name
            );
        }

        public Layout.from_variant (GLib.Variant variant) {
            if (variant.is_of_type (new VariantType ("(ss)"))) {
                unowned string type;
                unowned string name;

                variant.get ("(&s&s)", out type, out name);

                LayoutType? _layout_type = null;
                if (type == "xkb") {
                    _layout_type = LayoutType.XKB;
                } else if (type == "ibus") {
                    _layout_type = LayoutType.IBUS;
                }

                if (_layout_type != null) {
                    Object (
                        layout_type: _layout_type,
                        name: name
                    );
                } else {
                    critical ("Unkown type %s", type);
                }
            } else {
                critical ("Variant has invalid type");
            }
        }

        public bool equal (Layout other) {
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
