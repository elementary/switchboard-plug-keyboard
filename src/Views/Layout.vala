/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 elementary, Inc. (https://elementary.io)
 */

public class Pantheon.Keyboard.LayoutPage.Page : Gtk.Box {
    private Display display;
    private SourceSettings settings;
    private Gtk.SizeGroup [] size_group;
    private AdvancedSettings advanced_settings;
    private Gtk.Entry entry_test;
    private const string MULTITASKING_VIEW_COMMAND = "dbus-send --session --dest=org.pantheon.gala --print-reply /org/pantheon/gala org.pantheon.gala.PerformAction int32:1";

    construct {
        settings = SourceSettings.get_instance ();

        size_group = {
            new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL),
            new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL)
        };

        // tree view to display the current layouts
        display = new LayoutPage.Display ();

        var switch_layout_label = new Gtk.Label (_("Switch layout:")) {
            xalign = 0
        };

        // Layout switching keybinding
        var modifier = new XkbModifier ("switch-layout");
        modifier.append_xkb_option ("", _("Disabled"));
        modifier.append_xkb_option ("grp:alt_caps_toggle", _("Alt + Caps Lock"));
        modifier.append_xkb_option ("grp:alt_shift_toggle", _("Alt + Shift"));
        modifier.append_xkb_option ("grp:alt_space_toggle", _("Alt + Space"));
        modifier.append_xkb_option ("grp:shifts_toggle", _("Both Shift keys together"));
        modifier.append_xkb_option ("grp:caps_toggle", _("Caps Lock"));
        modifier.append_xkb_option ("grp:ctrl_alt_toggle", _("Ctrl + Alt"));
        modifier.append_xkb_option ("grp:ctrl_shift_toggle", _("Ctrl + Shift"));
        modifier.append_xkb_option ("grp:shift_caps_toggle", _("Shift + Caps Lock"));
        modifier.set_default_command ("");

        settings.add_xkb_modifier (modifier);

        var switch_layout_combo = new XkbComboBox (modifier, size_group[1]) {
            hexpand = true
        };

        var compose_key_label = new Gtk.Label (_("Compose key:")) {
            xalign = 0
        };

        // Compose key position menu
        modifier = new XkbModifier ();
        modifier.append_xkb_option ("", _("Disabled"));
        modifier.append_xkb_option ("compose:caps", _("Caps Lock"));
        modifier.append_xkb_option ("compose:menu", _("Menu"));
        modifier.append_xkb_option ("compose:ralt", _("Right Alt"));
        modifier.append_xkb_option ("compose:rctrl", _("Right Ctrl"));
        modifier.append_xkb_option ("compose:rwin", _("Right ⌘"));
        modifier.set_default_command ("");

        settings.add_xkb_modifier (modifier);

        var compose_key_combo = new XkbComboBox (modifier, size_group[1]);

        var overlay_key_label = new Gtk.Label (_("⌘ key behavior:")) {
            xalign = 0
        };

        // ⌘ key behavior
        var overlay_key_combo = new Gtk.ComboBoxText ();
        overlay_key_combo.append_text (_("Disabled"));
        overlay_key_combo.append_text (_("Applications Menu"));
        overlay_key_combo.append_text (_("Multitasking View"));

        string? cheatsheet_path = Environment.find_program_in_path ("io.elementary.shortcut-overlay");
        if (cheatsheet_path != null) {
            overlay_key_combo.append_text (_("Shortcut Overlay"));
        }

        size_group[1].add_widget (overlay_key_combo);

        var caps_lock_label = new Gtk.Label (_("Caps Lock behavior:")) {
            xalign = 0
        };

        // Caps Lock key functionality
        modifier = new XkbModifier ();
        modifier.append_xkb_option ("", _("Default"));
        modifier.append_xkb_option ("caps:none", _("Disabled"));
        modifier.append_xkb_option ("caps:backspace", _("as Backspace"));
        modifier.append_xkb_option ("ctrl:nocaps", _("as Ctrl"));
        modifier.append_xkb_option ("caps:escape", _("as Escape"));
        modifier.append_xkb_option ("caps:numlock", _("as Num Lock"));
        modifier.append_xkb_option ("caps:super", _("as ⌘"));
        modifier.append_xkb_option ("ctrl:swapcaps", _("Swap with Ctrl"));
        modifier.append_xkb_option ("caps:swapescape", _("Swap with Escape"));

        modifier.set_default_command ("");
        settings.add_xkb_modifier (modifier);

        var caps_lock_combo = new XkbComboBox (modifier, size_group[1]);

        var onscreen_keyboard_header = new Granite.HeaderLabel (_("On-screen Keyboard"));

        var onscreen_keyboard_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var onscreen_keyboard_settings = new Gtk.LinkButton.with_label ("", _("On-screen keyboard settings…")) {
            halign = Gtk.Align.START,
            has_tooltip = false
        };

        var onscreen_keyboard_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        onscreen_keyboard_grid.attach (onscreen_keyboard_header, 0, 0);
        onscreen_keyboard_grid.attach (onscreen_keyboard_settings, 0, 1);
        onscreen_keyboard_grid.attach (onscreen_keyboard_switch, 1, 0, 1, 2);

        // Advanced settings panel
        AdvancedSettingsPanel? [] panels = {fifth_level_layouts_panel (),
                                            japanese_layouts_panel (),
                                            korean_layouts_panel (),
                                            third_level_layouts_panel ()};

        advanced_settings = new AdvancedSettings (panels);

        entry_test = new Gtk.Entry () {
            vexpand = true,
            valign = Gtk.Align.END
        };

        update_entry_test_usable ();

        size_group[0].add_widget (switch_layout_label);
        size_group[0].add_widget (compose_key_label);
        size_group[0].add_widget (overlay_key_label);
        size_group[0].add_widget (caps_lock_label);

        var grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        grid.attach (switch_layout_label, 0, 0);
        grid.attach (switch_layout_combo, 1, 0);
        grid.attach (compose_key_label, 0, 1);
        grid.attach (compose_key_combo, 1, 1);
        grid.attach (overlay_key_label, 0, 2);
        grid.attach (overlay_key_combo, 1, 2);
        grid.attach (caps_lock_label, 0, 3);
        grid.attach (caps_lock_combo, 1, 3);

        var box = new Gtk.Box (VERTICAL, 18);
        box.add (onscreen_keyboard_grid);

        if (GLib.SettingsSchemaSource.get_default ().lookup ("io.elementary.wingpanel.keyboard", true) != null) {
            var indicator_header = new Granite.HeaderLabel (_("Show in Panel"));

            var capslock_check = new Gtk.CheckButton.with_label (_("Caps Lock"));
            var numlock_check = new Gtk.CheckButton.with_label (_("Num Lock"));

            var indicator_settings = new GLib.Settings ("io.elementary.wingpanel.keyboard");
            indicator_settings.bind ("capslock", capslock_check, "active", DEFAULT);
            indicator_settings.bind ("numlock", numlock_check, "active", DEFAULT);

            var panel_box = new Gtk.Box (VERTICAL, 6);
            panel_box.add (indicator_header);
            panel_box.add (capslock_check);
            panel_box.add (numlock_check);

            box.add (panel_box);
        }

        box.add (display);
        box.add (grid);
        box.add (advanced_settings);
        box.add (entry_test);

        var clamp = new Hdy.Clamp () {
            child = box
        };

        add (clamp);

        // Cannot be just called from the constructor because the stack switcher
        // shows every child after the constructor has been called
        advanced_settings.map.connect (() => {
            show_panel_for_active_layout ();
        });

        settings.notify["active-index"].connect (() => {
            update_entry_test_usable ();
            show_panel_for_active_layout ();
        });

        var gala_behavior_settings = new GLib.Settings ("org.pantheon.desktop.gala.behavior");

        var overlay_string = gala_behavior_settings.get_string ("overlay-action");

        switch (overlay_string) {
            case "":
                overlay_key_combo.active = 0;
                break;
            case "io.elementary.wingpanel --toggle-indicator=app-launcher":
                overlay_key_combo.active = 1;
                break;
            case MULTITASKING_VIEW_COMMAND:
                overlay_key_combo.active = 2;
                break;
            case "io.elementary.shortcut-overlay":
                overlay_key_combo.active = 3;
                break;
        }

        onscreen_keyboard_settings.clicked.connect (() => {
            try {
                var appinfo = AppInfo.create_from_commandline ("onboard-settings", null, AppInfoCreateFlags.NONE);
                appinfo.launch (null, null);
            } catch (Error e) {
                warning ("Unable to launch onboard-settings: %s", e.message);
            }
        });

        var applications_settings = new GLib.Settings ("org.gnome.desktop.a11y.applications");

        applications_settings.bind ("screen-keyboard-enabled", onscreen_keyboard_switch, "active", SettingsBindFlags.DEFAULT);

        overlay_key_combo.changed.connect (() => {
            var combo_active = overlay_key_combo.active;

            if (combo_active == 0) {
                gala_behavior_settings.set_string ("overlay-action", "");
            } else if (combo_active == 1) {
                gala_behavior_settings.set_string ("overlay-action", "io.elementary.wingpanel --toggle-indicator=app-launcher");
            } else if (combo_active == 2) {
                gala_behavior_settings.set_string ("overlay-action", MULTITASKING_VIEW_COMMAND);
            } else if (combo_active == 3) {
                gala_behavior_settings.set_string ("overlay-action", "io.elementary.shortcut-overlay");
            }
        });
    }

    private AdvancedSettingsPanel? third_level_layouts_panel () {
        var modifier = settings.get_xkb_modifier_by_name ("third_level_key");

        if (modifier == null) {
            return null;
        }

        string [] invalid_input_sources = {
            "am*", "ara*", "az+cyrillic",
           "bg*", "by", "by+legacy",
           "ca+eng", "ca+ike", "cm", "cn*", "cz+ucw",
           "fr+dvorak",
           "ge+os", "ge+ru", "gr+nodeadkeys", "gr+simple",
           "ie+ogam", "il*", "in+ben_gitanjali", "in+ben_inscript", "in+tam_keyboard_with_numerals",
           "in+tam_TAB", "in+tam_TSCII", "in+tam_unicode", "iq",
           "jp*",
           "kg*", "kz*",
           "la*", "lk+tam_TAB", "lk+tam_unicode",
           "mk*", "mv*",
           "no+mac", "no+mac_nodeadkeys", "np*",
           "pk+ara",
           "ru", "ru+dos", "ru+legacy", "ru+mac", "ru+os_legacy", "ru+os_winkeys",
           "ru+phonetic", "ru+phonetic_winkeys", "ru+typewriter", "ru+typewriter-legacy",
           "sy", "sy+syc", "sy+syc_phonetic",
           "th*", "tz*",
           "ua+homophonic", "ua+legacy", "ua+phonetic", "ua+rstu", "ua+rstu_ru",
           "ua+typewriter", "ua+winkeys", "us", "us+chr", "us+dvorak", "us+dvorak-classic",
           "us+dvorak-l", "us+dvorak-r", "uz*"
        };

        var third_level_label = new Gtk.Label (_("Key to choose 3rd level:"));

        var panel = new AdvancedSettingsPanel ("third_level_layouts", {}, invalid_input_sources);

        var third_level_combo = new XkbComboBox (modifier, size_group[1]);

        panel.attach (third_level_label, 0, 0);
        panel.attach (third_level_combo, 1, 0);

        panel.show_all ();

        return panel;
    }

    private AdvancedSettingsPanel fifth_level_layouts_panel () {
        var panel = new AdvancedSettingsPanel ("fifth_level_layouts", {"ca+multix"});

        var third_level_label = new Gtk.Label (_("Key to choose 3rd level:")) {
            xalign = 0
        };

        size_group[0].add_widget (third_level_label);

        XkbModifier modifier = new XkbModifier ("third_level_key");
        modifier.append_xkb_option ("", _("Default"));
        modifier.append_xkb_option ("lv3:caps_switch", _("Caps Lock"));
        modifier.append_xkb_option ("lv3:lalt_switch", _("Left Alt"));
        modifier.append_xkb_option ("lv3:ralt_switch", _("Right Alt"));
        modifier.append_xkb_option ("lv3:switch", _("Right Ctrl"));
        modifier.append_xkb_option ("lv3:rwin", _("Right ⌘"));

        modifier.set_default_command ("");
        settings.add_xkb_modifier (modifier);

        var third_level_combo = new XkbComboBox (modifier, size_group[1]);

        var fifth_level_label = new Gtk.Label (_("Key to choose 5th level:"));

        modifier = new XkbModifier ();
        modifier.append_xkb_option ("lv5:ralt_switch_lock", _("Right Alt"));
        modifier.append_xkb_option ("", _("Right Ctrl"));
        modifier.append_xkb_option ("lv5:rwin_switch_lock", _("Right ⌘"));
        modifier.set_default_command ("");
        settings.add_xkb_modifier (modifier);

        var fifth_level_combo = new XkbComboBox (modifier, size_group[1]);

        panel.attach (third_level_label, 0, 0, 1, 1);
        panel.attach (third_level_combo, 1, 0, 1, 1);
        panel.attach (fifth_level_label, 0, 1, 1, 1);
        panel.attach (fifth_level_combo, 1, 1, 1, 1);
        panel.show_all ();

        return panel;
    }

    private AdvancedSettingsPanel japanese_layouts_panel () {
        var kana_lock_label = new Gtk.Label (_("Kana Lock:")) {
            xalign = 0
        };

        size_group[0].add_widget (kana_lock_label);

        var kana_lock_switch = new XkbOptionSwitch (settings, "japan:kana_lock");

        // Used to align this grid without expanding the switch itself
        var spacer_grid = new Gtk.Grid ();
        spacer_grid.add (kana_lock_switch);
        size_group[1].add_widget (spacer_grid);

        var nicola_backspace_label = new Gtk.Label (_("Nicola F Backspace:")) {
            xalign = 0
        };

        size_group[0].add_widget (nicola_backspace_label);

        var nicola_backspace_switch = new XkbOptionSwitch (settings, "japan:nicola_f_bs");

        var zenkaku_label = new Gtk.Label (_("Hankaku Zenkaku as Escape:")) {
            xalign = 0
        };

        size_group[0].add_widget (zenkaku_label);

        var zenkaku_switch = new XkbOptionSwitch (settings, "japan:hztg_escape");

        string [] valid_input_sources = {"jp"};
        var panel = new AdvancedSettingsPanel ( "japanese_layouts", valid_input_sources );
        panel.attach (kana_lock_label, 0, 0, 1, 1);
        panel.attach (spacer_grid, 1, 0, 1, 1);
        panel.attach (nicola_backspace_label, 0, 1, 1, 1);
        panel.attach (nicola_backspace_switch, 1, 1, 1, 1);
        panel.attach (zenkaku_label, 0, 2, 1, 1);
        panel.attach (zenkaku_switch, 1, 2, 1, 1);
        panel.show_all ();

        return panel;
    }

    private AdvancedSettingsPanel korean_layouts_panel () {
        var hangul_label = new Gtk.Label (_("Hangul/Hanja keys on Right Alt/Ctrl:")) {
            xalign = 0
        };

        size_group[0].add_widget (hangul_label);

        var hangul_switch = new XkbOptionSwitch (settings, "korean:ralt_rctrl");

        // Used to align this grid without expanding the switch itself
        var spacer_grid = new Gtk.Grid ();
        spacer_grid.add (hangul_switch);
        size_group[1].add_widget (spacer_grid);

        string [] valid_input_sources = {"kr"};
        var panel = new AdvancedSettingsPanel ("korean_layouts", valid_input_sources);
        panel.attach (hangul_label, 0, 0, 1, 1);
        panel.attach (spacer_grid, 1, 0, 1, 1);
        panel.show_all ();

        return panel;
    }

    private void show_panel_for_active_layout () {
        var active_layout = settings.active_input_source;
        if (active_layout != null) {
            advanced_settings.set_visible_panel_from_layout (active_layout.name);
        } else {
            advanced_settings.set_visible_panel_from_layout (null);
        }
    }

    private class XkbComboBox : Gtk.ComboBoxText {
        public XkbComboBox (XkbModifier modifier, Gtk.SizeGroup size_group) {
            valign = Gtk.Align.CENTER;
            size_group.add_widget (this);

            for (int i = 0; i < modifier.xkb_option_commands.length; i++) {
                append (modifier.xkb_option_commands[i], modifier.option_descriptions[i]);
            }

            set_active_id (modifier.get_active_command ());

            changed.connect (() => {
                modifier.update_active_command (active_id);
            });

            modifier.active_command_updated.connect (() => {
                set_active_id (modifier.get_active_command ());
            });
        }
    }

    private class XkbOptionSwitch : Gtk.Switch {
        public XkbOptionSwitch (SourceSettings settings, string xkb_command) {
            halign = Gtk.Align.START;
            valign = Gtk.Align.CENTER;

            var modifier = new XkbModifier ("" + xkb_command);
            modifier.append_xkb_option ("", "option off");
            modifier.append_xkb_option (xkb_command, "option on");

            settings.add_xkb_modifier (modifier);

            if (modifier.get_active_command () == "") {
                active = false;
            } else {
                active = true;
            }

            notify["active"].connect (() => {
                if (active) {
                    modifier.update_active_command (xkb_command);
                } else {
                    modifier.update_active_command ("");
                }
            });
        }
    }

    private void update_entry_test_usable () {
        if (settings.active_input_source != null &&
            settings.active_input_source.layout_type == LayoutType.XKB) {

            entry_test.placeholder_text = _("Type to test your layout");
            entry_test.sensitive = true;
        } else {
            entry_test.placeholder_text = _("Input Method is active");
            entry_test.sensitive = false;
        }
    }
}
