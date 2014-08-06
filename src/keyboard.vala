public class Pantheon.Keyboard.Plug : Switchboard.Plug {
    Gtk.Grid grid;

    public Plug () {
        Object (category: Category.HARDWARE,
                code_name: "hardware-pantheon-keyboard",
                display_name: _("Keyboard"),
                description: _("Configure your keyboard"),
                icon: "preferences-desktop-keyboard");
    }

    public override Gtk.Widget get_widget () {
        if (grid == null) {
            grid = new Gtk.Grid ();
            grid.margin = 12;
            var stack = new Gtk.Stack ();
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.halign = Gtk.Align.CENTER;
            
            stack.add_titled (new Keyboard.Shortcuts.Page (), "shortcuts", _("Shortcuts"));
            stack.add_titled (new Keyboard.Behaviour.Page (), "behavior", _("Behavior"));
            stack.add_titled (new Keyboard.Layout.Page (), "layout", _("Layout"));
            stack.add_titled (new Keyboard.Options.Page (), "options", _("Options"));

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
    
    }
    
    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Keyboard plug");
    var plug = new Pantheon.Keyboard.Plug ();
    return plug;
}