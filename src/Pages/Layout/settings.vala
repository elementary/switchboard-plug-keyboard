namespace Keyboard.Layout
{
	// class to interact with gsettings and add/remove keyboard layouts
	class SettingsLayouts : Granite.Services.Settings
	{
		public string[] layouts { get; set; }
		
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
		
		public SettingsLayouts()
		{
			base ("org.gnome.libgnomekbd.keyboard");
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
