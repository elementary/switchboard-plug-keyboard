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
	class Page : AbstractPage
	{
		public override void reset ()
		{
			// TODO
			stdout.printf ("scs\n");
			return;
		}
		
		public Page ()
		{
			// init public elements
			section_names = {
				_("Windows"),
				_("Workspaces"),
				_("Screenshots"),
				_("Applications"),
				_("Media"),
				_("Universal Access")
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
			this.attach (shortcut_display, 1, 0, 2, 1);
		
			section_switcher.changed.connect ((i) => {
				shortcut_display.change_selection (i);
			} );
		}
	}
}
