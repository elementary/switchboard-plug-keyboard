using Gtk;

using Granite.Widgets;
using Granite.Services;

using Pantheon;
using Pantheon.Switchboard;

class KeyboardPlug : Pantheon.Switchboard.Plug
{
	public KeyboardPlug ()
	{
		var notebook = new Granite.Widgets.StaticNotebook ();
		
		notebook.append_page (page_behaviour (), new Gtk.Label (_("Behaviour")));
		notebook.append_page (page_shortcuts (), new Gtk.Label (_("Shortcuts")));
		notebook.append_page (page_layout    (), new Gtk.Label (_("Layout")));
		
		this.add( notebook );
	}
	/*
	private Gtk.ListStore language_list_store()
	{
			// Create & fill a ListStore:
		Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iter;

		list_store.append (out iter);
		list_store.set (iter, 0, "German");
		list_store.append (out iter);
		list_store.set (iter, 0, "English");

		return list_store;
	}
	
	private Gtk.ListStore layout_list_store()
	{
			// Create & fill a ListStore:
		Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iter;

		list_store.append (out iter);
		list_store.set (iter, 0, "German");
		list_store.append (out iter);
		list_store.set (iter, 0, "German (Switzerland)");

		return list_store;
	}*/
	
	private Gtk.Grid page_layout () 
	{
		var grid = new Gtk.Grid ();
		/*
		grid.row_spacing    = 12;
		grid.column_spacing = 12;
		grid.margin         = 20;
		grid.expand         = true;
		
		// Labels
		var label_language = new Gtk.Label ("Language:");
		var label_layout   = new Gtk.Label ("Layout:");
		
		label_language.valign = Gtk.Align.CENTER;
		label_language.halign = Gtk.Align.END;
		label_layout.valign   = Gtk.Align.CENTER;
		label_layout.halign   = Gtk.Align.END;
		
		grid.attach (label_language, 0, 0, 1, 1);
		grid.attach (label_layout,   0, 1, 1, 1);
		
		// Comco boxes
		var box_language = new Gtk.TreeView.with_model (language_list_store ());
		var box_layout   = new Gtk.ComboBox.with_model (layout_list_store ());
		
		var renderer_language = new Gtk.CellRendererText ();
		var renderer_layout   = new Gtk.CellRendererText ();
		
	//	box_language.pack_start    (renderer_language, true);
		box_layout.pack_start      (renderer_layout,   true);
	//	box_language.add_attribute (renderer_language, "text", 0);
		box_layout.add_attribute   (renderer_layout,   "text", 0);
	//	box_language.active = 0;
		box_language.insert_column_with_attributes (-1, "Language", renderer_language, "text", 0);
		box_layout.active   = 0;

		grid.attach (box_language, 1, 0, 1, 1);
		grid.attach (box_layout,   1, 1, 1, 1);

		// Test entry
		var entry_test = new Granite.Widgets.HintedEntry ("Type to test your layout...");
		
		entry_test.hexpand = true;
		
		entry_test.set_icon_from_stock (Gtk.EntryIconPosition.SECONDARY, Gtk.Stock.CLEAR);
		
		entry_test.icon_press.connect ((pos, event) => 
		{
			if (pos == Gtk.EntryIconPosition.SECONDARY) 
			{
				entry_test.set_text ("");
			}
		});
		
		grid.attach (entry_test, 1, 3, 1, 1);
		*/
		return grid;
	}
	
	private Gtk.Grid page_shortcuts ()
	{
		// TODO
		
		/*
		 * Where to find shortcuts in dconf:
		 *
		 * -> org.gnome.mutter.keybindings
		 * -> org.gnome.settings-daemon.plugins.media-keys
		 * -> org.gnome.desktop.wm.keybindings
		 			close
		 			lower
		 			maximize
		 			minimize
		 			move to workspace x, right, left
		 			switch to workspace x, right, left
		 			toggle-maximize/shaded/on-all-workspaces
		 			show-desktop: shows workspace switcher
		 * -> org.pantheon.desktop.gala.behavior
		 			expose all windows
		 			expose windows
		 			move to first workspace
		 			move to last workspace
		 			zoom in
		 			zoom out
		 * -> org.gnome.settings-daemon.plugins.power (managed in power plug)
		 *
		 */
		
		
		
		return new Gtk.Grid (); 
	}

