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

namespace Keyboard {
    public class LayoutPage.Page : Gtk.Box {
        private Display display;
        private SourceSettings settings;
        private AdvancedSettings advanced_settings;
        private Gtk.Entry entry_test;
        private const string MULTITASKING_VIEW_COMMAND = "dbus-send --session --dest=org.pantheon.gala --print-reply /org/pantheon/gala org.pantheon.gala.PerformAction int32:1";

        construct {
            settings = SourceSettings.get_instance ();

            // tree view to display the current layouts
            display = new LayoutPage.Display ();

            var switch_layout_label = new SettingsLabel (_("Switch Layout")) ;

            var switch_layout_list = new Shortcuts.ShortcutListBox (Shortcuts.SectionID.LAYOUTS);

            var switch_layout_list_frame = new Gtk.Frame (null) {
                child = switch_layout_list
            };

            var switch_layout_additional_label = new SettingsLabel (_("Additional Shortcuts"));

            // Layout switching keybinding
            var modifier = new XkbModifier ("switch-layout");
            modifier.append_xkb_option ("", _("Disabled"));
            modifier.append_xkb_option ("grp:alt_caps_toggle", _("Alt + Caps Lock"));
            modifier.append_xkb_option ("grp:alt_shift_toggle", _("Alt + Shift"));
            modifier.append_xkb_option ("grp:caps_toggle", _("Caps Lock"));
            modifier.append_xkb_option ("grp:ctrl_alt_toggle", _("Ctrl + Alt"));
            modifier.append_xkb_option ("grp:ctrl_shift_toggle", _("Ctrl + Shift"));
            modifier.append_xkb_option ("grp:shift_caps_toggle", _("Shift + Caps Lock"));
            modifier.set_default_command ("");

            settings.add_xkb_modifier (modifier);

            var switch_layout_flowbox = new XkbFlowBox (modifier);

            var compose_key_label = new SettingsLabel (_("Compose key"));

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

            var compose_key_flowbox = new XkbFlowBox (modifier);

            var overlay_key_label = new SettingsLabel (_("⌘ key behavior"));

            // ⌘ key behavior
            var overlay_key_flowbox = new Gtk.FlowBox () {
                homogeneous = true,
                row_spacing = 12,
                column_spacing = 12,
                selection_mode = NONE,
                max_children_per_line = 3
            };

            var overlay_key_disabled = new RadioButtonWithValue (null, _("Disabled"), "");
            overlay_key_flowbox.add (overlay_key_disabled);
            var overlay_key_application_menu = new RadioButtonWithValue (overlay_key_disabled, _("Applications Menu"), "io.elementary.wingpanel --toggle-indicator=app-launcher");
            overlay_key_flowbox.add (overlay_key_application_menu);
            var overlay_key_multitasking_view = new RadioButtonWithValue (overlay_key_disabled, _("Multitasking View"), MULTITASKING_VIEW_COMMAND);
            overlay_key_flowbox.add (overlay_key_multitasking_view);

            string? cheatsheet_path = Environment.find_program_in_path ("io.elementary.shortcut-overlay");
            if (cheatsheet_path != null) {
                var overlay_key_shortcut_overlay = new RadioButtonWithValue (overlay_key_disabled, _("Shortcut Overlay"), "io.elementary.shortcut-overlay");
                overlay_key_flowbox.add (overlay_key_shortcut_overlay);
            }

            var caps_lock_label = new SettingsLabel (_("Caps Lock behavior"));

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

            var caps_lock_flowbox = new XkbFlowBox (modifier);

            // Advanced settings panel
            AdvancedSettingsPanel? [] panels = {fifth_level_layouts_panel (),
                                                japanese_layouts_panel (),
                                                korean_layouts_panel (),
                                                third_level_layouts_panel ()};

            advanced_settings = new AdvancedSettings (panels);

            entry_test = new Gtk.Entry ();

            update_entry_test_usable ();

            var settings_box = new Gtk.Box (VERTICAL, 12);
            settings_box.add (switch_layout_label);
            settings_box.add (switch_layout_list_frame);
            settings_box.add (switch_layout_additional_label);
            settings_box.add (switch_layout_flowbox);
            settings_box.add (compose_key_label);
            settings_box.add (compose_key_flowbox);
            settings_box.add (overlay_key_label);
            settings_box.add (overlay_key_flowbox);
            settings_box.add (caps_lock_label);
            settings_box.add (caps_lock_flowbox);
            settings_box.add (advanced_settings);

            var scrolled_window = new Gtk.ScrolledWindow (null, null) {
                child = settings_box,
                hscrollbar_policy = NEVER,
                hexpand = true,
                vexpand = true
            };

            var main_box = new Gtk.Box (VERTICAL, 12);
            main_box.add (scrolled_window);
            main_box.add (entry_test);

            orientation = HORIZONTAL;
            spacing = 12;
            margin_start = 12;
            margin_end = 12;
            margin_bottom = 12;

            add (display);
            add (main_box);
            show_all ();

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
            foreach (unowned var child in overlay_key_flowbox.get_children ()) {
                unowned var flow_box_child = (Gtk.FlowBoxChild) child;
                unowned var button = (RadioButtonWithValue) flow_box_child.get_child ();

                button.active = button.value == gala_behavior_settings.get_string ("overlay-action");

                button.toggled.connect (() => {
                    if (button.active) {
                        gala_behavior_settings.set_string ("overlay-action", button.value);
                    }
                });
            }
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

            var third_level_label = new SettingsLabel (_("Key to choose 3rd level"));

            var panel = new AdvancedSettingsPanel ("third_level_layouts", {}, invalid_input_sources);

            var third_level_flowbox = new XkbFlowBox (modifier);

            panel.attach (third_level_label, 0, 0);
            panel.attach (third_level_flowbox, 0, 1);

            panel.show_all ();

            return panel;
        }

