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

public enum Keyboard.InputMethodPage.InstallList {
    JA,
    KO,
    ZH;

    public string get_name () {
        switch (this) {
            case JA:
                return _("Japanese");
            case KO:
                return _("Korean");
            case ZH:
                return _("Chinese");
            default:
                assert_not_reached ();
        }
    }

    public string[] get_components () {
        switch (this) {
            case JA:
                return { "ibus-anthy", "ibus-mozc", "ibus-skk" };
            case KO:
                return { "ibus-hangul" };
            case ZH:
                return { "ibus-cangjie", "ibus-chewing", "ibus-pinyin", "ibus-rime" };
            default:
                assert_not_reached ();
        }
    }

    public static InstallList get_language_from_engine_name (string engine_name) {
        switch (engine_name) {
            case "ibus-anthy":
                return JA;
            case "ibus-mozc":
                return JA;
            case "ibus-skk":
                return JA;
            case "ibus-hangul":
                return KO;
            case "ibus-cangjie":
                return ZH;
            case "ibus-chewing":
                return ZH;
            case "ibus-pinyin":
                return ZH;
            case "ibus-rime":
                return ZH;
            default:
                assert_not_reached ();
        }
    }

    public static InstallList[] get_all () {
        return { JA, KO, ZH };
    }
}
