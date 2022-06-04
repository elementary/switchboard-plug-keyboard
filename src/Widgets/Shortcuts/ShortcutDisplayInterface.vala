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

interface Pantheon.Keyboard.Shortcuts.ShortcutDisplayInterface : Gtk.Widget {
    public abstract Page shortcut_page { get; construct; } // Object with access to all shortcut views
    public abstract bool shortcut_conflicts (Shortcut shortcut, out string name);
    public virtual bool system_shortcut_conflicts (Shortcut shortcut, out string name) {
        name = "";
        return shortcut_page.system_shortcut_conflicts (shortcut, out name);
    }
    public virtual bool custom_shortcut_conflicts (Shortcut shortcut, out string name) {
        name = "";
        return shortcut_page.custom_shortcut_conflicts (shortcut, out name);
    }
}
