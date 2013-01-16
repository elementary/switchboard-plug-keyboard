// main class for keyboard plug

namespace Keyboard
{
	class KeyboardPlug : Pantheon.Switchboard.Plug
	{
		public KeyboardPlug ()
		{
			var notebook = new Granite.Widgets.StaticNotebook (false);
		
			// every page is a seperate class
			notebook.append_page (new Keyboard.Behaviour.Page (), new Gtk.Label (_("Behaviour")));
			notebook.append_page (new Keyboard.Shortcuts.Page (), new Gtk.Label (_("Shortcuts")));
			notebook.append_page (new Keyboard.Layout.Page    (), new Gtk.Label (_("Layout")));

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
