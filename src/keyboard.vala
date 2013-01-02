// main class for keyboard plug

namespace Keyboard
{
	class KeyboardPlug : Pantheon.Switchboard.Plug
	{
		public KeyboardPlug ()
		{
			var notebook = new Granite.Widgets.StaticNotebook ();
		
			// every page is a seperate class in Keyboard.Page
			notebook.append_page (new Keyboard.Page.Behaviour (), new Gtk.Label (_("Behaviour")));
			notebook.append_page (new Keyboard.Page.Shortcuts (), new Gtk.Label (_("Shortcuts")));
			notebook.append_page (new Keyboard.Page.Layout    (), new Gtk.Label (_("Layout")));
		
			this.add( notebook );
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
