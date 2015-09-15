namespace Pantheon.Keyboard.Behaviour
{
	class SettingsRepeat : Granite.Services.Settings
	{
		public uint delay            { get; set; }
		public uint repeat_interval  { get; set; }
		public bool repeat           { get; set; }
		
		public void reset_all () {
			schema.reset ("delay");
			schema.reset ("repeat-interval");
			schema.reset ("repeat");
		}
		
		public SettingsRepeat () { 
			base ("org.gnome.desktop.peripherals.keyboard");
		}
	}
	
	class SettingsBlink : Granite.Services.Settings
	{
		public int  cursor_blink_time    { get; set; }
		public int  cursor_blink_timeout { get; set; }
		public bool cursor_blink         { get; set; }
		
		public void reset_all () {
			schema.reset ("cursor-blink-time");
			schema.reset ("cursor-blink-timeout");
			schema.reset ("cursor-blink");
		}
		
		public SettingsBlink () { 
			base ("org.gnome.desktop.interface");
		}
	}
}
