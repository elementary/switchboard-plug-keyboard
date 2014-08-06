namespace Pantheon.Keyboard.LayoutPage
{
	// class that parses the layout file, provides lists of languages and
	// variants, and converts between layout names and their gsettings codes
	class LayoutHandler : GLib.Object
	{
		InternalLayout[]  layouts;

		private string[] names;
		private string[] codes;

		public LayoutHandler ()
		{
			foreach (var l in parse_layouts ())
			{
				var parts = l.split(":", 2);

				names += parts[0];
				codes += parts[1];

				layouts += new InternalLayout (parse_variants (l));
			}
		}

		public string[] get_layouts () {
			return names;
		}

		public string[] get_variants (uint index) {
			return layouts[index].names;
		}

		public string get_code (uint l, uint v)
		{
			if (v != 0)
				return codes[l] + "\t" + layouts[l].codes[v];
			return codes[l];
		}

		public string get_name (uint l, uint v)
		{
			if (v != 0)
				return layouts[l].names[v];
			return names[l];
		}

		public bool from_code (string code, out uint l, out uint v)
		{
			var parts = code.split("\t", 2);

			l = v = 0;

			if (parts[0] == null) return false;

			while (codes[l] != parts[0])
				if (l++ > codes.length)
					return false;

			if (parts[1] == null) return true;

			while (layouts[l].codes[v] != parts[1])
				if (v++ > layouts[l].codes.length)
					return false;

			return true;
		}

		// private class that contains the variants of one language
		private class InternalLayout : GLib.Object
		{
			public string[] names;
			public string[] codes;

			public InternalLayout( string[] variants )
			{
				names += _("Default");
				codes += "";

				foreach (var v in variants)
				{
					var parts = v.split(":", 2);

					names += parts[0];
					codes += parts[1];
				}
			}
		}

		// private functions to parse the files
		private string[]? parse_layouts ()
		{
			string[] return_val = null;

			var file = File.new_for_path (Build.PKGDATADIR + "/layouts.txt");

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

		private string[]? parse_variants (string language)
		{
			string[] return_val = null;

			var file = File.new_for_path (Build.PKGDATADIR + "/layouts.txt");

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