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

public class Pantheon.Keyboard.InputMethodPage.Page : Pantheon.Keyboard.AbstractPage {
    private IBus.Bus bus;
    private GLib.Settings ibus_panel_settings;
    // Stores all installed engines
#if IBUS_1_5_19
    private List<IBus.EngineDesc> engines;
#else
    private List<weak IBus.EngineDesc> engines;
#endif

    private Granite.Widgets.AlertView spawn_failed_alert;
    private Gtk.ListBox listbox;
    private Gtk.Button remove_button;
    private AddEnginesPopover add_engines_popover;
    private Gtk.Switch show_system_tray_switch;
    private Gtk.Stack stack;

    public Page () {
    }

    construct {
        bus = new IBus.Bus ();
        ibus_panel_settings = new GLib.Settings ("org.freedesktop.ibus.panel");

        // no_daemon_runnning view shown if IBus Daemon is not running
        var no_daemon_runnning_alert = new Granite.Widgets.AlertView (
            _("IBus Daemon is not running"),
            _("You need to run IBus Daemon to enable or configure input method engines."),
            "dialog-information"
        );
        no_daemon_runnning_alert.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        no_daemon_runnning_alert.halign = Gtk.Align.CENTER;
        no_daemon_runnning_alert.valign = Gtk.Align.CENTER;
        no_daemon_runnning_alert.show_action (_("Start IBus Daemon"));
        no_daemon_runnning_alert.action_activated.connect (() => {
            spawn_ibus_daemon ();
        });

        var no_daemon_runnning_grid = new Gtk.Grid ();
        no_daemon_runnning_grid.add (no_daemon_runnning_alert);

        // spawn_failed view shown if IBus Daemon is not running
        spawn_failed_alert = new Granite.Widgets.AlertView (
            _("Failed to start IBus Daemon"),
            "",
            "dialog-error"
        );
        spawn_failed_alert.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        spawn_failed_alert.halign = Gtk.Align.CENTER;
        spawn_failed_alert.valign = Gtk.Align.CENTER;

        var spawn_failed_grid = new Gtk.Grid ();
        spawn_failed_grid.add (spawn_failed_alert);

        // normal view shown if IBus Daemon is already running
        listbox = new Gtk.ListBox ();

        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.expand = true;
        scroll.add (listbox);

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
        add_button.tooltip_text = _("Add…");

        remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
        remove_button.tooltip_text = _("Remove");

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        actionbar.add (add_button);
        actionbar.add (remove_button);

        var left_grid = new Gtk.Grid ();
        left_grid.attach (scroll, 0, 0, 1, 1);
        left_grid.attach (actionbar, 0, 1, 1, 1);

        var display = new Gtk.Frame (null);
        display.add (left_grid);

        add_engines_popover = new AddEnginesPopover (add_button);

        var keyboard_shortcut_label = new Gtk.Label (_("Switch engines:"));
        keyboard_shortcut_label.halign = Gtk.Align.END;

        var keyboard_shortcut_combobox = new Gtk.ComboBoxText ();
        keyboard_shortcut_combobox.halign = Gtk.Align.START;
        keyboard_shortcut_combobox.append ("alt-space", _("Alt + Space"));
        keyboard_shortcut_combobox.append ("ctl-space", _("Ctrl + Space"));
        keyboard_shortcut_combobox.append ("shift-space", _("Shift + Space"));
        keyboard_shortcut_combobox.active_id = get_keyboard_shortcut ();

        var show_ibus_panel_label = new Gtk.Label (_("Show candidate window:"));
        show_ibus_panel_label.halign = Gtk.Align.END;

        var show_ibus_panel_combobox = new Gtk.ComboBoxText ();
        show_ibus_panel_combobox.halign = Gtk.Align.START;
        show_ibus_panel_combobox.append ("none", _("Do not show"));
        show_ibus_panel_combobox.append ("auto-hide", _("Auto hide"));
        show_ibus_panel_combobox.append ("always-show", _("Always show"));

        var show_system_tray_label = new Gtk.Label (_("Show icon on system tray:"));
        show_system_tray_label.halign = Gtk.Align.END;

        show_system_tray_switch = new Gtk.Switch ();
        show_system_tray_switch.halign = Gtk.Align.START;

        var embed_preedit_text_label = new Gtk.Label (_("Embed preedit text in application window:"));
        embed_preedit_text_label.halign = Gtk.Align.END;

        var embed_preedit_text_switch = new Gtk.Switch ();
        embed_preedit_text_switch.halign = Gtk.Align.START;

        var entry_test = new Gtk.Entry ();
        entry_test.hexpand = true;
        entry_test.placeholder_text = (_("Type to test your settings"));

        var ibus_button = new Gtk.Button.with_label (_("Advanced Settings…"));

        var action_area = new Gtk.Grid ();
        action_area.column_spacing = 12;
        action_area.valign = Gtk.Align.END;
        action_area.vexpand = true;
        action_area.add (entry_test);
        action_area.add (ibus_button);

        var right_grid = new Gtk.Grid ();
        right_grid.halign = Gtk.Align.CENTER;
        right_grid.hexpand = true;
        right_grid.column_spacing = 12;
        right_grid.row_spacing = 12;
        right_grid.margin = 12;
        right_grid.attach (keyboard_shortcut_label, 0, 0, 1, 1);
        right_grid.attach (keyboard_shortcut_combobox, 1, 0, 1, 1);
        right_grid.attach (show_ibus_panel_label, 0, 1, 1, 1);
        right_grid.attach (show_ibus_panel_combobox, 1, 1, 1, 1);
        right_grid.attach (show_system_tray_label, 0, 2, 1, 1);
        right_grid.attach (show_system_tray_switch, 1, 2, 1, 1);
        right_grid.attach (embed_preedit_text_label, 0, 3, 1, 1);
        right_grid.attach (embed_preedit_text_switch, 1, 3, 1, 1);

        var main_grid = new Gtk.Grid ();
        main_grid.column_spacing = 12;
        main_grid.row_spacing = 12;
        main_grid.attach (display, 0, 0, 1, 2);
        main_grid.attach (right_grid, 1, 0, 1, 1);
        main_grid.attach (action_area, 1, 1, 1, 1);

        stack = new Gtk.Stack ();
        stack.add_named (no_daemon_runnning_grid, "no_daemon_runnning_view");
        stack.add_named (spawn_failed_grid, "spawn_failed_view");
        stack.add_named (main_grid, "main_view");
        stack.visible_child_name = "no_daemon_runnning_view";
        stack.show_all ();

        add (stack);

        set_visible_view ();

        add_button.clicked.connect (() => {
            add_engines_popover.show_all ();
        });

        add_engines_popover.add_engine.connect ((engine) => {
            string[] new_engine_list = Utils.active_engines;
            new_engine_list += engine;
            Utils.active_engines = new_engine_list;

            update_engines_list ();
            add_engines_popover.popdown ();
        });

        remove_button.clicked.connect (() => {
            int index = listbox.get_selected_row ().get_index ();

            // Convert to GLib.Array once, because Vala does not support "-=" operator
            Array<string> removed_lists = new Array<string> ();
            foreach (var active_engine in Utils.active_engines) {
                removed_lists.append_val (active_engine);
            }
            // Remove applicable engine from the list
            removed_lists.remove_index (index);

            /*
             * Substitute the contents of removed_lists through another string array,
             * because array concatenation is not supported for public array variables and parameters
             */
            string[] new_engines;
            for (int i = 0; i < removed_lists.length; i++) {
                new_engines += removed_lists.index (i);
            }
            Utils.active_engines = new_engines;
            update_engines_list ();
        });

        keyboard_shortcut_combobox.changed.connect (() => {
            set_keyboard_shortcut (keyboard_shortcut_combobox.active_id);
        });

        ibus_button.clicked.connect (() => {
            try {
                var appinfo = GLib.AppInfo.create_from_commandline ("ibus-setup", null, GLib.AppInfoCreateFlags.NONE);
                appinfo.launch (null, null);
            } catch (Error e) {
                critical ("Could not open ibus setup: %s", e.message);
            }
        });

        ibus_panel_settings.bind ("show", show_ibus_panel_combobox, "active", SettingsBindFlags.DEFAULT);
        ibus_panel_settings.bind ("show-icon-on-systray", show_system_tray_switch, "active", SettingsBindFlags.DEFAULT);
        Pantheon.Keyboard.Plug.ibus_general_settings.bind ("embed-preedit-text", embed_preedit_text_switch, "active", SettingsBindFlags.DEFAULT);
    }

