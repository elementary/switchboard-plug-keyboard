namespace Keyboard.Layout
{
	// class to interact with gsettings and add/remove keyboard layouts
	class SettingsLayouts : Granite.Services.Settings
	{
		public string[] layouts { get; set; }
		
		public void validate ()
		{
			string[] copy = {};
			foreach (string str in layouts)
			{
				if (handler.valid_code(str))
					copy += str;
			}
			layouts = copy;
		}
		
		public void add_layout (string layout)
		{
			foreach (string str in layouts)
			{
				if (str == layout)
					return;
			}
			string[] val = layouts;
			val += layout;
			layouts = val;
		}
		
		public void remove_layout (string layout)
		{
			string[] val = {};
			
			foreach (string str in layouts)
			{
				if (str != layout)
					val += str;
			}
			layouts = val;
		}
		
		public void layout_up (int i)
		{
			var l = layouts;
			var tmp = l[i];
			l[i] = l[i-1];
			l[i-1] = tmp;
			layouts = l;
		}
		
		public void layout_down (int i)
		{
			var l = layouts;
			var tmp = l[i];
			l[i] = l[i+1];
			l[i+1] = tmp;
			layouts = l;
		}
		
		public string[]? parse_default ()
		{
			string[] return_val = null;
	
			var file = File.new_for_path ("/etc/default/keyboard");

			if (!file.query_exists ())
			{
				warning ("File '%s' doesn't exist.\n", file.get_path ());
				return null;
			}

			string xkb_layout  = "";
			string xkb_variant = "";

			try
			{
				var dis = new DataInputStream (file.read ());
	
				string line;
	
				while ((line = dis.read_line (null)) != null)
				{
					if (line.contains ("XKBLAYOUT="))
					{
						xkb_layout = line.replace ("XKBLAYOUT=", "").replace ("\"", "");
						
						while ((line = dis.read_line (null)) != null) {
							if (line.contains ("XKBVARIANT=")) {
								xkb_variant = line.replace ("XKBVARIANT=", "").replace ("\"", "");
							}
						}
						
						break;
					}
				}
			}

			catch (Error e)
			{
				error ("%s", e.message);
			}
			
			var variants = xkb_variant.split (",");
			var layouts  = xkb_layout.split (",");
			
			for (int i = 0; i < layouts.length; i++)
			{
				if (variants[i] != null && variants[i] != "")
					return_val += layouts[i] + "\t" + variants[i];
				else
					return_val += layouts[i];
			}
			
			return return_val;
		}
		
		public SettingsLayouts()
		{
			base ("org.gnome.libgnomekbd.keyboard");
			
			if (layouts == null || layouts.length == 0)
				layouts = parse_default ();
			
			validate ();
		}
	}
	
	// allows for multiple kayboard layouts at a time
	class SettingsGroups : Granite.Services.Settings
	{
		public int  default_group    { get; set; }
		public bool group_per_window { get; set; }
		
		public SettingsGroups()
		{
			base ("org.gnome.libgnomekbd.desktop");
		}
	}
}
