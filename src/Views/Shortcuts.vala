/*
* Copyright (c) 2017-2018 elementary, LLC. (https://elementary.io)
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

namespace Pantheon.Keyboard.Shortcuts {
    // list of all shortcuts in gsettings, global object
    private List list;
    // class to interact with gsettings
    private Shortcuts.Settings settings;
    // array of tree views, one for each section
    private DisplayTree[] trees;

    private enum SectionID {
        WINDOWS,
        WORKSPACES,
        SCREENSHOTS,
        APPS,
        MEDIA,
        A11Y,
        CUSTOM,
        COUNT
    }

    private string[] section_names;

    class Page : Pantheon.Keyboard.AbstractPage {
        public override void reset () {
            for (int i = 0; i < SectionID.COUNT; i++) {
                var g = list.groups[i];

                for (int k = 0; k < g.actions.length; k++) {
                    settings.reset (g.schemas[k], g.keys[k]);
                }
            }
            return;
        }

        construct {            
            CustomShortcutSettings.init ();

            // init public elements
            section_names = {
                _("Windows"),
                _("Workspaces"),
                _("Screenshots"),
                _("Applications"),
                _("Media"),
                _("Universal Access"),
                _("Custom")
            };

            list = new List ();
            settings = new Shortcuts.Settings ();

            for (int id = 0; id < SectionID.CUSTOM; id++) {
                trees += new Tree ((SectionID) id);
            }

            if (CustomShortcutSettings.available) {
                trees += new CustomTree ();
            }

            var section_switcher = new SectionSwitcher ();
            var shortcut_display = new ShortcutDisplay (trees);

            column_homogeneous = true;
            attach (section_switcher, 0, 0, 1, 1);
            attach (shortcut_display, 1, 0, 2, 1);

            section_switcher.changed.connect (shortcut_display.change_selection);
        }
    }
}
