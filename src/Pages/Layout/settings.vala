namespace Pantheon.Keyboard.LayoutPage
{

    /**
     * Type of a keyboard-layout as described in the description of
     * "org.gnome.desktop.input-sources sources".
     */
    enum LayoutType { IBUS, XKB }

    /**
     * Immutable class that respresents a keyboard-layout according to
     * "org.gnome.desktop.input-sources sources".
     * This means that the enum parameter @layout_type equals the first string in the
     * tupel of strings, and the @name parameter equals the second string.
     */
    class Layout {

        public LayoutType layout_type { get; private set; }
        public string name { get; private set; }

        public Layout (LayoutType layout_type, string name) {
            this.layout_type = layout_type;
            this.name = name;
        }

        public Layout.from_variant (GLib.Variant variant) {
            if (variant.is_of_type (new VariantType ("(ss)"))) {
			    unowned string type;
			    unowned string name;

			    variant.get ("(&s&s)", out type, out name);

			    if (type == "xkb") {
				    layout_type = LayoutType.XKB;
			    } else if (type == "ibus") {
				    layout_type = LayoutType.IBUS;
			    } else {
			        warning (@"Unkown type $type");
			    }
			    this.name = name;

		    } else {
                warning ("Variant has invalid type");
		    }
        }

        public bool equal (Layout other) {
            return this.layout_type == other.layout_type && this.name == other.name;
        }

        /**
         * GSettings saves values in the form of GLib.Variant and this
         * function creates a Variant representing this object.
         */
        public GLib.Variant to_variant () {
            string type_name = "";
            switch (layout_type) {
                case LayoutType.IBUS:
                    type_name = "ibus";
                    break;
                case LayoutType.XKB:
                    type_name = "xkb";
                    break;
                default:
                    error ("You need to implemnt this for all possible values of"
                           + "the LayoutType-enum");
            }
            GLib.Variant first = new GLib.Variant.string (type_name);
            GLib.Variant second = new GLib.Variant.string (name);
            GLib.Variant result = new GLib.Variant.tuple ({first, second});

            return result;
        }

    }

    /**
     * Represents a list of layouts.
     */
    class LayoutList : Object {

        GLib.List<Layout> layouts = new GLib.List<Layout> ();

        // signals
        public signal void layouts_changed ();
        public signal void active_changed ();

        public uint length {
            get {
                return layouts.length ();
            }
        }

        int _active;
        public int active {
            get {
                return _active;
            }
            set {
                active_changed ();
                _active = value;
            }

        }

        public bool contains_layout (Layout given_layout) {
            foreach (Layout l in layouts) {
                if (l.equal (given_layout))
                    return true;
            }
            return false;
        }

        public void move_layout_up (Layout given_layout) {
            if (contains_layout (given_layout)) {
                uint index = 0;
                for (uint i = 0; i < length; i++) {
                    if (get_layout (i).equal (given_layout)) {
                        index = i;
                        break;
                    }
                }
                if (index > 0) {
                    remove_layout (given_layout);
                    // We have to cast as GLib.List uses uint AND int for positions
                    layouts.insert (given_layout, (int) index--);
                }
                layouts_changed ();
            }
        }

        public void move_layout_down (Layout given_layout) {
            if (contains_layout (given_layout)) {
                uint index = 0;
                for (uint i = 0; i < length; i++) {
                    if (get_layout (i).equal (given_layout)) {
                        index = i;
                        break;
                    }
                }
                if (index < length - 1) {
                    remove_layout (given_layout);
                    // We have to cast as GLib.List uses uint AND int for positions
                    layouts.insert (given_layout, (int) index++);
                }
                layouts_changed ();
            }
        }

        public bool add_layout (Layout new_layout) {
            if (!contains_layout (new_layout)) {
                layouts.append (new_layout);
                layouts_changed ();
                return true;
            }
            return false;
        }

        public void remove_layout (Layout given_layout) {
            Layout? layout_in_list = null;

            foreach (Layout l in layouts) {
                if (l.equal (given_layout)) {
                    layout_in_list = l;
                    break;
                }
            }
            if (layout_in_list != null) {
                layouts.remove (layout_in_list);
                layouts_changed ();
            }
        }

        public void remove_all () {
            layouts = new GLib.List<Layout> ();
            layouts_changed ();
        }

        /**
         * This method does not need call layouts_changed in any situation
         * as a Layout-Object is immutable.
         */
        public Layout get_layout (uint index) {
            return layouts.nth_data (index);
        }

    }

	class LayoutSettings
	{

        public LayoutList layouts { get; private set; }

        GLib.Settings settings;

        /**
         * True if and only if we are currently writing to gsettings
         * by ourselves.
         */
        bool currently_writing;

		void write_list_to_gsettings () {
            currently_writing = true;
            try {
                Variant[] elements = {};
                for (uint i = 0; i < layouts.length; i++) {
                    elements += layouts.get_layout (i).to_variant ();
                    message ("blub");
                }
                GLib.Variant list = new GLib.Variant.array (new VariantType ("(ss)"), elements);
                settings.set_value ("sources", list);
            } finally {
                currently_writing = false;
            }
		}

		void update_list_from_gsettings () {
		    // We currently write to gsettings, so we caused this signal
		    // and therefore don't need to read the list again from dconf
		    if (currently_writing)
		        return;

            GLib.Variant sources = settings.get_value ("sources");
            if (sources.is_of_type (VariantType.ARRAY)) {
                for(size_t i = 0; i < sources.n_children (); i++) {
                    GLib.Variant child = sources.get_child_value (i);
                    layouts.add_layout (new Layout.from_variant (child));
                }
            } else {
                warning ("Unkown type");
            }
		}

		public void parse_default ()
		{
			var file = File.new_for_path ("/etc/default/keyboard");

			if (!file.query_exists ())
			{
				warning ("File '%s' doesn't exist.\n", file.get_path ());
				return;
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
				warning ("%s", e.message);
				return;
			}

			var variants = xkb_variant.split (",");
			var xkb_layouts  = xkb_layout.split (",");

			for (int i = 0; i < layouts.length; i++)
			{
				if (variants[i] != null && variants[i] != "")
					layouts.add_layout (new Layout (LayoutType.XKB, xkb_layouts[i] + "+" + variants[i]));
				else
					layouts.add_layout (new Layout (LayoutType.XKB, xkb_layouts[i]));
			}
		}

		public void reset_all ()
		{
		    layouts.remove_all ();
			parse_default ();
		}

		public signal void reverted ();

        // singleton pattern
        static LayoutSettings? instance;
        public static LayoutSettings get_instance () {
            if (instance == null) {
                instance = new LayoutSettings ();
            }
            return instance;
        }

		private LayoutSettings ()
		{
            settings = new Settings ("org.gnome.desktop.input-sources");
            layouts = new LayoutList ();

            update_list_from_gsettings ();

            layouts.layouts_changed.connect (() => {
                write_list_to_gsettings ();
            });

            settings.changed["sources"].connect (() => {
                update_list_from_gsettings ();
            });

            settings.changed["active"].connect (() => {
                update_list_from_gsettings ();
            });

			if (layouts.length == 0)
				parse_default ();

		}
	}

}