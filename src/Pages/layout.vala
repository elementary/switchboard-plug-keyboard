namespace Pantheon.Keyboard.LayoutPage
{
	// global handler
	LayoutHandler handler;

	class AdvancedSettingsPanel : Gtk.Grid
	{
		public string name;
		public string [] input_sources;
		public AdvancedSettingsPanel ( string name, string [] input_sources ) {
			this.name = name;
			this.input_sources = input_sources;

			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin_top     = 12;
			this.margin_bottom  = 12;
			this.column_homogeneous = false;
			this.row_homogeneous    = false;

			this.hexpand = true;
			this.halign = Gtk.Align.CENTER;
		}
	}

	class AdvancedSettings : Gtk.Grid
	{
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

			foreach ( AdvancedSettingsPanel panel in panels ){
				stack.add_named ( panel, panel.name );
				foreach ( string layout_name in panel.input_sources ){
					// currently we only want *one* panel per input-source
					panel_for_layout.insert ( layout_name, panel.name );
				}
			}
		}

		public void set_visible_panel_from_layout ( string layout_name ){
			string panel_name = panel_for_layout.lookup (layout_name) ;

			if (panel_name == null ) {
				// if panel_name was not found we look for the layout without variant
				if ("+" in layout_name) {
					var splited_name = layout_name.split ("+");
					layout_name = splited_name[0];
					panel_name = panel_for_layout.lookup (layout_name) ;
				}
				if (panel_name == null ) {
					// this.hide() cannot be used because it messes the alignment`
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
			size_group = {new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL), new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL)};

			// Different layouts per window
			add_label ( this, _("Allow different layouts for individual windows:"), 0, 1);

			var switch_main = new Gtk.Switch();
			switch_main.expand = false;
			switch_main.halign = Gtk.Align.START;
			switch_main.valign = Gtk.Align.CENTER;
			var box = new Gtk.Box ( Gtk.Orientation.HORIZONTAL, 0 );
			box.pack_start (switch_main, false, false, 0);
			this.attach (box, 2, 0, 1, 1);
			size_group[1].add_widget (box);

            switch_main.active = settings.per_window;

			switch_main.notify["active"].connect(() => {
                settings.per_window = switch_main.active;
			});
            settings.per_window_changed.connect (() => {
                switch_main.active = settings.per_window;
            });

			// Compose key position menu

			add_label ( this, _("Compose key:"), 1, 1);
			
			var compose_key = new Gtk.ComboBoxText ();
			compose_key.append ("", _("Disabled"));
			compose_key.append ("compose:ralt", _("Right Alt (Alt Gr)"));
			compose_key.append ("compose:rwin", _("Right Super"));
			compose_key.append ("compose:rctrl", _("Right Control"));
			compose_key.append ("compose:lctrl", _("Left Control"));
			compose_key.append ("compose:lwin", _("Left Super"));
			compose_key.append ("compose:caps", _("Caps Lock"));
			compose_key.append ("compose:pause", _("Pause"));
			compose_key.append ("compose:menu", _("Menu"));

			compose_key.set_active_id ("");

			compose_key.halign = Gtk.Align.START;
			compose_key.valign = Gtk.Align.CENTER;
			this.attach (compose_key, 2, 1, 1, 1);
			size_group[1].add_widget (compose_key);

			// Caps Lock key functionality
			add_label (this, _("Caps Lock function:"), 2, 1);
			
			var caps_lock = new Gtk.ComboBoxText ();
			caps_lock.append ("caps:capslock", _("Caps Lock"));
			caps_lock.append ("caps:numlock", _("Num Lock"));
			caps_lock.append ("caps:escape", _("Escape"));
			caps_lock.append ("caps:backspace", _("Backspace"));
			caps_lock.append ("caps:super", _("Super"));
			caps_lock.append ("caps:hyper", _("Hyper"));
			caps_lock.append ("caps:none", _("Disabled"));
			caps_lock.append ("ctrl:nocaps", _("Control"));
			caps_lock.append ("ctrl:swapcaps", _("Swap With Control"));
			caps_lock.append ("caps:swapescape", _("Swap With Escape"));

			caps_lock.set_active_id ("caps:capslock");

			caps_lock.halign = Gtk.Align.START;
			caps_lock.valign = Gtk.Align.CENTER;
			this.attach (caps_lock, 2, 2, 1, 1);
			size_group[1].add_widget (caps_lock);

			// tree view to display the current layouts
			display = new LayoutPage.Display ();
			this.attach (display, 0, 0, 1, 4);

			// Advanced settings panel
			AdvancedSettingsPanel [] panels = { third_level_layouts_panel (),
												fifth_level_layouts_panel (),
												japanese_layouts_panel () };
			this.advanced_settings = new AdvancedSettings ( panels, settings );

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
			var entry_test = new Granite.Widgets.HintedEntry (_("Type to test your layout…"));

			entry_test.has_clear_icon = true;
			entry_test.hexpand = entry_test.vexpand = true;
			entry_test.valign  = Gtk.Align.START;

			//this.attach (entry_test, 4, 3, 3, 1);
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
												"za"};

			var panel = new AdvancedSettingsPanel ( "third_level_layouts", valid_input_sources );

			add_label ( panel, _("Key to choose third level:"), 0);


			var third_level = new Gtk.ComboBoxText ();
			third_level.append ("lv3:ralt_switch", _("Right Alt (Alt Gr)"));
			third_level.append ("lv3:switch", _("Right Control"));
			third_level.append ("lv3:menu_switch", _("Menu"));
			third_level.append ("lv3:win_switch", _("Super"));
			third_level.append ("lv3:lwin_switch", _("Left Super"));
			third_level.append ("lv3:rwin_switch", _("Right Super"));
			third_level.append ("lv3:alt_switch", _("Alt"));
			third_level.append ("lv3:ralt_switch", _("Right Alt"));
			third_level.append ("lv3:lalt_switch", _("Left Alt"));
			third_level.append ("lv3:ralt_alt", _("Disabled"));
			third_level.append ("lv3:caps_switch", _("Caps Lock"));
			third_level.append ("lv3:bksl_switch", _("Backslash"));

			third_level.set_active_id ("lv3:ralt_switch");

			third_level.halign = Gtk.Align.START;
			third_level.valign = Gtk.Align.CENTER;
			panel.attach (third_level, 1, 0, 1, 1);
			size_group[1].add_widget (third_level);
			panel.show_all ();

			return panel;
		}

		private AdvancedSettingsPanel fifth_level_layouts_panel () {
			var panel = third_level_layouts_panel ();
			panel.input_sources = {"ca+multix"};
			panel.name = "fifth_level_layouts";

			add_label ( panel, _("Key to choose fifth level:"), 1);

			var fifth_level = new Gtk.ComboBoxText ();
			fifth_level.append ("", _("Right Control"));
			fifth_level.append ("lv5:switch", _("Right Alt"));
			fifth_level.append ("lv5:ralt_switch_lock", _("Right Alt"));
			fifth_level.append ("lv5:lwin_switch_lock", _("Left Super"));
			fifth_level.append ("lv5:rwin_switch_lock", _("Right Super"));
			fifth_level.append ("lv5:lsgt_switch_lock" , _("Less/Grater"));

			fifth_level.set_active_id ("");

			fifth_level.halign = Gtk.Align.START;
			fifth_level.valign = Gtk.Align.CENTER;
			panel.attach (fifth_level, 1, 1, 1, 1);
			size_group[1].add_widget (fifth_level);
			panel.show_all ();

			return panel;
		}

		private AdvancedSettingsPanel japanese_layouts_panel () {
			string [] valid_input_sources = {"jp", "jp+kana86", "jp+OADG109A", "jp+mac", "jp+kana", "nec_vndr/jp"};
			var panel = new AdvancedSettingsPanel ( "japanese_layouts", valid_input_sources );

			add_label (panel, _("Nicola F Backspace:"), 0);
			add_switch (panel, 0);

			add_label (panel, _("Kana Lock:"), 1);
			add_switch (panel, 1);

			add_label (panel, _("Zenkaku Hankaku as Escape:"), 2);
			add_switch (panel, 2);

			panel.show_all ();

			return panel;
		}


		private void add_switch (Gtk.Grid panel, int v_position) {

			var new_switch = new Gtk.Switch ();
			new_switch.halign = Gtk.Align.START;
			new_switch.valign = Gtk.Align.CENTER;
			
			// There is a bug that makes the switch go outside its socket, this
			// is a workaround for that.
			var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
			box.pack_start (new_switch, false, false, 0);
			panel.attach (box, 1, v_position, 1, 1);
			size_group[1].add_widget (box);
		}

		private void add_label (Gtk.Grid panel, string text, int v_position, int h_position = 0) {
			// v_position is relative to the panel provided
			var new_label   = new Gtk.Label (text);
			new_label.valign = Gtk.Align.CENTER;
			//TODO: set_alignment is deprecated watch for https://bugzilla.gnome.org/show_bug.cgi?id=733981
			// should be:
			//new_label.halign = Gtk.Align.END;
			new_label.set_alignment (1, 0.5f);
			panel.attach (new_label, h_position, v_position, 1, 1);
			size_group[0].add_widget (new_label);
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