        private AdvancedSettingsPanel fifth_level_layouts_panel () {
            var panel = new AdvancedSettingsPanel ("fifth_level_layouts", {"ca+multix"});

            var third_level_label = new Gtk.Label (_("Key to choose 3rd level")) ;

            XkbModifier modifier = new XkbModifier ("third_level_key");
            modifier.append_xkb_option ("", _("Default"));
            modifier.append_xkb_option ("lv3:caps_switch", _("Caps Lock"));
            modifier.append_xkb_option ("lv3:lalt_switch", _("Left Alt"));
            modifier.append_xkb_option ("lv3:ralt_switch", _("Right Alt"));
            modifier.append_xkb_option ("lv3:switch", _("Right Ctrl"));
            modifier.append_xkb_option ("lv3:rwin", _("Right ⌘"));

            modifier.set_default_command ("");
            settings.add_xkb_modifier (modifier);

            var third_level_flowbox = new XkbFlowBox (modifier);

            var fifth_level_label = new SettingsLabel (_("Key to choose 5th level"));

            modifier = new XkbModifier ();
            modifier.append_xkb_option ("lv5:ralt_switch_lock", _("Right Alt"));
            modifier.append_xkb_option ("", _("Right Ctrl"));
            modifier.append_xkb_option ("lv5:rwin_switch_lock", _("Right ⌘"));
            modifier.set_default_command ("");
            settings.add_xkb_modifier (modifier);

            var fifth_level_flowbox = new XkbFlowBox (modifier);

            panel.attach (third_level_label, 0, 0);
            panel.attach (third_level_flowbox, 0, 1);
            panel.attach (fifth_level_label, 0, 2);
            panel.attach (fifth_level_flowbox, 1, 3);
            panel.show_all ();

            return panel;
        }

