// main class for keyboard plug

namespace Keyboard
{
	class KeyboardPlug : Pantheon.Switchboard.Plug
	{
		public KeyboardPlug ()
		{
			var grid = new Gtk.Grid ();
			
			grid.margin = 12;
			
			var notebook = new Granite.Widgets.StaticNotebook (false);
			
			AbstractPage[] pages =
			{
				(AbstractPage) new Keyboard.Shortcuts.Page (),
				(AbstractPage) new Keyboard.Behaviour.Page (),
				(AbstractPage) new Keyboard.Layout.Page    ()
			};
			
			// every page is a seperate class
			notebook.append_page (pages[0], new Gtk.Label (_("Shortcuts")));
			notebook.append_page (pages[1], new Gtk.Label (_("Behaviour")));
			notebook.append_page (pages[2], new Gtk.Label (_("Layout")));

			var button = new Gtk.Button.with_label (_("Reset to Default"));
			
			button.expand = false;
			button.halign = Gtk.Align.END;
			
			button.clicked.connect (() => {
				pages[notebook.page].reset ();
			} );
			
			grid.attach (notebook, 0, 0, 1, 1);
			//grid.attach (button,   0, 1, 1, 1);

			this.add( grid );
		}
	}
}

static int main (string[] args)
{
	Gtk.init (ref args);

	var plug = new Keyboard.KeyboardPlug ();
	plug.register ("Keyboard");
	plug.show_all();

	Gtk.main ();
	return 0;
}
