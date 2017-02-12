public class Pantheon.Keyboard.LayoutPage.LayoutHandler : GLib.Object {
    public HashTable<string, string> languages { public get; private set; }

    public LayoutHandler () {
        parse_layouts ();
    }

    construct {
        languages = new HashTable<string, string> (str_hash, str_equal);
    }

    private void parse_layouts () {
        var file = File.new_for_path ("/usr/share/X11/xkb/rules/evdev.lst");

        if (!file.query_exists ()) {
            critical ("File '%s' doesn't exist.", file.get_path ());
            return;
        }

        try {
            var dis = new DataInputStream (file.read ());
            string line;
            bool layout_found = false;
            while ((line = dis.read_line (null)) != null) {
                if (layout_found) {
                    if ("!" in line || line == "") {
                        break;
                    }
                    
                    var parts = line.chug ().split (" ", 2);
                    languages.set (parts[0], dgettext ("xkeyboard-config", parts[1].chug ()));
                } else {
                    if ("!" in line && "layout" in line) {
                        layout_found = true;
                    }
                }
            }
        } catch (Error e) {
            error (e.message);
        }
    }

    public HashTable<string, string> get_variants_for_language (string language) {
        var returned_table = new HashTable<string, string> (str_hash, str_equal);
        returned_table.set ("", _("Default"));
        var file = File.new_for_path ("/usr/share/X11/xkb/rules/evdev.lst");

        if (!file.query_exists ()) {
            critical ("File '%s' doesn't exist.", file.get_path ());
            return returned_table;
        }

        try {
            var dis = new DataInputStream (file.read ());
            string line;
            bool variant_found = false;
            while ((line = dis.read_line (null)) != null) {
                if (variant_found) {
                    if ("!" in line || line == "") {
                        break;
                    }
                    
                    var parts = line.chug ().split (" ", 2);
                    var subparts = parts[1].chug ().split (":", 2);
                    if (subparts[0] == language) {
                        returned_table.set (parts[0], dgettext ("xkeyboard-config", subparts[1].chug ()));
                    }
                } else {
                    if ("!" in line && "variant" in line) {
                        variant_found = true;
                    }
                }
            }
        } catch (Error e) {
            error (e.message);
        }

        return returned_table;
    }

    public string get_display_name (string variant) {
        if ("+" in variant) {
            var parts = variant.split ("+", 2);
            return get_variants_for_language (parts[0]).get (parts[1]);
        } else {
            return languages.get (variant);
        }
    }
}
