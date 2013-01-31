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
			
			AbstractPage[] pages = {
				(AbstractPage) new Keyboard.Shortcuts.Page (_("Shortcuts")),
				(AbstractPage) new Keyboard.Behaviour.Page (_("Behaviour")),
				(AbstractPage) new Keyboard.Layout.Page    (_("Layout"))
			};
			
			// every page is a seperate class
			foreach (var page in pages) {
				notebook.append_page (page, new Gtk.Label (page.title));
			}

			var button = new Gtk.Button.with_label (_("Reset to defaults"));
			
			button.expand = false;
			button.halign = Gtk.Align.END;
			
			button.clicked.connect (() => {
				pages[notebook.page].reset ();
			});
			
			grid.attach (notebook, 0, 0, 1, 1);
			//grid.attach (button,   0, 1, 1, 1);

			this.add (grid);
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