    private string get_keyboard_shortcut () {
        // TODO: Support getting multiple shortcut keys like ibus-setup does
        string[] keyboard_shortcuts = Pantheon.Keyboard.Plug.ibus_general_settings.get_child ("hotkey").get_strv ("triggers");

        string keyboard_shortcut = "";
        foreach (var ks in keyboard_shortcuts) {
            switch (ks) {
                case "<Alt>space":
                    keyboard_shortcut = "alt-space";
                    break;
                case "<Shift>space":
                    keyboard_shortcut = "shift-space";
                    break;
                case "<Control>space":
                    keyboard_shortcut = "ctl-space";
                    break;
                default:
                    break;
            }
        }

        return keyboard_shortcut;
    }

    private void set_keyboard_shortcut (string combobox_id) {
        // TODO: Support setting multiple shortcut keys like ibus-setup does
        string[] keyboard_shortcuts = {};

        switch (combobox_id) {
            case "alt-space":
                keyboard_shortcuts += "<Alt>space";
                break;
            case "shift-space":
                keyboard_shortcuts += "<Shift>space";
                break;
            default:
                keyboard_shortcuts += "<Control>space";
                break;
        }

        Pantheon.Keyboard.Plug.ibus_general_settings.get_child ("hotkey").set_strv ("triggers", keyboard_shortcuts);
    }

