/*
* Copyright (c) 2017 elementary, LLC. (https://elementary.io)
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

class Pantheon.Keyboard.Shortcuts.ApplicationShortcutSettings : Object {

    const string SCHEMA = "org.pantheon.desktop.gala.keybindings";
    const string KEY = "custom-application-keybinding";

    const string RELOCATABLE_SCHEMA_PATH_TEMLPATE = "/org/pantheon/desktop/gala/keybindings/custom-application-keybindings/custom%d/";

    const int MAX_SHORTCUTS = 8;

    static GLib.Settings settings;

    public static bool available = false;

    public struct CustomShortcut {
        string name;
        string desktop_id;
        string shortcut;
        string relocatable_schema;
    }

    public static void init () {
        var schema_source = GLib.SettingsSchemaSource.get_default ();

        var schema = schema_source.lookup (SCHEMA, true);

        if (schema == null) {
            warning ("Schema \"%s\" is not installed on your system.", SCHEMA);
            return;
        }

        settings = new GLib.Settings.full (schema, null, null);
        available = true;
    }

    static string[] get_relocatable_schemas () {
        return settings.get_strv (KEY + "s");
    }

    static string get_relocatable_schema_path (int i) {
        return RELOCATABLE_SCHEMA_PATH_TEMLPATE.printf (i);
    }

    static GLib.Settings? get_relocatable_schema_settings (string relocatable_schema) {
        return new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);
    }

    public static string? create_shortcut (AppInfo info) requires (available) {
        for (int i = 0; i < MAX_SHORTCUTS; i++) {
            var new_relocatable_schema = get_relocatable_schema_path (i);

            if (relocatable_schema_is_used (new_relocatable_schema) == false) {
                reset_relocatable_schema (new_relocatable_schema);
                add_relocatable_schema (new_relocatable_schema);
                edit_desktop_id (new_relocatable_schema, info.get_name (), info.get_id ());
                return new_relocatable_schema;
            }
        }

        return (string) null;
    }

    static bool relocatable_schema_is_used (string new_relocatable_schema) {
        var relocatable_schemas = get_relocatable_schemas ();

        foreach (var relocatable_schema in relocatable_schemas)
            if (relocatable_schema == new_relocatable_schema)
                return true;

        return false;
    }

    static void add_relocatable_schema (string new_relocatable_schema) {
        var relocatable_schemas = get_relocatable_schemas ();
        relocatable_schemas += new_relocatable_schema;
        settings.set_strv (KEY + "s", relocatable_schemas);
        apply_settings (settings);
    }

    static void reset_relocatable_schema (string relocatable_schema) {
        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.reset ("name");
        relocatable_settings.reset ("desktop-id");
        relocatable_settings.reset ("binding" + relocatable_schema.substring (-2, 1));
        apply_settings (relocatable_settings);
    }

    public static void remove_shortcut (string relocatable_schema)
        requires (available) {

        string []relocatable_schemas = {};

        foreach (var schema in get_relocatable_schemas ())
            if (schema != relocatable_schema)
                relocatable_schemas += schema;

        reset_relocatable_schema (relocatable_schema);
        settings.set_strv (KEY + "s", relocatable_schemas);
        apply_settings (settings);
    }

    public static bool edit_shortcut (string relocatable_schema, string shortcut)
        requires (available) {

        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.set_strv ("binding"  + relocatable_schema.substring (-2, 1), {shortcut});
        apply_settings (relocatable_settings);
        return true;
    }

    public static bool edit_desktop_id (string relocatable_schema, string name, string desktop_id)
        requires (available) {

        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.set_string ("desktop-id", desktop_id);
        relocatable_settings.set_string ("name", name);
        apply_settings (relocatable_settings);
        return true;
    }

    public static GLib.List <CustomShortcut?> list_custom_shortcuts ()
        requires (available) {

        var list = new GLib.List <CustomShortcut?> ();
        foreach (var relocatable_schema in get_relocatable_schemas ())
            list.append (create_custom_shortcut_object (relocatable_schema));
        return list;
    }

    static CustomShortcut? create_custom_shortcut_object (string relocatable_schema) {
        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);

        return {
            relocatable_settings.get_string ("name"),
            relocatable_settings.get_string ("desktop-id"),
            relocatable_settings.get_strv ("binding"  + relocatable_schema.substring (-2, 1))[0],
            relocatable_schema
        };
    }

    public static bool shortcut_conflicts (Shortcut new_shortcut, out string name,
                                           out string relocatable_schema) {
        var custom_shortcuts = list_custom_shortcuts ();
        name = "";
        relocatable_schema = "";

        foreach (var custom_shortcut in custom_shortcuts) {
            var shortcut = new Shortcut.parse (custom_shortcut.shortcut);
            if (shortcut.is_equal (new_shortcut)) {
                name = custom_shortcut.name;
                relocatable_schema = custom_shortcut.relocatable_schema;
                return true;
            }
        }

        return false;
    }

    private static void apply_settings (GLib.Settings asettings) {
        asettings.apply ();
        GLib.Settings.sync ();
    }
}
