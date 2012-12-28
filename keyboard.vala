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
		
		notebook.append_page (page_behaviour (), new Gtk.Label ("Behaviour"));
		notebook.append_page (page_shortcuts (), new Gtk.Label ("Shortcuts"));
		notebook.append_page (page_layout    (), new Gtk.Label ("Layout"));
		
		this.add( notebook );
	}
	
	private Gtk.Grid page_layout () 
	{
		// TODO
		return new Gtk.Grid (); 
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
		var label_repeat       = new Gtk.Label ("<b>Repeat Keys</b>");
		var label_repeat_delay = new Gtk.Label ("Delay in milliseconds:");
		var label_repeat_speed = new Gtk.Label ("Interval in milliseconds:");
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
		var label_blink       = new Gtk.Label ("<b>Cursor Blinking</b>");
		var label_blink_speed = new Gtk.Label ("Interval in milliseconds:");
		var label_blink_time  = new Gtk.Label ("Timeout after seconds:");
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
		scale_blink_time.sensitive = switch_blink.active;
		label_blink_time.sensitive = switch_blink.active;
		spin_blink_time.sensitive  = switch_blink.active;
		
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
		
		var label_test = new Gtk.Label ("<b>Test Settings</b>");
		
		label_test.use_markup = true;
		label_test.halign     = Gtk.Align.END;
		label_test.valign     = Gtk.Align.CENTER;
		
		var entry_test = new Gtk.Entry ();
		
		entry_test.hexpand = true;
		
		grid.attach (label_test, 0, 6, 1, 1);
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
