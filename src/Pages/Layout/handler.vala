namespace Keyboard.Layout
{
	// class that parses the layout file, provides lists of languages and
	// variants, and converts between layout names and their gsettings codes
	class Handler : GLib.Object
	{
		Layout[]  _layouts;
	
		private string[] _language_names;
		private string[] _language_codes;
	
		public string[] language_names { get {return _language_names;} }
		public string[] language_codes { get {return _language_codes;} }
	
		public Handler ()
		{
			foreach (var l in parse_languages ())
			{
				var parts = l.split(":", 2);
			
				_language_names += parts[0];
				_language_codes += parts[1];
			
				_layouts += new Layout (parse_layouts (l));
			}
		}
	
		public bool valid_code (string settings_code)
		{
			string code, vcode;

			code  = settings_code.split("\t")[0];
			vcode = settings_code.split("\t")[1];
			
			if (code == null)
				return false;
			
			for (int i = 0; i < _language_codes.length; i++)
			{
				if (_language_codes[i] == code)
				{
					if (vcode == null)
						return true;
					if (_layouts[i].name_from_code (vcode) != null)
						return true;
				}
			}
			return false;
		}
		
		// returns gsettings code
		public string code_from_name (string name, string? vname = null, string sep = "\t")
		{
			string code, vcode;
		
			for (int i = 0; i < _language_names.length; i++)
			{
				if (_language_names[i] == name)
				{
					code  = _language_codes[i];
				
					if (vname != null)
					{
						vcode = _layouts[i].code_from_name (vname);
						
						if (vcode == (string) null || vcode == "")
						{
							return code;
						}

						return code + sep + vcode;
					}
				
					return code;
				}
			}
			return (string) null;
		}

		// returns a string with the name
		public bool name_from_code (string settings_code, out string name, out string vname)
		{
			string code, vcode;
			
			vname = name = "";
			
			code  = settings_code.split("\t")[0];
			vcode = settings_code.split("\t")[1];
			
			if (code==null)
				return false;
			if (vcode==null)
				vcode = "";
			
			for (int i = 0; i < _language_codes.length; i++)
			{
				if (_language_codes[i] == code)
				{
					name  = _language_names[i];
					vname = _layouts[i].name_from_code (vcode);
					return true;
				}
			}
			return false;
		}
	
		// returns a list of variants of a given language
		public string[] variants (string name)
		{
			for (int i = 0; i < _language_names.length; i++)
			{
				if (_language_names[i] == name)
					return _layouts[i].variant_names;
			}
			return (string[]) null;
		}

		// private class that contains the variants of one language
		private class Layout : GLib.Object
		{
			private string[] _variant_names;
			private string[] _variant_codes;
		
			public string[] variant_names { get {return _variant_names;} }
			public string[] variant_codes { get {return _variant_codes;} }
		
			public Layout( string[] variants )
			{
				_variant_names += _("Default");
				_variant_codes += "";
			
				foreach (var v in variants)
				{
					var parts = v.split(":", 2);
			
					_variant_names += parts[0];
					_variant_codes += parts[1];
				}
			}
	
			public string code_from_name (string name)
			{
				for (int i = 0; i < _variant_names.length; i++)
				{
					if (_variant_names[i] == name)
						return _variant_codes[i];
				}
				return (string) null;
			}
	
			public string name_from_code (string code)
			{
				for (int i = 0; i < _variant_codes.length; i++)
				{
					if (_variant_codes[i] == code)
						return _variant_names[i];
				}
				return (string) null;
			}
		}

		// private functions to parse the files
		private string[]? parse_languages ()
		{
			string[] return_val = null;
	
			var file = File.new_for_path ("layouts.txt");

			if (!file.query_exists ())
			{
				stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
				return return_val;
			}

			try 
			{
				var dis = new DataInputStream (file.read ());
	
				string line;
	
				while ((line = dis.read_line (null)) != null)
				{
					if( "#" in line )
					{
						return_val += line.replace ("#", "");
					}
				}
			}

			catch (Error e)
			{
				error ("%s", e.message);
			}
	
			return return_val;
		}

		private string[]? parse_layouts (string language)
		{
			string[] return_val = null;
	
			var file = File.new_for_path ("layouts.txt");

			if (!file.query_exists ())
			{
				warning ("File '%s' doesn't exist.\n", file.get_path ());
				return null;
			}

			try
			{
				var dis = new DataInputStream (file.read ());
	
				string line;
	
				while ((line = dis.read_line (null)) != null)
				{
					if (line == "#"+language)
					{
						while ((line = dis.read_line (null)) != null)
						{
							if( "#" in line ) { break; }
				
							return_val += line;
						}
						break;
					}
				}
			}

			catch (Error e)
			{
				error ("%s", e.message);
			}

			return return_val;
		}
	}
}
