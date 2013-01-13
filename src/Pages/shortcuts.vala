namespace Keyboard.Shortcuts
{	
	// list of all shortcuts in gsettings, global object
	private List list;
	
	private Shortcuts.Settings settings;
	
	// main class
	class Page : Gtk.Grid
	{
		public Page ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.expand         = true;
		
			list     = new List ();
			settings = new Shortcuts.Settings ();
		
			var notebook = new Granite.Widgets.StaticNotebook ();
			
			notebook.append_page (new Display (new Tree (Groups.WINDOWS)),     new Gtk.Label (_("Windows")));
			notebook.append_page (new Display (new Tree (Groups.WORKSPACES)),  new Gtk.Label (_("Workspaces")));
			notebook.append_page (new Display (new Tree (Groups.SCREENSHOTS)), new Gtk.Label (_("Screenshots")));
			notebook.append_page (new Display (new Tree (Groups.MEDIA)),       new Gtk.Label (_("Media")));
			notebook.append_page (new Display (new Tree (Groups.LAUNCHERS)),   new Gtk.Label (_("Launchers")));
			notebook.append_page (new Display (new Tree (Groups.A11Y)),        new Gtk.Label (_("Accessibility")));
 
			this.attach (notebook, 0, 0, 1, 1);
		}
	}
}
