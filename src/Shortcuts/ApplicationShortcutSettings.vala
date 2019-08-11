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

    const string SCHEMA_DEFAULT = "org.pantheon.desktop.gala.keybindings.applications";
    const string SCHEMA_CUSTOM = "org.pantheon.desktop.gala.keybindings.applications.custom";
    const string KEY_TEMPLATE = "applications-custom%d";
    const string KEY_DESKTOP_IDS = "desktop-ids";
    const int MAX_SHORTCUTS = 10;
    static HashTable<string, string> keybindings_to_types;
    static GLib.Settings settings_custom;
    static GLib.Settings settings_default;

    public struct CustomShortcut {
        string name;
        string desktop_id;
        string shortcut;
        string key;
    }

    public static void init () {
        keybindings_to_types = new HashTable<string, string> (str_hash, str_equal);
        keybindings_to_types.insert ("applications-webbrowser", "x-scheme-handler/http");
        keybindings_to_types.insert ("applications-emailclient", "x-scheme-handler/mailto");
        keybindings_to_types.insert ("applications-calendar", "text/calendar");
        keybindings_to_types.insert ("applications-videoplayer", "video/x-ogm+ogg");
        keybindings_to_types.insert ("applications-musicplayer", "audio/x-vorbis+ogg");
        keybindings_to_types.insert ("applications-imageviewer", "image/jpeg");
        keybindings_to_types.insert ("applications-texteditor", "text/plain");
        keybindings_to_types.insert ("applications-filebrowser", "inode/directory");
        keybindings_to_types.insert ("applications-terminal", "");

        var schema_source = GLib.SettingsSchemaSource.get_default ();

        var schema_default = schema_source.lookup (SCHEMA_DEFAULT, true);

        if (schema_default == null) {
            warning ("Schema \"%s\" is not installed on your system.", SCHEMA_DEFAULT);
            return;
        }

        settings_default = new GLib.Settings.full (schema_default, null, null);

        var schema_custom = schema_source.lookup (SCHEMA_CUSTOM, true);

        if (schema_custom == null) {
            warning ("Schema \"%s\" is not installed on your system.", SCHEMA_CUSTOM);
            return;
        }

        settings_custom = new GLib.Settings.full (schema_custom, null, null);
    }

    public static GLib.List <CustomShortcut?> list_custom_shortcuts () {
        var desktop_ids = settings_custom.get_strv (KEY_DESKTOP_IDS);
        var l = new GLib.List <CustomShortcut?> ();
        for (int i = 0; i < MAX_SHORTCUTS; i++) {
            var desktop_id = desktop_ids [i];
            if (desktop_id != "") {
                var key = KEY_TEMPLATE.printf (i);
                l.append ({
                    (new DesktopAppInfo (desktop_id)).get_name (),
                    desktop_id,
                    settings_custom.get_strv (key) [0],
                    key
                });
            }
        }

        return l;
   }

    public static GLib.List <CustomShortcut?> list_default_shortcuts () {
        GLib.List <CustomShortcut?> l = null; 
        var keys = list.launchers_group.keys;
        var actions = list.launchers_group.actions;

        for (var i=0; i < keys.length; i++) {
            var key = keys [i];
            var action = actions [i];
            var type = keybindings_to_types.get (key);
            string desktop_id;

            if (key == "applications-terminal") { // can't set default application for terminal
                desktop_id = "io.elementary.terminal.desktop";
            } else { 
                desktop_id = AppInfo.get_default_for_type (type, false).get_id ();
            }

            l.append ({
                action,
                desktop_id,
                settings_default.get_strv (key) [0],
                key
            });
        }

        return l;
   }

    public static string? create_shortcut (AppInfo info) {
        var desktop_ids = settings_custom.get_strv (KEY_DESKTOP_IDS);

        for (int i = 0; i < MAX_SHORTCUTS; i++) {
            if (desktop_ids [i] == "") {
                desktop_ids [i] = info.get_id ();
                settings_custom.set_strv (KEY_DESKTOP_IDS, desktop_ids);
                return KEY_TEMPLATE.printf (i);
            }
        }

        return (string) null;
    }

    public static void remove_shortcut (string key) {
        var index = int.parse(key.substring (-1));
        var desktop_ids = settings_custom.get_strv (KEY_DESKTOP_IDS);
        desktop_ids [index] = "";
        settings_custom.set_strv (KEY_DESKTOP_IDS, desktop_ids);
        settings_custom.set_strv (key, {""});
    }

    public static bool edit_shortcut (string key, Shortcut shortcut) {
        var custom = key.slice (0, -1) == KEY_TEMPLATE.slice (0, -2);
        var settings = custom ? settings_custom : settings_default;
        settings.set_strv (key, {shortcut.to_gsettings ()});
        return true;
    }

    public static bool shortcut_conflicts (Shortcut new_shortcut, out string name, out string key) {
        var shortcuts = list_default_shortcuts ();
        shortcuts.concat (list_custom_shortcuts ());

        name = "";
        key = "";

        foreach (var sc in shortcuts) {
            var shortcut = new Shortcut.parse (sc.shortcut);
            if (shortcut.is_equal (new_shortcut)) {
                name = sc.name;
                key = sc.key;
                return true;
            }
        }

        return false;
    }
}
