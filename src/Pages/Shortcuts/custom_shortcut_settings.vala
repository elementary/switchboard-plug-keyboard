public class Pantheon.Keyboard.Shortcuts.CustomShortcutSettings : Object {

    const string SCHEMA = "org.gnome.settings-daemon.plugins.media-keys";
    const string KEY = "custom-keybinding";

    const string RELOCATABLE_SCHEMA_PATH_TEMLPATE = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom%d/";

    static GLib.Settings settings;

    public struct CustomShortcut {
        string name;
        string shortcut;
        string command;
        string relocatable_schema;
    }
    
    public static void init () {
        settings = new GLib.Settings (SCHEMA);
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

    public static string? create_shortcut () {
        var relocatable_schemas = get_relocatable_schemas ();

        for (int i = 0; i < 999; i++) {
            var exists = false;

            foreach (var relocatable_schema in relocatable_schemas) {
                if (relocatable_schema == get_relocatable_schema_path (i)) {
                    exists = true;
                    break;
                }
            }

            if (exists == false) {
                var new_relocatable_schema = get_relocatable_schema_path (i);
                var new_relocatable_schemas = relocatable_schemas;
                new_relocatable_schemas += new_relocatable_schema;
                settings.set_strv (KEY + "s", new_relocatable_schemas);
                return new_relocatable_schema;
            }
        }
        
        return (string) null;
    }

    public static void remove_shortcut (string relocatable_schema) {
        var settings = new GLib.Settings (SCHEMA);
        string []relocatable_schemas = {};
        
        foreach (var schema in settings.get_strv (KEY + "s"))
            if (schema != relocatable_schema)
                relocatable_schemas += schema;
        
        settings.set_strv (KEY + "s", relocatable_schemas);
    }

    public static bool edit_custom_shortcut (string relocatable_schema, string shortcut) {
        var relocatable_schemas = get_relocatable_schemas ();

        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.set_string ("binding", shortcut);

        return true;
    }

    public static bool edit_command (string relocatable_schema, string command) {
        var relocatable_schemas = get_relocatable_schemas ();

        var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);
        relocatable_settings.set_string ("command", command);

        return true;
    }

    public static GLib.List <CustomShortcut?> list_custom_shortcuts () {
        var list = new GLib.List <CustomShortcut?> ();

        var relocatable_schemas = get_relocatable_schemas ();

        try {
            foreach (var relocatable_schema in relocatable_schemas) {
                var relocatable_settings = get_relocatable_schema_settings (relocatable_schema);

                list.append ({
                    relocatable_settings.get_string ("name"),
                    relocatable_settings.get_string ("binding"),
                    relocatable_settings.get_string ("command"),
                    relocatable_schema
                });
            }
        } catch (Error e) {
            warning (e.message);
        }

        return list;
    }
}