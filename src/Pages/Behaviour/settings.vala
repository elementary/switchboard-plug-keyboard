namespace Keyboard.Behaviour
{
	class SettingsRepeat : Granite.Services.Settings
	{
		public uint delay            { get; set; }
		public uint repeat_interval  { get; set; }
		public bool repeat           { get; set; }
		
		public void reset_all () {
			/*(this as GLib.Settings).reset ("delay");
			reset ("repeat-interval");
			reset ("repeat");*/
		}
		
		public SettingsRepeat () { 
			base ("org.gnome.settings-daemon.peripherals.keyboard");
		}
	}
	
	class SettingsBlink : Granite.Services.Settings
	{
		public int  cursor_blink_time    { get; set; }
		public int  cursor_blink_timeout { get; set; }
		public bool cursor_blink         { get; set; }
		
		public void reset_all () {/*
			(this as GLib.Settings).reset ("cursor-blink-time");
			(this as GLib.Settings).reset ("cursor-blink-timeout");
			(this as GLib.Settings).reset ("cursor-blink");*/
		}
		
		public SettingsBlink () { 
			base ("org.gnome.desktop.interface");
		}
	}
}
