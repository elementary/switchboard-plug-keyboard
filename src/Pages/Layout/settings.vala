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

        public Layout.XKB (string layout, string? variant) {
            string full_name = layout;
            if (variant != null && variant != "")
                full_name += "+" + variant;
            this (LayoutType.XKB, full_name);
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
                    warning ("Unkown type %s", type);
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

        uint _active;
        public uint active {
            get {
                return _active;
            }
            set {
                if (length == 0)
                    return;

                if (_active == value)
                    return;

                _active = value;
                if (_active >= length)
                    _active = length - 1;
                active_changed ();
            }

        }

        public bool contains_layout (Layout given_layout) {
            return get_layout_index (given_layout) != -1;
        }

        public int get_layout_index (Layout given_layout) {
            int i = 0;
            foreach (Layout l in layouts) {
                if (l.equal (given_layout))
                    return i;
                i++;
            }
            return -1;
        }

        private void switch_items (uint pos1, uint pos2) {
            unowned List<Layout> container1 = layouts.nth (pos1);
            unowned List<Layout> container2 = layouts.nth (pos2);
            Layout tmp = container1.data;
            container1.data = container2.data;
            container2.data = tmp;

            if (active == pos1)
                active = pos2;
            else if (active == pos2)
                active = pos1;

            layouts_changed ();
        }

        public void move_active_layout_up () {
            if (length == 0)
                return;

            // check that the active item is not the first one
            if (active > 0) {
                switch_items (active, active - 1);
            }
        }

        public void move_active_layout_down () {
            if (length == 0)
                return;

            // check that the active item is not the last one
            if (active < length - 1) {
                switch_items (active, active + 1);
            }
        }

        public bool add_layout (Layout new_layout) {
            if (! contains_layout (new_layout)) {
                layouts.append (new_layout);
                layouts_changed ();
                return true;
            }
            return false;
        }

        public void remove_active_layout () {
            layouts.remove (get_layout (active));

            if (active >= length)
                active = length - 1;
            layouts_changed ();
        }

        public void remove_all () {
            layouts = new GLib.List<Layout> ();
            layouts_changed ();
        }

        /**
         * This method does not need call layouts_changed in any situation
         * as a Layout-Object is immutable.
         */
        public Layout? get_layout (uint index) {
            if (index >= length)
                return null;

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
                }
                GLib.Variant list = new GLib.Variant.array (new VariantType ("(ss)"), elements);
                settings.set_value ("sources", list);
            } finally {
                currently_writing = false;
            }
        }

        void write_active_to_gsettings () {
            uint active = layouts.active;
            settings.set_uint ("current", active);
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

        void update_active_from_gsettings () {
            layouts.active = settings.get_uint ("current");
        }

        bool _per_window;
        public bool per_window {
            get {
                return _per_window;
            }
            set {
                if (value != _per_window) {
                    settings.set_boolean ("per-window", value);
                    _per_window = value;
                }
            }
        }
        // signal when the variable per_window is changed by gsettings
        public signal void per_window_changed ();

        // An array of all view switches that modify in any way xkb_options
        // the value of xkb_options is computed as an array of all active_command properties
        private Xkb_modifier [] xkb_options_modifiers;

        void update_modifiers_from_gsettings () {
            string [] xkb_options = settings.get_strv ("xkb-options");
            foreach ( Xkb_modifier modifier in xkb_options_modifiers ) {
                bool modifier_is_default = true;
                foreach ( string xkb_command in xkb_options ){
                    if ( xkb_command in modifier.xkb_option_commands ) {
                        modifier.set_active_command ( xkb_command );
                        modifier_is_default = false;
                        break;
                    } else {
                        continue;
                    }
                }
                if ( modifier_is_default ) {
                    modifier.set_active_command ( modifier.default_command );
                }
            }
        }

        void update_gsettings_from_modifiers () {
            string [] new_xkb_options = {};
            string [] old_xkb_options = settings.get_strv ("xkb-options");
            // adds all options that come from modifiers
            foreach ( Xkb_modifier modifier in xkb_options_modifiers ) {
                if ( "" != modifier.get_active_command () )
                    new_xkb_options += modifier.get_active_command ();
            }

            // adds all options that are on gsettings but can't be modified
            // through modifiers to allow compatibility options that cannot
            // be changed through the GUI.
            foreach ( string xkb_command in old_xkb_options ) {
                bool xkb_option_in_modifiers = false;
                foreach ( Xkb_modifier modifier in xkb_options_modifiers ) {
                    if ( xkb_command in modifier.xkb_option_commands ) {
                        xkb_option_in_modifiers = true;
                        break;
                    }
                }

                if ( xkb_option_in_modifiers == false ) {
                    new_xkb_options += xkb_command;
                }
            }
            // Writing to GSettiongs will send a signal telling it changed but we
            // don't want to trigger the update of all modifiers.
            currently_writing = true;
            settings.set_strv ("xkb-options", new_xkb_options);
            currently_writing = false;
        }

        public void parse_default () {
            var file = File.new_for_path ("/etc/default/keyboard");

            if (!file.query_exists ()) {
                warning ("File '%s' doesn't exist.\n", file.get_path ());
                return;
            }

            string xkb_layout  = "";
            string xkb_variant = "";

            try {
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
            catch (Error e) {
                warning ("%s", e.message);
                return;
            }

            var variants = xkb_variant.split (",");
            var xkb_layouts  = xkb_layout.split (",");

            for (int i = 0; i < layouts.length; i++) {
                if (variants[i] != null && variants[i] != "")
                    layouts.add_layout (new Layout (LayoutType.XKB, xkb_layouts[i] + "+" + variants[i]));
                else
                    layouts.add_layout (new Layout (LayoutType.XKB, xkb_layouts[i]));
            }
        }

        public void add_xkb_modifier (Xkb_modifier modifier) {
            xkb_options_modifiers += modifier;
            modifier.active_command_updated.connect (() => {
                update_gsettings_from_modifiers ();
            });
            update_modifiers_from_gsettings ();
        }

        public Xkb_modifier get_xkb_modifier_by_name (string name) {
            foreach (Xkb_modifier modifier in xkb_options_modifiers) {
                if ( modifier.name == name ) {
                    return modifier;
                }
            }

            return null;
        }

        public void reset_all () {
            layouts.remove_all ();
            parse_default ();
        }

        // singleton pattern
        static LayoutSettings? instance;
        public static LayoutSettings get_instance () {
            if (instance == null) {
                instance = new LayoutSettings ();
            }
            return instance;
        }

        private LayoutSettings () {
            settings = new Settings ("org.gnome.desktop.input-sources");
            layouts = new LayoutList ();

            _per_window = settings.get_boolean ("per-window");
            settings.changed["per-window"].connect (() => {
                _per_window = settings.get_boolean ("per-window");
                per_window_changed ();
            });

            update_list_from_gsettings ();
            update_active_from_gsettings ();
            update_modifiers_from_gsettings ();

            layouts.layouts_changed.connect (() => {
                write_list_to_gsettings ();
            });

            layouts.active_changed.connect (() => {
                write_active_to_gsettings ();
            });

            settings.changed["sources"].connect (() => {
                update_list_from_gsettings ();
            });

            settings.changed["current"].connect (() => {
                update_active_from_gsettings ();
            });

            settings.changed["xkb-options"].connect (() => {
                if (currently_writing) {
                    return;
                } else {
                    update_modifiers_from_gsettings ();
                }
            });

            if (layouts.length == 0)
                parse_default ();

        }
    }

}
