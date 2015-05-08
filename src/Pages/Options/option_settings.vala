namespace Pantheon.Keyboard.Options
{
	class OptionSettings : GLib.Object
	{
		public uint[] groups;
		public uint[] options;
		
		public uint length { 
			get { return groups.length; } 
		}
		
		private GLib.Settings settings;
		
		public OptionSettings()
		{
			var schema_name   = "org.gnome.desktop.input-sources";
			var schema_source = GLib.SettingsSchemaSource.get_default ();
				
			// check if schema exists
			var schema = schema_source.lookup (schema_name, true);
				
			if (schema == null) {
				warning ("Schema \"%s\" is not installed on you system.", schema_name);
				settings = null;
			} else {
				settings = new GLib.Settings.full (schema, null, null);
				parse ();
				apply ();
			}
			
			settings.changed["xkb-options"].connect (() => {
				uint[] old_groups  = groups;
				uint[] old_options = options;
				
				parse ();
				
				if (old_groups.length  != groups.length || old_options.length != old_options.length) {
					external_change ();
					return;
				}
				
				for (int i = 0; i < length; i++) {
					if (old_groups[i] != groups[i] || old_options[i] != options[i])
						external_change ();
				}
			});
		}
		
		// emittedwhen the options are changed from an external program
		public signal void external_change ();
		
		// parse the "xkb-options" key and store the values in options[] and groups[]
		public bool parse ()
		{
			groups  = {};
			options = {};
			
			uint group, option;
			
			foreach (var code in settings.get_strv ("xkb-options"))
			{
				var add = true;
				
				if(!option_handler.from_code (code, out group, out option)) {
					warning ("The option \"%s\" in \"%s.options\" is invalid and will be removed.", code, settings.schema);
					add = false;
				}
				
				for (int i = 0; i < groups.length; i++) {
					if (group == groups[i] && option == options[i]) {
						warning ("Duplicate of \"%s\" in \"%s.options\" will be removed.", code, settings.schema);
						add = false;
					}
				}
				
				if (add) {
					groups  += group;
					options += option;
				}
			}
			
			return true;
		}
		
		public void reset ()
		{
			groups  = {};
			options = {};
			settings.set_strv ("xkb-options", null);
		}
		
		
		
		// apply settings to gsettings
		public void apply ()
		{
			string[] tmp = {};
			
			for (int i = 0; i < groups.length; i++)
				tmp += option_handler.get_code (groups[i], options[i]);
			
			settings.set_strv ("xkb-options", tmp);
		}
		
		public void add (uint group, uint option) {
			groups  += group;
			options += option;
		}
		
		public void remove (uint group, uint option)
		{
			uint[] groups_new  = {};
			uint[] options_new = {};
			 
			for (int i = 0; i < groups.length; i++) {
				if (group != groups[i] || option != options[i]) {
					groups_new  += groups[i];
					options_new += options[i];
				}
			}
			
			groups = groups_new;
			options = options_new;
		}
	}
}