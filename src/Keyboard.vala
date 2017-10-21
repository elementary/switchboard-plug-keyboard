public class Pantheon.Keyboard.Plug : Switchboard.Plug {
    Gtk.Grid  grid;
    Gtk.Stack stack;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("input/keyboard", "Layout");
        settings.set ("input/keyboard/layout", "Layout");
        settings.set ("input/keyboard/behavior", "Behavior");
        settings.set ("input/keyboard/shortcuts", "Shortcuts");
        Object (category: Category.HARDWARE,
                code_name: "hardware-pantheon-keyboard",
                display_name: _("Keyboard"),
                description: _("Configure keyboard behavior, layouts, and shortcuts"),
                icon: "preferences-desktop-keyboard",
                supported_settings: settings);
    }

    public override Gtk.Widget get_widget () {
        if (grid == null) {
            stack = new Gtk.Stack ();
            stack.margin = 12;
            stack.add_titled (new Keyboard.LayoutPage.Page (), "layout", _("Layout"));
            stack.add_titled (new Keyboard.Shortcuts.Page (), "shortcuts", _("Shortcuts"));
            stack.add_titled (new Keyboard.Behaviour.Page (), "behavior", _("Behavior"));

            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.margin = 12;
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.homogeneous = true;
            stack_switcher.stack = stack;

            grid = new Gtk.Grid ();
            grid.attach (stack_switcher, 0, 0, 1, 1);
            grid.attach (stack, 0, 1, 1, 1);
        }
        grid.show_all ();
        return grid;
    }

    public override void shown () {

    }

    public override void hidden () {

    }

    public override void search_callback (string location) {
        switch (location) {
            default:
            case "Shortcuts":
                stack.visible_child_name = "shortcuts";
                break;
            case "Behavior":
                stack.visible_child_name = "behavior";
                break;
            case "Layout":
                stack.visible_child_name = "layout";
                break;
        }
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>)strcmp, (Gee.EqualDataFunc<string>)str_equal);
        search_results.set ("%s → %s".printf (display_name, _("Shortcuts")), "Shortcuts");
        search_results.set ("%s → %s".printf (display_name, _("Repeat Keys")), "Behavior");
        search_results.set ("%s → %s".printf (display_name, _("Cursor Blinking")), "Behavior");
        search_results.set ("%s → %s".printf (display_name, _("Switch layout")), "Layout");
        search_results.set ("%s → %s".printf (display_name, _("Compose Key")), "Layout");
        search_results.set ("%s → %s".printf (display_name, _("Caps Lock behavior")), "Layout");
        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Keyboard plug");
    var plug = new Pantheon.Keyboard.Plug ();
    return plug;
}