        private AdvancedSettingsPanel japanese_layouts_panel () {
            var kana_lock_label = new Gtk.Label (_("Kana Lock:")) {
                xalign = 1
            };
            var kana_lock_switch = new XkbOptionSwitch (settings, "japan:kana_lock");

            // Used to align this grid without expanding the switch itself
            var spacer_grid = new Gtk.Grid ();
            spacer_grid.add (kana_lock_switch);

            var nicola_backspace_label = new Gtk.Label (_("Nicola F Backspace:")) {
                xalign = 1
            };
            var nicola_backspace_switch = new XkbOptionSwitch (settings, "japan:nicola_f_bs");

            var zenkaku_label = new Gtk.Label (_("Hankaku Zenkaku as Escape:")) {
                xalign = 1
            };
            var zenkaku_switch = new XkbOptionSwitch (settings, "japan:hztg_escape");

            string [] valid_input_sources = {"jp"};
            var panel = new AdvancedSettingsPanel ( "japanese_layouts", valid_input_sources ) {
                halign = CENTER,
                margin_top = 12 // additional margin to better separate switches from radio buttons
            };
            panel.attach (kana_lock_label, 0, 0);
            panel.attach (spacer_grid, 1, 0);
            panel.attach (nicola_backspace_label, 0, 1);
            panel.attach (nicola_backspace_switch, 1, 1);
            panel.attach (zenkaku_label, 0, 2);
            panel.attach (zenkaku_switch, 1, 2);
            panel.show_all ();

            return panel;
        }

        private AdvancedSettingsPanel korean_layouts_panel () {
            var hangul_label = new Gtk.Label (_("Hangul/Hanja keys on Right Alt/Ctrl:")) {
                xalign = 1
            };
            var hangul_switch = new XkbOptionSwitch (settings, "korean:ralt_rctrl");

            // Used to align this grid without expanding the switch itself
            var spacer_grid = new Gtk.Grid ();
            spacer_grid.add (hangul_switch);

            string [] valid_input_sources = {"kr"};
            var panel = new AdvancedSettingsPanel ("korean_layouts", valid_input_sources) {
                halign = CENTER,
                margin_top = 12 // additional margin to better separate switches from radio buttons
            };
            panel.attach (hangul_label, 0, 0);
            panel.attach (spacer_grid, 1, 0);
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

        private class XkbFlowBox : Gtk.FlowBox {
            public XkbModifier modifier { get; construct; }

            private signal void changed ();

            public XkbFlowBox (XkbModifier modifier) {
                Object (modifier: modifier);
            }

            construct {
                hexpand = true;
                homogeneous = true;
                row_spacing = 12;
                column_spacing = 12;
                selection_mode = NONE;
                max_children_per_line = 3;

                RadioButtonWithValue? previous_button = null;
                for (int i = 0; i < modifier.xkb_option_commands.length; i++) {
                    var button = new RadioButtonWithValue (previous_button, modifier.option_descriptions[i], modifier.xkb_option_commands[i]);
                    add (button);

                    button.toggled.connect (() => modifier.update_active_command (get_active_value ()));

                    previous_button = button;
                }

                set_active (modifier.get_active_command ());

                modifier.active_command_updated.connect (() => {
                    set_active (modifier.get_active_command ());
                });
            }

            private void set_active (string value) {
                foreach (unowned var child in get_children ()) {
                    unowned var flow_box_child = (Gtk.FlowBoxChild) child;
                    unowned var button = (RadioButtonWithValue) flow_box_child.get_child ();
                    button.active = button.value == value;
                }
            }

            private string get_active_value () {
                foreach (unowned var child in get_children ()) {
                    unowned var flow_box_child = (Gtk.FlowBoxChild) child;
                    unowned var button = (RadioButtonWithValue) flow_box_child.get_child ();

                    if (button.active) {
                        return button.value;
                    }
                }

                return "";
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

        private class SettingsLabel : Gtk.Label {
            public SettingsLabel (string label) {
                Object (label: label);

                halign = START;
                get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            }
        }

        private class RadioButtonWithValue : Gtk.Box {
            public signal void toggled ();

            public RadioButtonWithValue? group_member { get; construct; }
            public string label { get; construct; }
            public string value { get; construct; }
            public Gtk.RadioButton radio_button { get; private set; }

            public bool active {
                get {
                    return radio_button.active;
                }
                set {
                    radio_button.active = value;
                }
            }

            public RadioButtonWithValue (RadioButtonWithValue? group_member, string label, string value) {
                Object (
                    group_member: group_member,
                    label: label,
                    value: value
                );
            }

            construct {
                Gtk.RadioButton? radio_group_member = null;
                if (group_member != null) {
                    radio_group_member = group_member.radio_button;
                }

                radio_button = new Gtk.RadioButton.with_label_from_widget (radio_group_member, label);
                add (radio_button);

                radio_button.toggled.connect (() => toggled ());
            }
        }
    }
}
