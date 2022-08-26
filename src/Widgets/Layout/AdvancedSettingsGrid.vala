/*
* Copyright 2017-2022 elementary, Inc. (https://elementary.io)
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

public class Pantheon.Keyboard.LayoutPage.AdvancedSettings : Gtk.Grid {
    private Gtk.Stack stack;
    private HashTable <string, string> panel_for_layout;
    AdvancedSettingsPanel? [] all_panels;

    public AdvancedSettings (AdvancedSettingsPanel? [] panels) {
        panel_for_layout = new HashTable <string, string> (str_hash, str_equal);

        all_panels = panels;

        stack = new Gtk.Stack () {
            hexpand = true,
            hhomogeneous = false,
            vhomogeneous = false
        };
        attach (stack, 0, 0);

        // Add an empty Widget
        var blank_panel = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        stack.add_named (blank_panel, "none");

        foreach (AdvancedSettingsPanel? panel in panels) {
            if (panel == null) {
                continue;
            }

            stack.add_named (panel, panel.panel_name);
            foreach (string layout_name in panel.input_sources) {
                // currently we only want *one* panel per input-source
                panel_for_layout.insert (layout_name, panel.panel_name);
            }
        }
    }

    public void set_visible_panel_from_layout (string? layout_name) {

        string panel_name = "none";
        string[] split_name = {};
        if (layout_name != null) {
            if (!panel_for_layout.lookup_extended (layout_name, null, out panel_name)) {
                panel_name = "";
            }
            split_name = layout_name.split ("+");

            if (panel_name == "" && "+" in layout_name) {
                // if layout_name was not found we look for the layout without variant
                if (!panel_for_layout.lookup_extended (split_name[0], null, out panel_name)) {
                    panel_name = "";
                }
            }
        }

        if (panel_name == "") {
            foreach (AdvancedSettingsPanel? panel in all_panels) {
                if (panel == null || panel.exclusions.length == 0)
                    continue;

                if (!(split_name[0] + "*" in panel.exclusions || layout_name in panel.exclusions)) {
                    panel_name = panel.panel_name;
                    break;
                }
            }
        }

        if (panel_name == "") {
            stack.set_visible_child_name ("none");
            return;
        } else {
            stack.set_visible_child_name (panel_name);
        }
    }
}
