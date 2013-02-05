namespace Keyboard.Options
{
	class OptionSettings : Granite.Services.Settings
	{
		public string[] options { get; set; }
		
		public uint[] u_groups;
		public uint[] u_options;
		
		public OptionSettings()
		{
			base ("org.gnome.libgnomekbd.keyboard");
			
			uint group, option;
			
			foreach (var code in options)
				stdout.printf ("%s\n", code);
				
			foreach (var code in options)
			{
				var add = true;
				
				if(!option_handler.from_code (code, out group, out option)) {
					warning ("The option \"%s\" in \"%s.options\" is invalid and will be removed.", code, schema.schema);
					add = false;
				}
				
				for (int i = 0; i < u_groups.length; i++) {
					if (group == u_groups[i] && option == u_options[i]) {
						warning ("Duplicate of \"%s\" in \"%s.options\" will be removed.", code, schema.schema);
						add = false;
					}
				}
				
				if (add) {
					u_groups  += group;
					u_options += option;
				}
			}
			
			apply ();
		}
		
		public void apply ()
		{
			string [] tmp = {};
			
			for (int i = 0; i < u_groups.length; i++)
				tmp += option_handler.get_code (u_groups[i], u_options[i]);
			
			options = tmp;
		}
		
		public void add (uint group, uint option) {
			u_groups  += group;
			u_options += option;
			//apply ();
		}
		
		public void remove (uint group, uint option)
		{
			uint[] u_groups_new  = {};
			uint[] u_options_new = {};
			 
			for (int i = 0; i < u_groups.length; i++) {
				if (group != u_groups[i] || option != u_options[i]) {
					u_groups_new  += u_groups[i];
					u_options_new += u_options[i];
				}
			}
			
			u_groups = u_groups_new;
			u_options = u_options_new;
			//apply ();
		}
	}
}
