namespace Keyboard.Behaviour
{
	class SettingsRepeat : Granite.Services.Settings
	{
		public uint delay            { get; set; }
		public uint repeat_interval  { get; set; }
		public bool repeat           { get; set; }
		
		public SettingsRepeat () { 
			base ("org.gnome.settings-daemon.peripherals.keyboard");
		}
	}
	
	class SettingsBlink : Granite.Services.Settings
	{
		public int  cursor_blink_time    { get; set; }
		public int  cursor_blink_timeout { get; set; }
		public bool cursor_blink         { get; set; }
		
		public SettingsBlink () { 
			base ("org.gnome.desktop.interface");
		}
	}
	
	class Page : Gtk.Grid
	{
		public Page ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.expand         = true;
		
			// create widgets
			var label_repeat       = new Gtk.Label (_("<b>Repeat Keys</b>"));
			var label_repeat_delay = new Gtk.Label (_("Delay:"));
			var label_repeat_speed = new Gtk.Label (_("Interval:"));
			var label_repeat_ms1   = new Gtk.Label (_("milliseconds"));
			var label_repeat_ms2   = new Gtk.Label (_("milliseconds"));
			var switch_repeat      = new Gtk.Switch ();
			var scale_repeat_delay = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 10, 1000, 1);
			var scale_repeat_speed = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 10, 100,  1);
			var spin_repeat_delay  = new Gtk.SpinButton.with_range (10, 1000, 1);
			var spin_repeat_speed  = new Gtk.SpinButton.with_range (10, 100,  1);
		
			// align labels vertically to CENTER and horizontally to END
			label_repeat.use_markup   = true;
			label_repeat.halign       = Gtk.Align.END;
			label_repeat_delay.halign = Gtk.Align.END;
			label_repeat_speed.halign = Gtk.Align.END;
			label_repeat_ms1.halign   = Gtk.Align.START;
			label_repeat_ms2.halign   = Gtk.Align.START;
		
			// tweak other widgets
			switch_repeat.halign          = Gtk.Align.START;
			scale_repeat_delay.hexpand    = true;
			scale_repeat_speed.hexpand    = true;
			scale_repeat_delay.draw_value = false;
			scale_repeat_speed.draw_value = false;

			// attach to this
			this.attach (label_repeat,       0, 0, 1, 1);
			this.attach (label_repeat_delay, 0, 1, 1, 1);
			this.attach (label_repeat_speed, 0, 2, 1, 1);
			this.attach (switch_repeat,      1, 0, 1, 1);
			this.attach (scale_repeat_delay, 1, 1, 1, 1);
			this.attach (scale_repeat_speed, 1, 2, 1, 1);
			this.attach (spin_repeat_delay,  2, 1, 1, 1);
			this.attach (spin_repeat_speed,  2, 2, 1, 1);
			this.attach (label_repeat_ms1,   3, 1, 1, 1);
			this.attach (label_repeat_ms2,   3, 2, 1, 1);
			
			// set values from settigns
			var settings_repeat = new Behaviour.SettingsRepeat ();
		
			var double_delay = (double) settings_repeat.delay;
			var double_speed = (double) settings_repeat.repeat_interval;

			scale_repeat_delay.set_value (double_delay);
			scale_repeat_speed.set_value (double_speed);
			spin_repeat_delay.set_value  (double_delay);
			spin_repeat_speed.set_value  (double_speed);
		
			switch_repeat.active = settings_repeat.repeat;

			scale_repeat_delay.sensitive = switch_repeat.active;
			label_repeat_delay.sensitive = switch_repeat.active;
			spin_repeat_delay.sensitive  = switch_repeat.active;
			scale_repeat_speed.sensitive = switch_repeat.active;
			label_repeat_speed.sensitive = switch_repeat.active;
			spin_repeat_speed.sensitive  = switch_repeat.active;
		
			// connect signals
			scale_repeat_delay.value_changed.connect (() => {
				settings_repeat.delay = (uint) (spin_repeat_delay.adjustment.value = scale_repeat_delay.adjustment.value);
			} );
		
			scale_repeat_speed.value_changed.connect (() => {
				settings_repeat.repeat_interval = (uint) (spin_repeat_speed.adjustment.value = scale_repeat_speed.adjustment.value);
			} );
		
			spin_repeat_delay.value_changed.connect (() => {
				settings_repeat.delay = (uint) (scale_repeat_delay.adjustment.value = spin_repeat_delay.adjustment.value);
			} );
		
			spin_repeat_speed.value_changed.connect (() => {
				settings_repeat.repeat_interval = (uint) (scale_repeat_speed.adjustment.value = spin_repeat_speed.adjustment.value);
			} );
			
			settings_repeat.changed["delay"].connect (() => {
				scale_repeat_delay.adjustment.value = spin_repeat_delay.adjustment.value = (double) settings_repeat.delay;
			} );
			
			settings_repeat.changed["repeat-interval"].connect (() => {
				scale_repeat_speed.adjustment.value = spin_repeat_speed.adjustment.value = (double) settings_repeat.repeat_interval;
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
				settings_repeat.repeat       = active;
			} );
			
			settings_repeat.changed["repeat"].connect (() => 
			{
				var active = settings_repeat.repeat;

				scale_repeat_delay.sensitive = active;
				label_repeat_delay.sensitive = active;
				spin_repeat_delay.sensitive  = active;
				scale_repeat_speed.sensitive = active;
				label_repeat_speed.sensitive = active;
				spin_repeat_speed.sensitive  = active;
				switch_repeat.active         = active;
			} );
			
			
		
			/** Cursor Blinking **/
		
			// setup gui
			var label_blink       = new Gtk.Label (_("<b>Cursor Blinking</b>"));
			var label_blink_speed = new Gtk.Label (_("Interval:"));
			var label_blink_time  = new Gtk.Label (_("Duration:"));
			var label_blink_ms    = new Gtk.Label (_("milliseconds"));
			var label_blink_s     = new Gtk.Label (_("seconds"));
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
			label_blink_ms.halign    = Gtk.Align.START;
			label_blink_s.halign     = Gtk.Align.START;
		
			// tweak other widgets
			switch_blink.halign          = Gtk.Align.START;
			switch_blink.active          = true;
			scale_blink_speed.hexpand    = true;
			scale_blink_time.hexpand     = true;
			scale_blink_speed.draw_value = false;
			scale_blink_time.draw_value  = false;
		
			// attach to this
			this.attach (label_blink,       0, 3, 1, 1);
			this.attach (label_blink_speed, 0, 4, 1, 1);
			this.attach (label_blink_time,  0, 5, 1, 1);
			this.attach (switch_blink,      1, 3, 1, 1);
			this.attach (scale_blink_speed, 1, 4, 1, 1);
			this.attach (scale_blink_time,  1, 5, 1, 1);
			this.attach (spin_blink_speed,  2, 4, 1, 1);
			this.attach (spin_blink_time,   2, 5, 1, 1);
			this.attach (label_blink_ms,    3, 4, 1, 1);
			this.attach (label_blink_s,     3, 5, 1, 1);
		
			// set values from settings
			var settings_blink = new Behaviour.SettingsBlink ();
		
			var double_blink_speed = (double) settings_blink.cursor_blink_time;
			var double_blink_time  = (double) settings_blink.cursor_blink_timeout;
		
			scale_blink_speed.set_value (double_blink_speed);
			scale_blink_time.set_value  (double_blink_time);
			spin_blink_speed.set_value  (double_blink_speed);
			spin_blink_time.set_value   (double_blink_time);

			switch_blink.active = settings_blink.cursor_blink;

			scale_blink_speed.sensitive = switch_blink.active;
			label_blink_speed.sensitive = switch_blink.active;
			spin_blink_speed.sensitive  = switch_blink.active;
			scale_blink_time.sensitive  = switch_blink.active;
			label_blink_time.sensitive  = switch_blink.active;
			spin_blink_time.sensitive   = switch_blink.active;
		
			// connect signals
			scale_blink_speed.value_changed.connect (() => {
				settings_blink.cursor_blink_time = (int) (spin_blink_speed.adjustment.value = scale_blink_speed.adjustment.value);
			} );

			scale_blink_time.value_changed.connect (() => {
				settings_blink.cursor_blink_timeout = (int) (spin_blink_time.adjustment.value = scale_blink_time.adjustment.value);
			} );
		
			spin_blink_speed.value_changed.connect (() => {
				settings_blink.cursor_blink_time = (int) (scale_blink_speed.adjustment.value = spin_blink_speed.adjustment.value);
			} );
		
			spin_blink_time.value_changed.connect (() => {
				settings_blink.cursor_blink_timeout = (int) (scale_blink_time.adjustment.value = spin_blink_time.adjustment.value);
			} );
			
			settings_blink.changed["cursor-blink-time"].connect (() => {
				scale_blink_speed.adjustment.value = spin_blink_speed.adjustment.value = (double) settings_blink.cursor_blink_time;
			} );
			
			settings_blink.changed["cursor-blink-timeout"].connect (() => {
				scale_blink_time.adjustment.value = spin_blink_time.adjustment.value = (double) settings_blink.cursor_blink_timeout;
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
				settings_blink.cursor_blink = active;
			} );
			
			settings_blink.changed["cursor-blink"].connect (() => 
			{
				var active = settings_blink.cursor_blink;

				scale_blink_speed.sensitive = active;
				label_blink_speed.sensitive = active;
				spin_blink_speed.sensitive  = active;
				scale_blink_time.sensitive  = active;
				label_blink_time.sensitive  = active;
				spin_blink_time.sensitive   = active;
				switch_blink.active         = active;
			} );

			/** Test Settings **/
		
			var entry_test = new Granite.Widgets.HintedEntry (_("Type to test your settings…"));
		
			entry_test.hexpand = true;
		
			entry_test.icon_press.connect ((pos, event) => 
			{
				if (pos == Gtk.EntryIconPosition.SECONDARY) 
				{
					entry_test.set_text ("");
				}
			});
			
			entry_test.changed.connect (() => {
				if (entry_test.text == "")
					entry_test.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "");
				else
					entry_test.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
			} );

			this.attach (entry_test, 1, 6, 1, 1);
		}
	}
}
