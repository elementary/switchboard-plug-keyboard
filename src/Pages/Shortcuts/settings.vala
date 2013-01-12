namespace Keyboard.Shortcuts
{
	// helper class for gsettings
	// note that media key are stored as strings, all others as string vectors
	class Settings : GLib.Object
	{
		public enum Schema { WM, MUTTER, GALA, MEDIA, COUNT }
		
		private GLib.Settings schemas[4];
		
		public Settings ()
		{
			schemas[Schema.WM]     = new GLib.Settings ("org.gnome.desktop.wm.keybindings");
			schemas[Schema.MUTTER] = new GLib.Settings ("org.gnome.mutter.keybindings");
			schemas[Schema.GALA]   = new GLib.Settings ("org.pantheon.desktop.gala.behavior");
			schemas[Schema.MEDIA]  = new GLib.Settings ("org.gnome.settings-daemon.plugins.media-keys");
		}
		
		// get/set methods for shortcuts in gsettings
		// require and return class Shortcut objects
		public Shortcut get_val (Schema schema, string key)
		{
			if (schema == Schema.MEDIA)
				return new Shortcut.parse (schemas[schema].get_string (key));
			else
				return new Shortcut.parse ((schemas[schema].get_strv (key)) [0]);
		}
		
		public bool set_val  (Schema schema, string key, Shortcut sc)
		{
			if (schema == Schema.MEDIA)
				schemas[schema].set_string (key, sc.to_gsettings ());
			else
				schemas[schema].set_strv (key, {sc.to_gsettings ()});
			return true;
		}
	}
}
