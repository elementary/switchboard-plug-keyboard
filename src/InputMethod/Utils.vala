/*
* Copyright 2019-2020 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class Pantheon.Keyboard.InputMethodPage.Utils : Object {
    private static string[] _active_engines;
    // Stores currently activated engines
    public static string[] active_engines {
        get {
            _active_engines = Pantheon.Keyboard.Plug.ibus_general_settings.get_strv ("preload-engines");
            return _active_engines;
        }
        set {
            Pantheon.Keyboard.Plug.ibus_general_settings.set_strv ("preload-engines", value);
            Pantheon.Keyboard.Plug.ibus_general_settings.set_strv ("engines-order", value);
        }
    }

    // From https://github.com/ibus/ibus/blob/master/ui/gtk2/i18n.py#L47-L54
    public static string gettext_engine_longname (IBus.EngineDesc engine) {
        string name = engine.name;
        if (name.has_prefix ("xkb:")) {
            return dgettext ("xkeyboard-config", engine.longname);
        }

        string textdomain = engine.textdomain;
        if (textdomain == "") {
            return engine.longname;
        }

        return dgettext (textdomain, engine.longname);
    }
}
