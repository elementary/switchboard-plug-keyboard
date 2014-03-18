public class Pantheon.Keyboard.Shortcuts.CustomShortcutSettings : Object {

    const string SCHEMA = "org.gnome.settings-daemon.plugins.media-keys";
    const string KEY = "custom-keybinding";

    const string RELOCATABLE_SCHEMA_PATH_TEMLPATE = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom%d/";

    const int MAX_SHORCUTS = 100;

    static GLib.Settings settings;

    public static bool available = false;

    public struct CustomShortcut {
        string name;
        string shortcut;
        string command;
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
        try {
            return new GLib.Settings.with_path (SCHEMA + "." + KEY, relocatable_schema);
        } catch (Error e) {
            warning (e.message);
        }

        return (GLib.Settings) null;
    }

    public static string? create_shortcut () requires (available) {
        for (int i = 0; i < MAX_SHORCUTS; i++) {
            var new_relocatable_schema = get_relocatable_schema_path (i);

            if (relocatable_schema_is_used (new_relocatable_schema) == false) {
                add_relocatable_schema (new_relocatable_schema);
                reset_relocatable_schema (new_relocatable_schema);
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
    }

    static void reset_relocatable_schema (string relocatable_schema) {
        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.reset ("name");
        relocatable_settings.reset ("command");
        relocatable_settings.reset ("binding");
    }

    public static void remove_shortcut (string relocatable_schema)
        requires (available) {
        
        string []relocatable_schemas = {};

        foreach (var schema in get_relocatable_schemas ())
            if (schema != relocatable_schema)
                relocatable_schemas += schema;

        reset_relocatable_schema (relocatable_schema);
        settings.set_strv (KEY + "s", relocatable_schemas);
    }

    public static bool edit_shortcut (string relocatable_schema, string shortcut)
        requires (available) {
        
        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.set_string ("binding", shortcut);
        return true;
    }

    public static bool edit_command (string relocatable_schema, string command) 
        requires (available) {
        
        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.set_string ("command", command);
        return true;
    }

    public static GLib.List <CustomShortcut?> list_custom_shortcuts ()
        requires (available) {
    
        var list = new GLib.List <CustomShortcut?> ();

        try {
            foreach (var relocatable_schema in get_relocatable_schemas ())
                list.append (create_custom_shortcut_object (relocatable_schema));
        } catch (Error e) {
            warning (e.message);
        }

        return list;
    }

    static CustomShortcut? create_custom_shortcut_object (string relocatable_schema) {
        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);

        return {
            relocatable_settings.get_string ("name"),
            relocatable_settings.get_string ("binding"),
            relocatable_settings.get_string ("command"),
            relocatable_schema
        };
    }
}