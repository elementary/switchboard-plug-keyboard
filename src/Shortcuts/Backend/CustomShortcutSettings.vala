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

public struct Keyboard.Shortcuts.CustomShortcut {
    public string shortcut; // Shortcut in gsettings format
    public string command;
    public string relocatable_schema;
}

public class Keyboard.Shortcuts.CustomShortcutSettings : Object {
    public static bool available = false;

    private const int MAX_SHORTCUTS = 100;
    private const string KEY = "custom-keybinding";
    private const string RELOCATABLE_SCHEMA_PATH_TEMPLATE = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom%d/";
    private const string SCHEMA = "org.gnome.settings-daemon.plugins.media-keys";

    private static GLib.Settings settings;

    public static void init () {
        var schema_source = GLib.SettingsSchemaSource.get_default ();

        var schema = schema_source.lookup (SCHEMA, true);

        if (schema == null) {
            warning ("Schema \"%s\" is not installed on your system.", SCHEMA);
            return;
        }

        settings = new GLib.Settings (SCHEMA);
        available = true;
    }

    public static string? create_shortcut () requires (available) {
        for (int i = 0; i < MAX_SHORTCUTS; i++) {
            var new_relocatable_schema = RELOCATABLE_SCHEMA_PATH_TEMPLATE.printf (i);

            if (!relocatable_schema_is_used (new_relocatable_schema)) {
                reset_relocatable_schema (new_relocatable_schema);

                var relocatable_schemas = settings.get_strv (KEY + "s");
                relocatable_schemas += new_relocatable_schema;

                settings.set_strv (KEY + "s", relocatable_schemas);

                return new_relocatable_schema;
            }
        }

        return null;
    }

    private static bool relocatable_schema_is_used (string new_relocatable_schema) {
        var relocatable_schemas = settings.get_strv (KEY + "s");

        foreach (var relocatable_schema in relocatable_schemas)
            if (relocatable_schema == new_relocatable_schema)
                return true;

        return false;
    }

    private static void reset_relocatable_schema (string relocatable_schema) {
        var relocatable_settings = new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);
        relocatable_settings.reset ("name");
        relocatable_settings.reset ("command");
        relocatable_settings.reset ("binding");
    }

    public static void remove_shortcut (string relocatable_schema)
        requires (available) {

        string []relocatable_schemas = {};

        foreach (var schema in settings.get_strv (KEY + "s"))
            if (schema != relocatable_schema)
                relocatable_schemas += schema;

        reset_relocatable_schema (relocatable_schema);
        settings.set_strv (KEY + "s", relocatable_schemas);
    }

    public static bool edit_shortcut (string relocatable_schema, string shortcut)
        requires (available) {

        var relocatable_settings = new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);
        relocatable_settings.set_string ("binding", shortcut);

        return true;
    }

    public static bool edit_command (string relocatable_schema, string command)
        requires (available) {

        var relocatable_settings = new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);
        relocatable_settings.set_string ("command", command);
        relocatable_settings.set_string ("name", command);

        return true;
    }

    public static GLib.List <CustomShortcut?> list_custom_shortcuts ()
        requires (available) {

        var list = new GLib.List <CustomShortcut?> ();
        foreach (var relocatable_schema in settings.get_strv (KEY + "s")) {
            var relocatable_settings = new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);

            list.append ({
                relocatable_settings.get_string ("binding"),
                relocatable_settings.get_string ("command"),
                relocatable_schema
            });
        }

        return list;
    }

    public static GLib.Settings get_gsettings_for_relocatable_schema (string relocatable_schema) {
        return new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);
    }

    public static bool shortcut_conflicts (Shortcut new_shortcut, out string command,
                                           out string relocatable_schema) {
        command = "";
        relocatable_schema = "";
        var new_gsettings_shortcut = new_shortcut.to_gsettings ();
        if (new_gsettings_shortcut == "") {
            return false;
        }

        foreach (var custom_shortcut in list_custom_shortcuts ()) {
            if (custom_shortcut.shortcut == new_gsettings_shortcut) {
                command = custom_shortcut.command;
                relocatable_schema = custom_shortcut.relocatable_schema;
                return true;
            }
        }

        return false;
    }
}
