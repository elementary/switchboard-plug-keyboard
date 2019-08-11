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

// TODO use new Gtk.Stack widget here
namespace Pantheon.Keyboard.Shortcuts {
    class ShortcutDisplay : Gtk.Grid {
        private int selected;

        private Gtk.ScrolledWindow scroll;
        private DisplayTree[] trees;

        private Gtk.ActionBar actionbar;
        private Gtk.Button add_button;
        private Gtk.Button remove_button;

        public ShortcutDisplay (DisplayTree[] t) {
            selected = 0;

            foreach (var tree in t) {
                trees += tree;
            }

            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;
            scroll.add (t[selected]);

            add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            add_button.tooltip_text = _("Add");

            remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            remove_button.sensitive = false;
            remove_button.tooltip_text = _("Remove");

            actionbar = new Gtk.ActionBar ();
            actionbar.hexpand = true;
            actionbar.no_show_all = true;
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            actionbar.add (add_button);
            actionbar.add (remove_button);

            attach (scroll, 0, 0, 1, 1);
            attach (actionbar, 0, 1, 1, 1);

            actionbar.no_show_all = selected != SectionID.CUSTOM && selected != SectionID.APPS;
            actionbar.visible = selected == SectionID.CUSTOM || selected == SectionID.APPS;

            add_button.clicked.connect (() => {
                if (selected == SectionID.CUSTOM) {
                    (trees[selected] as CustomTree).on_add_clicked ();
                } else if (selected == SectionID.APPS) {
                    (trees[selected] as ApplicationTree).on_add_clicked ();
                }
            });

            remove_button.clicked.connect (() => {
                if (selected == SectionID.CUSTOM) {
                    (trees[selected] as CustomTree).on_remove_clicked ();
                } else if (selected == SectionID.APPS) {
                    (trees[selected] as ApplicationTree).on_remove_clicked ();
                }
            });

            change_selection (3);
        }


        // replace old tree view with new one
        public void change_selection (int new_selection) {
            if (new_selection == selected) {
                return;
            }

            scroll.remove (trees[selected]);
            scroll.add (trees[new_selection]);

            if (new_selection == SectionID.CUSTOM) {
                var custom_tree = trees[new_selection] as CustomTree;
                custom_tree.row_selected.connect (row_selected);
                custom_tree.row_unselected.connect (row_unselected);

                custom_tree.command_editing_started.connect (disable_add);
                custom_tree.command_editing_ended.connect (enable_add);
            } else if (new_selection == SectionID.APPS) {
                var application_tree = trees[new_selection] as ApplicationTree;
                application_tree.row_selected.connect (row_selected);
                application_tree.row_unselected.connect (row_unselected);
            }

            if (selected == SectionID.CUSTOM) {
                var custom_tree = trees[selected] as CustomTree;
                custom_tree.row_selected.disconnect (row_selected);
                custom_tree.row_unselected.disconnect (row_unselected);

                custom_tree.command_editing_started.disconnect (disable_add);
                custom_tree.command_editing_ended.disconnect (enable_add);
            } else if (selected == SectionID.APPS) {
                var application_tree = trees[selected] as ApplicationTree;
                application_tree.row_selected.disconnect (row_selected);
                application_tree.row_unselected.disconnect (row_unselected);
            }

            selected = new_selection;

            actionbar.no_show_all = new_selection != SectionID.CUSTOM && new_selection != SectionID.APPS;
            actionbar.visible = new_selection == SectionID.CUSTOM || new_selection == SectionID.APPS;

            show_all ();

            return;
        }

        private void row_selected () {
            remove_button.sensitive = true;
        }

        private void row_unselected () {
            remove_button.sensitive = false;
        }

        private void disable_add () {
            add_button.sensitive = false;
        }

        private void enable_add () {
            add_button.sensitive = true;
        }

    }
}
