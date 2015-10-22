namespace Pantheon.Keyboard.LayoutPage {
    // global handler
    LayoutHandler handler;

    class AdvancedSettingsPanel : Gtk.Grid {
        public string name;
        public string [] input_sources;
        public AdvancedSettingsPanel ( string name, string [] input_sources ) {
            this.name = name;
            this.input_sources = input_sources;

            this.row_spacing = 12;
            this.column_spacing = 12;
            this.margin_top = 12;
            this.margin_bottom  = 12;
            this.column_homogeneous = false;
            this.row_homogeneous = false;

            this.hexpand = true;
            this.halign = Gtk.Align.CENTER;
        }
    }

    class AdvancedSettings : Gtk.Grid {
        private Gtk.Separator sep;
        private Gtk.Stack stack;
        private HashTable <string, string> panel_for_layout;

        public AdvancedSettings ( AdvancedSettingsPanel [] panels, LayoutSettings settings) {
            sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            panel_for_layout = new HashTable <string, string> (str_hash, str_equal);
            this.attach (sep, 0, 0, 1, 1);

            stack = new Gtk.Stack ();
            stack.hexpand = true;
            this.attach (stack, 0, 1, 1, 1);

            // Add an empty Widget
            var blank_panel = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            stack.add_named (blank_panel, "none");
            blank_panel.show();

            foreach ( AdvancedSettingsPanel panel in panels ) {
                stack.add_named ( panel, panel.name );
                foreach ( string layout_name in panel.input_sources ) {
                    // currently we only want *one* panel per input-source
                    panel_for_layout.insert ( layout_name, panel.name );
                }
            }
        }

        public void set_visible_panel_from_layout ( string layout_name ){
            string panel_name = panel_for_layout.lookup (layout_name) ;

            if (panel_name == null ) {
                // if layout_name was not found we look for the layout without variant
                if ("+" in layout_name) {
                    var splited_name = layout_name.split ("+");
                    layout_name = splited_name[0];
                    panel_name = panel_for_layout.lookup (layout_name) ;
                }
                if (panel_name == null ) {
                    // this.hide() cannot be used because it messes the alignment
                    this.stack.set_visible_child_name ("none");
                    this.sep.hide();
                    return;
                }
            }

            this.stack.set_visible_child_name (panel_name);
            this.sep.show();
        }
    }

	class Page : Pantheon.Keyboard.AbstractPage
	{
		private LayoutPage.Display display;
		private LayoutSettings settings;
        private Gtk.SizeGroup [] size_group;
        private AdvancedSettings advanced_settings;

		public override void reset ()
		{
			settings.reset_all ();
			display.reset_all ();
			return;
		}

		public Page ()
		{
			handler  = new LayoutHandler ();
			settings = LayoutSettings.get_instance ();
            size_group = { new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL),
                           new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL) };

            // Different layouts per window
            new_label (this, _("Allow different layouts for individual windows:"), 0, 1);

            var layouts_per_window_sw = new_switch (this, 0, 2);

            layouts_per_window_sw.active = settings.per_window;
            layouts_per_window_sw.notify["active"].connect(() => {
                settings.per_window = layouts_per_window_sw.active;
            });
            settings.per_window_changed.connect (() => {
                layouts_per_window_sw.active = settings.per_window;
            });

            // Compose key position menu
            new_label (this, _("Compose key:"), 1, 1);
            Xkb_modifier modifier = new Xkb_modifier ();
            modifier.append_xkb_option ("", _("Disabled"));
            modifier.append_xkb_option ("compose:ralt", _("Right Alt (Alt Gr)"));
            modifier.append_xkb_option ("compose:rwin", _("Right Super"));
            modifier.append_xkb_option ("compose:rctrl", _("Right Control"));
            modifier.append_xkb_option ("compose:lctrl", _("Left Control"));
            modifier.append_xkb_option ("compose:lwin", _("Left Super"));
            modifier.append_xkb_option ("compose:caps", _("Caps Lock"));
            modifier.append_xkb_option ("compose:paus", _("Pause"));
            modifier.append_xkb_option ("compose:menu", _("Menu"));
            modifier.default_command = "";
            settings.add_xkb_modifier (modifier);

            var compose_combo_box = new_combo_box (this, modifier, 1, 2);

            // Caps Lock key functionality
            var caps_label = new_label (this, _("Caps Lock function:"), 2, 1);

            modifier = new Xkb_modifier ();
            modifier.append_xkb_option ("caps:capslock", _("Caps Lock"));
            modifier.append_xkb_option ("caps:numlock", _("Num Lock"));
            modifier.append_xkb_option ("caps:escape", _("Escape"));
            modifier.append_xkb_option ("caps:backspace", _("Backspace"));
            modifier.append_xkb_option ("caps:super", _("Super"));
            modifier.append_xkb_option ("caps:hyper", _("Hyper"));
            modifier.append_xkb_option ("caps:none", _("Disabled"));
            modifier.append_xkb_option ("ctrl:nocaps", _("Control"));
            modifier.append_xkb_option ("ctrl:swapcaps", _("Swap With Control"));
            modifier.append_xkb_option ("caps:swapescape", _("Swap With Escape"));
            modifier.default_command = "caps:capslock";
            settings.add_xkb_modifier (modifier);

            var caps_combo_box = new_combo_box (this, modifier, 2, 2);

            compose_combo_box.changed.connect (() => {
                if (compose_combo_box.active_id == "compose:caps") {
                    caps_label.set_sensitive (false);
                    caps_combo_box.set_sensitive (false);
                } else {
                    caps_label.set_sensitive (true);
                    caps_combo_box.set_sensitive (true);
                }
            });

			// tree view to display the current layouts
			display = new LayoutPage.Display ();
            this.attach (display, 0, 0, 1, 5);

            // Advanced settings panel
            AdvancedSettingsPanel [] panels = { third_level_layouts_panel (),
                                                fifth_level_layouts_panel (),
                                                japanese_layouts_panel () };
            this.advanced_settings = new AdvancedSettings (panels, settings);

            advanced_settings.hexpand = advanced_settings.vexpand = true;
            advanced_settings.valign = Gtk.Align.START;
            this.attach (advanced_settings, 1, 3, 2, 1);

            // Cannot be just called from the constructor because the stack switcher
            // shows every child after the constructor has been called
            advanced_settings.map.connect (() => {
                show_panel_for_active_layout ();
            });

            settings.layouts.active_changed.connect (() => {
                show_panel_for_active_layout ();
            });

			// Test entry
			var entry_test = new Gtk.Entry ();
			entry_test.placeholder_text = (_("Type to test your layout…"));

			entry_test.hexpand = entry_test.vexpand = true;
			entry_test.valign  = Gtk.Align.END;

            this.attach (entry_test, 1, 4, 2, 1);
		}

        private AdvancedSettingsPanel third_level_layouts_panel () {
            string [] valid_input_sources = {"al", "az",
                                                "be", "br", "bt",
                                                "ca", "ch", "cs", "cz",
                                                "de","dk",
                                                "ee", "es",
                                                "fi", "fo", "fr",
                                                "gb", "gr",
                                                "hu",
                                                "ie", "ir", "is", "it",
                                                "latam", "lk", "lt",
                                                "mn", "mt",
                                                "nl", "no",
                                                "pl", "pt",
                                                "ro",
                                                "se", "sk",
                                                "tr",
                                                "vn",
                                                "za",
                                                "us+euro", "us+inlt", "us+alt-intl", "us+dvorak-intl",
                                                "us+dvorak-alt-intl", "us+rus", "us+mac", "us+colemak",
                                                "us+altgr-intl", "us+olpc", "us+olpcm", "us+hbs", "us+workman",
                                                "us+workman-intl", "us+norman", "us+cz_sk_de", "us+intl_unicode",
                                                "us+ats", "us+crd"};

            var panel = new AdvancedSettingsPanel ( "third_level_layouts", valid_input_sources );

            new_label (panel, _("Key to choose third level:"), 0);

            Xkb_modifier modifier = new Xkb_modifier ("third_level_key");
            modifier.append_xkb_option ("lv3:ralt_switch", _("Right Alt (Alt Gr)"));
            modifier.append_xkb_option ("lv3:switch", _("Right Control"));
            modifier.append_xkb_option ("lv3:menu_switch", _("Menu"));
            modifier.append_xkb_option ("lv3:win_switch", _("Super"));
            modifier.append_xkb_option ("lv3:lwin_switch", _("Left Super"));
            modifier.append_xkb_option ("lv3:rwin_switch", _("Right Super"));
            modifier.append_xkb_option ("lv3:alt_switch", _("Alt"));
            modifier.append_xkb_option ("lv3:ralt_switch", _("Right Alt"));
            modifier.append_xkb_option ("lv3:lalt_switch", _("Left Alt"));
            modifier.append_xkb_option ("lv3:ralt_alt", _("Disabled"));
            modifier.append_xkb_option ("lv3:caps_switch", _("Caps Lock"));
            modifier.append_xkb_option ("lv3:bksl_switch", _("Backslash"));
            modifier.default_command = "lv3:ralt_switch";
            settings.add_xkb_modifier (modifier);

            new_combo_box (panel, modifier, 0);

            panel.show_all ();

            return panel;
        }

        private AdvancedSettingsPanel fifth_level_layouts_panel () {
            var panel = new AdvancedSettingsPanel ("fifth_level_layouts", {"ca+multix"});

            new_label (panel, _("Key to choose third level:"), 0);
            Xkb_modifier modifier = settings.get_xkb_modifier_by_name ("third_level_key");
            new_combo_box (panel, modifier, 0);

            new_label (panel, _("Key to choose fifth level:"), 1);

            modifier = new Xkb_modifier ();
            modifier.append_xkb_option ("", _("Right Control"));
            modifier.append_xkb_option ("lv5:switch", _("Right Alt"));
            modifier.append_xkb_option ("lv5:ralt_switch_lock", _("Right Alt"));
            modifier.append_xkb_option ("lv5:lwin_switch_lock", _("Left Super"));
            modifier.append_xkb_option ("lv5:rwin_switch_lock", _("Right Super"));
            modifier.append_xkb_option ("lv5:lsgt_switch_lock" , _("Less/Grater"));
            modifier.default_command = "";
            settings.add_xkb_modifier (modifier);

            new_combo_box (panel, modifier, 1);

            panel.show_all ();

            return panel;
        }

        private AdvancedSettingsPanel japanese_layouts_panel () {
            string [] valid_input_sources = {"jp"};
            var panel = new AdvancedSettingsPanel ( "japanese_layouts", valid_input_sources );

            new_label (panel, _("Nicola F Backspace:"), 0);
            new_xkb_option_switch ( panel, "japan:nicola_f_bs", 0);
            new_switch (panel, 0);

            new_label (panel, _("Kana Lock:"), 1);
            new_xkb_option_switch ( panel, "japan:kana_lock", 1);
            new_switch (panel, 1);

            new_label (panel, _("Zenkaku Hankaku as Escape:"), 2);
            new_xkb_option_switch ( panel, "japan:hztg_escape", 2);
            new_switch (panel, 2);

            panel.show_all ();

            return panel;
        }


        // Function that adds a new switch to panel, and sets it up visually
        // and aligning it
        private Gtk.Switch new_switch (Gtk.Grid panel, int v_position, int h_position = 1) {
            var new_switch = new Gtk.Switch ();
            new_switch.halign = Gtk.Align.START;
            new_switch.valign = Gtk.Align.CENTER;

            // There is a bug that makes the switch go outside its socket, this
            // is a workaround for that.
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.pack_start (new_switch, false, false, 0);
            panel.attach (box, h_position, v_position, 1, 1);
            size_group[1].add_widget (box);

            return new_switch;
        }

        // Function that adds a new switch but also cofigures its functionality
        // to enable/disable an xkb-option
        private Gtk.Switch new_xkb_option_switch
            (Gtk.Grid panel, string xkb_command, int v_position, int h_position = 1) {
            var new_switch = new_switch (panel, v_position, h_position);
            Xkb_modifier modifier = new Xkb_modifier ();
            modifier.append_xkb_option ("", "option off");
            modifier.append_xkb_option (xkb_command, "option on");

            if (modifier.active_command == "") {
                new_switch.active = true;
            } else {
                new_switch.active = false;
            }

            new_switch.notify["active"].connect(() => {
                if (new_switch.active) {
                    modifier.active_command = xkb_command;
                } else {
                    modifier.active_command = "";
                }
            });

            settings.per_window_changed.connect (() => {
                if (modifier.active_command == "") {
                    new_switch.active = true;
                } else {
                    new_switch.active = false;
                }
            });

            settings.add_xkb_modifier (modifier);

            return new_switch;
        }

        private Gtk.ComboBoxText new_combo_box
            (Gtk.Grid panel, Xkb_modifier modifier, int v_position, int h_position = 1) {
            var new_combo_box = new Gtk.ComboBoxText ();

            for (int i = 0; i < modifier.xkb_option_commands.length; i++) {
                new_combo_box.append (modifier.xkb_option_commands[i], modifier.option_descriptions[i]);
            }

            new_combo_box.set_active_id (modifier.active_command);

            new_combo_box.changed.connect (() => {
                modifier.active_command = new_combo_box.active_id;
            });

            modifier.active_command_changed.connect (() => {
                new_combo_box.set_active_id (modifier.active_command);
            });


            new_combo_box.halign = Gtk.Align.START;
            new_combo_box.valign = Gtk.Align.CENTER;
            panel.attach (new_combo_box, h_position, v_position, 1, 1);
            size_group[1].add_widget (new_combo_box);

            return new_combo_box;
        }


        private Gtk.Label new_label (Gtk.Grid panel, string text, int v_position, int h_position = 0) {
            // v_position and h_position is relative to the panel provided
            var new_label = new Gtk.Label (text);
            new_label.valign = Gtk.Align.CENTER;
            ((Gtk.Misc) new_label).xalign = 1;
            panel.attach (new_label, h_position, v_position, 1, 1);
            size_group[0].add_widget (new_label);

            return new_label;
        }

        private void show_panel_for_active_layout () {
            Layout active_layout = settings.layouts.get_layout (settings.layouts.active);
            advanced_settings.set_visible_panel_from_layout (active_layout.name);
        }
    }

	// creates a list store from a string vector
	Gtk.ListStore create_list_store (string[] strv)
	{
		Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iter;

		foreach (string item in strv) {
			list_store.append (out iter);
			list_store.set (iter, 0, item);
		}

		return list_store;
	}
}