	private Gtk.Grid page_behaviour ()
	{
		var grid = new Gtk.Grid ();
		
		grid.row_spacing    = 12;
		grid.column_spacing = 12;
		grid.margin         = 20;
		grid.expand         = true;
		
		/** Repeat Keys **/
		
		// create widgets
		var label_repeat       = new Gtk.Label (_("<b>Repeat Keys</b>"));
		var label_repeat_delay = new Gtk.Label (_("Delay in milliseconds:"));
		var label_repeat_speed = new Gtk.Label (_("Interval in milliseconds:"));
		var switch_repeat      = new Gtk.Switch ();
		var scale_repeat_delay = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 10, 1000, 1);
		var scale_repeat_speed = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 10, 100,  1);
		var spin_repeat_delay  = new Gtk.SpinButton.with_range (10, 1000, 1);
		var spin_repeat_speed  = new Gtk.SpinButton.with_range (10, 100,  1);
		
		// align labels vertically to CENTER and hoizontally to END
		label_repeat.use_markup   = true;
		label_repeat.halign       = Gtk.Align.END;
		label_repeat_delay.halign = Gtk.Align.END;
		label_repeat_speed.halign = Gtk.Align.END;
		label_repeat.valign       = Gtk.Align.CENTER;
		label_repeat_delay.valign = Gtk.Align.CENTER;
		label_repeat_speed.valign = Gtk.Align.CENTER;
		
		// tweak other widgets
		switch_repeat.halign          = Gtk.Align.START;
		scale_repeat_delay.hexpand    = true;
		scale_repeat_speed.hexpand    = true;
		scale_repeat_delay.draw_value = false;
		scale_repeat_speed.draw_value = false;

		// attach to grid
		grid.attach (label_repeat,       0, 0, 1, 1);
		grid.attach (label_repeat_delay, 0, 1, 1, 1);
		grid.attach (label_repeat_speed, 0, 2, 1, 1);
		grid.attach (switch_repeat,      1, 0, 1, 1);
		grid.attach (scale_repeat_delay, 1, 1, 1, 1);
		grid.attach (scale_repeat_speed, 1, 2, 1, 1);
		grid.attach (spin_repeat_delay,  2, 1, 1, 1);
		grid.attach (spin_repeat_speed,  2, 2, 1, 1);
		
		// set values from settigns
		var settings_repeat = new GLib.Settings ("org.gnome.settings-daemon.peripherals.keyboard");
		
		var double_delay = (double) settings_repeat.get_uint("delay");
		var double_speed = (double) settings_repeat.get_uint("repeat-interval");

		scale_repeat_delay.set_value (double_delay);
		scale_repeat_speed.set_value (double_speed);
		spin_repeat_delay.set_value  (double_delay);
		spin_repeat_speed.set_value  (double_speed);
		
		switch_repeat.active = settings_repeat.get_boolean("repeat");

		scale_repeat_delay.sensitive = switch_repeat.active;
		label_repeat_delay.sensitive = switch_repeat.active;
		spin_repeat_delay.sensitive  = switch_repeat.active;
		scale_repeat_speed.sensitive = switch_repeat.active;
		label_repeat_speed.sensitive = switch_repeat.active;
		spin_repeat_speed.sensitive  = switch_repeat.active;
		
		// connect signals
		scale_repeat_delay.value_changed.connect (() =>
		{
			var val = scale_repeat_delay.get_value();
			settings_repeat.set_uint ("delay", (uint) val );
			spin_repeat_delay.set_value (val);
		} );
		
		scale_repeat_speed.value_changed.connect (() =>
		{
			var val = scale_repeat_speed.get_value();
			settings_repeat.set_uint ("repeat-interval", 100 - (uint) val);
			spin_repeat_speed.set_value (val);
		} );
		
		spin_repeat_delay.value_changed.connect (() =>
		{
			var val = spin_repeat_delay.get_value();
			settings_repeat.set_uint ("delay", (uint) val );
			scale_repeat_delay.set_value (val);
		} );
		
		spin_repeat_speed.value_changed.connect (() =>
		{
			var val = spin_repeat_speed.get_value();
			settings_repeat.set_uint ("repeat-interval", 100 - (uint) val);
			scale_repeat_speed.set_value (val);
		} );
		
		switch_repeat.notify["active"].connect (() => 
		{
			var active = switch_repeat.active;

			scale_repeat_delay.sensitive = active;
			label_repeat_delay.sensitive = active;
			spin_repeat_delay.sensitive  = active;
			scale_repeat_speed.sensitive = active;
			label_repeat_speed.sensitive = active;
			spin_repeat_speed.sensitive  = active;
			
			settings_repeat.set_boolean ("repeat", active);
		} );
		
		/** Cursor Blinking **/
		
		// setup gui
		var label_blink       = new Gtk.Label (_("<b>Cursor Blinking</b>"));
		var label_blink_speed = new Gtk.Label (_("Interval in milliseconds:"));
		var label_blink_time  = new Gtk.Label (_("Timeout after seconds:"));
		var switch_blink      = new Gtk.Switch ();
		var scale_blink_speed = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 100, 2500, 10);
		var scale_blink_time  = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 1, 100, 1);
		var spin_blink_speed  = new Gtk.SpinButton.with_range (100, 2500, 10);
		var spin_blink_time   = new Gtk.SpinButton.with_range (1, 100, 1);
		
		// align labels vertically to CENTER and hoizontally to END
		label_blink.use_markup   = true;
		label_blink.halign       = Gtk.Align.END;
		label_blink_time.halign  = Gtk.Align.END;
		label_blink_speed.halign = Gtk.Align.END;
		label_blink.valign       = Gtk.Align.CENTER;
		label_blink_time.valign  = Gtk.Align.CENTER;
		label_blink_speed.valign = Gtk.Align.CENTER;
		
		// tweak other widgets
		switch_blink.halign          = Gtk.Align.START;
		switch_blink.active          = true;
		scale_blink_speed.hexpand    = true;
		scale_blink_time.hexpand     = true;
		scale_blink_speed.draw_value = false;
		scale_blink_time.draw_value  = false;
		
		// attach to grid
		grid.attach (label_blink,       0, 3, 1, 1);
		grid.attach (label_blink_speed, 0, 4, 1, 1);
		grid.attach (label_blink_time,  0, 5, 1, 1);
		grid.attach (switch_blink,      1, 3, 1, 1);
		grid.attach (scale_blink_speed, 1, 4, 1, 1);
		grid.attach (scale_blink_time,  1, 5, 1, 1);
		grid.attach (spin_blink_speed,  2, 4, 1, 1);
		grid.attach (spin_blink_time,   2, 5, 1, 1);
		
		// set values from settings
		var settings_blink = new GLib.Settings ("org.gnome.desktop.interface");
		
		var double_blink_speed = (double) settings_blink.get_int ("cursor-blink-time");
		var double_blink_time  = (double) settings_blink.get_int ("cursor-blink-timeout");
		
		scale_blink_speed.set_value (double_blink_speed);
		scale_blink_time.set_value  (double_blink_time);
		spin_blink_speed.set_value  (double_blink_speed);
		spin_blink_time.set_value   (double_blink_time);

		switch_blink.active = settings_blink.get_boolean("cursor-blink");

		scale_blink_speed.sensitive = switch_blink.active;
		label_blink_speed.sensitive = switch_blink.active;
		spin_blink_speed.sensitive  = switch_blink.active;
		scale_blink_time.sensitive  = switch_blink.active;
		label_blink_time.sensitive  = switch_blink.active;
		spin_blink_time.sensitive   = switch_blink.active;
		
		// connect signals
		scale_blink_speed.value_changed.connect (() =>
		{
			var val = scale_blink_speed.get_value ();
			settings_blink.set_int ("cursor-blink-time", (int) val);
			spin_blink_speed.set_value (val);
		} );
		
		scale_blink_time.value_changed.connect (() =>
		{
			var val = scale_blink_time.get_value ();
			settings_blink.set_int ("cursor-blink-timeout", (int) val);
			spin_blink_time.set_value (val);
		} );
		
		spin_blink_speed.value_changed.connect (() =>
		{
			var val = spin_blink_speed.get_value ();
			settings_blink.set_int ("cursor-blink-time", (int) val);
			scale_blink_speed.set_value (val);
		} );
		
		spin_blink_time.value_changed.connect (() =>
		{
			var val = spin_blink_time.get_value ();
			settings_blink.set_int ("cursor-blink-timeout", (int) val);
			scale_blink_time.set_value (val);
		} );
		
		switch_blink.notify["active"].connect (() => 
		{
			var active = switch_blink.active;
			
			scale_blink_speed.sensitive = active;
			label_blink_speed.sensitive = active;
			spin_blink_speed.sensitive  = active;
			scale_blink_time.sensitive  = active;
			label_blink_time.sensitive  = active;
			spin_blink_time.sensitive   = active;
			
			settings_blink.set_boolean ("cursor-blink", active);
		} );

		/** Test Settings **/
		
		var entry_test = new Granite.Widgets.HintedEntry (_("Type to test your settings..."));
		
		entry_test.hexpand = true;
		entry_test.set_icon_from_stock (Gtk.EntryIconPosition.SECONDARY, Gtk.Stock.CLEAR);
		
		entry_test.icon_press.connect ((pos, event) => 
		{
			if (pos == Gtk.EntryIconPosition.SECONDARY) 
			{
				entry_test.set_text ("");
			}
		});
		
		grid.attach (entry_test, 1, 6, 1, 1);
		
		return grid;
	}
}

int main (string[] args)
{
	Gtk.init (ref args);

	var plug = new KeyboardPlug ();
	plug.register ("Keyboard");
	plug.show_all();

	Gtk.main ();
	return 0;
}
