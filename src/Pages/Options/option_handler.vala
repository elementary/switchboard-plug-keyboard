namespace Pantheon.Keyboard.Options
{
	// class that parses the layout file, provides lists of languages and
	// options, and converts between layout names and their gsettings codes	
	class OptionHandler : GLib.Object
	{
		Group[]  groups;
	
		private string[] names;
		private string[] codes;
		private bool[] multiple_selection;
		
		public int length {
			get {return names.length;}
		}
		
		public OptionHandler ()
		{
			foreach (var l in parse_groups ())
			{
				var parts = l.split(":", 3);
			
				if (parts[0] == null || parts[1] == null || parts[2] == null)
				{
					warning ("Line \"%s\" has wrong format. Will be ignored.", l);
					continue;
				}
			
				names += parts[0];
				codes += parts[1];
				
				var multi = bool.parse(parts[2]);
				multiple_selection += multi;
				
				groups += new Group (parse_options (l), multi);
			}
		}
		
		public string[] get_groups () {
			return names;
		}
		
		public string[] get_options (uint index) {
			return groups[index].names;
		}
		
		public bool get_multiple_selection (uint index) {
			return multiple_selection[index];
		}
		
		public string? get_code (uint l, uint v) {
			return codes[l] + "\t" + groups[l].codes[v];
		}
		
		public string get_name (uint l, uint v) {
			return groups[l].names[v];
		}
		
		public bool from_code (string code, out uint l, out uint v)
		{
			var parts = code.split("\t", 2);
			
			l = v = 0;
			
			if (parts[0] == null) return false;
			
			while (codes[l] != parts[0])
				if (++l > length)
					return false;
			
			if (parts[1] == null) return true;
			
			while (groups[l].codes[v] != parts[1])
				if (v++ > groups[l].codes.length)
					return false;
			
			return true;
		}

		// private class that contains the options of one language
		private class Group : GLib.Object
		{
			public string[] names;
			public string[] codes;

			public Group (string[] options, bool multi)
			{
				if (!multi) {
					names += _("None");
					codes += "";
				}
				
				foreach (var v in options) {
					var parts = v.split(":", 2);
					names += parts[0];
					codes += parts[1];
				}
			}
		}

		// private functions to parse the files
		private string[]? parse_groups ()
		{
			string[] return_val = null;
	
			var file = File.new_for_path (Build.PKGDATADIR + "/options.txt");

			if (!file.query_exists ()) {
				warning ("File '%s' doesn't exist.\n", file.get_path ());
				return return_val;
			}

			try {
				var dis = new DataInputStream (file.read ());
	
				string line;
	
				while ((line = dis.read_line (null)) != null)
					if( "#" in line )
						return_val += line.replace ("#", "");
						
			} catch (Error e) {
				error ("%s", e.message);
			}
	
			return return_val;
		}

		private string[]? parse_options (string language)
		{
			string[] return_val = null;
	
			var file = File.new_for_path (Build.PKGDATADIR + "/options.txt");

			if (!file.query_exists ()) {
				warning ("File '%s' doesn't exist.\n", file.get_path ());
				return null;
			}

			try {
				var dis = new DataInputStream (file.read ());
	
				string line;
	
				while ((line = dis.read_line (null)) != null) {
					if (line == "#"+language) {
						while ((line = dis.read_line (null)) != null) {
							if( "#" in line ) break;
							return_val += line;
						}
						break;
					}
				}
			} catch (Error e) {
				error ("%s", e.message);
			}

			return return_val;
		}
	}
}