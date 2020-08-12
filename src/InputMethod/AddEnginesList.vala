/*
* 2019-2020 elementary, Inc. (https://elementary.io)
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

public class Pantheon.Keyboard.InputMethodPage.AddEnginesList : Object {
    /*
     * Stores strings used to add/remove engines in the code and won't be shown in the UI.
     * It consists from "<Engine name>",
     * e.g. "mozc-jp" or "libpinyin"
     */
    public string engine_id { get; private set; }

    /*
     * Stores strings used to show in the UI.
     * It consists from "<Language name> - <Engine name>",
     * e.g. "Japanese - Mozc" or "Chinese - Intelligent Pinyin"
     */
    public string engine_full_name { get; private set; }

    public AddEnginesList (IBus.EngineDesc engine) {
        engine_id = engine.name;
        engine_full_name = "%s - %s".printf (IBus.get_language_name (engine.language),
                                            Utils.gettext_engine_longname (engine));
    }
}
