namespace Keyboard.Shortcuts
{	
	// list of all shortcuts in gsettings, global object
	private List list;
	// class to interact with gsettings
	private Shortcuts.Settings settings;
	// array of tree views, one for each section
	private Tree[] trees;
	
	private enum SectionID { WINDOWS, WORKSPACES, SCREENSHOTS, APPS, MEDIA, A11Y, COUNT }
	
	private string[] section_names;
	
	// main class
	class Page : Gtk.Grid
	{	
		public Page ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.expand         = true;
		
			// init public elements
			section_names = {
				_("Windows"),
				_("Workspaces"),
				_("Screenshots"),
				_("Applications"),
				_("Media"),
				_("Accessibility")
			};
			
			list     = new List ();
			settings = new Shortcuts.Settings ();
			
			for (int id = 0; id < SectionID.COUNT; id++) {
				trees += new Tree ((SectionID) id);
			}
			
			// private elements
			var shortcut_display = new ShortcutDisplay (trees);
			var section_switcher = new SectionSwitcher ();
			
			this.attach (section_switcher, 0, 0, 1, 1);
			this.attach (shortcut_display, 1, 0, 3, 1);
		
			section_switcher.changed.connect ((i) => {
				shortcut_display.change_selection (i);
			} );
		}
	}
}
