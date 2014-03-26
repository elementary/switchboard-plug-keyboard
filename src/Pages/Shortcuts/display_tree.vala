interface Pantheon.Keyboard.Shortcuts.DisplayTree : Gtk.TreeView {
    
    public abstract bool shortcut_conflicts (Shortcut shortcut, out string name);
    public abstract void reset_shortcut (Shortcut shortcut);
}