    private void update_engines_list () {
        engines = new IBus.Bus ().list_engines ();

        // Stores names of currently activated engines
        string[] engine_full_names = {};

        listbox.get_children ().foreach ((listbox_child) => {
            listbox_child.destroy ();
        });

        // Add the language and the name of activated engines
        foreach (var active_engine in Utils.active_engines) {
            foreach (var engine in engines) {
                if (engine.name == active_engine) {
                    engine_full_names += "%s - %s".printf (IBus.get_language_name (engine.language),
                                                    Utils.gettext_engine_longname (engine));
                }
            }
        }

        foreach (var engine_full_name in engine_full_names) {
            var listboxrow = new Gtk.ListBoxRow ();

            var label = new Gtk.Label (engine_full_name);
            label.margin = 6;
            label.halign = Gtk.Align.START;

            listboxrow.add (label);
            listbox.add (listboxrow);
        }

        listbox.show_all ();
        listbox.select_row (listbox.get_row_at_index (0));

        // Update the sensitivity of buttons depends on whether there are active engines
        remove_button.sensitive = listbox.get_row_at_index (0) != null;
        show_system_tray_switch.sensitive = listbox.get_row_at_index (0) != null;
    }

    private void spawn_ibus_daemon () {
        bool is_spawn_succeeded = false;
        try {
            is_spawn_succeeded = Process.spawn_sync ("/", { "ibus-daemon", "-drx" }, Environ.get (), SpawnFlags.SEARCH_PATH, null);
        } catch (GLib.SpawnError e) {
            warning (e.message);
            set_visible_view (e.message);
            return;
        }

        uint timeout_start_daemon = Timeout.add (500, () => {
            set_visible_view ();
            return Gdk.EVENT_PROPAGATE;
        });
        timeout_start_daemon = 0;
    }

    private void set_visible_view (string error_message = "") {
        if (error_message != "") {
            stack.visible_child_name = "spawn_failed_view";
            spawn_failed_alert.description = error_message;
        } else if (bus.is_connected ()) {
            stack.visible_child_name = "main_view";
            update_engines_list ();
            add_engines_popover.update_engines_list ();
        } else {
            stack.visible_child_name = "no_daemon_runnning_view";
        }
    }

    public override void reset () {
        set_keyboard_shortcut ("ctrl-space");
        ibus_panel_settings.reset ("show");
        ibus_panel_settings.reset ("show-icon-on-systray");
        Pantheon.Keyboard.Plug.ibus_general_settings.reset ("embed-preedit-text");
    }
}
