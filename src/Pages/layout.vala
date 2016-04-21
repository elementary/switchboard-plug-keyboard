namespace Pantheon.Keyboard.LayoutPage
{
	// global handler
	LayoutHandler handler;

	class Page : Pantheon.Keyboard.AbstractPage
	{
		private LayoutPage.Display display;
		private LayoutSettings settings;

		public override void reset ()
		{
			settings.reset_all ();
			display.reset_all ();
			return;
		}

		public Page ()
		{
			handler  = new LayoutHandler ();
			settings = LayoutSettings.get_instance ();

			// first some labels
			var label_1   = new Gtk.Label (_("Allow different layouts for individual windows:"));

			label_1.valign = Gtk.Align.CENTER;
			label_1.halign = Gtk.Align.END;
			this.attach (label_1, 4, 0, 1, 1);

			// widgets to change settings
			var switch_main = new Gtk.Switch();
			switch_main.expand = false;
			switch_main.halign = Gtk.Align.START;
			switch_main.valign = Gtk.Align.CENTER;

			this.attach (switch_main, 5, 0, 1, 1);

            switch_main.active = settings.per_window;

			switch_main.notify["active"].connect(() => {
                settings.per_window = switch_main.active;
			});
            settings.per_window_changed.connect (() => {
                switch_main.active = settings.per_window;
            });


			// tree view to display the current layouts
			display = new LayoutPage.Display ();

			this.attach (display, 0, 0, 4, 4);

			// Test entry
			var entry_test = new Gtk.Entry ();
			entry_test.placeholder_text = (_("Type to test your layout…"));

			entry_test.hexpand = entry_test.vexpand = true;
			entry_test.valign  = Gtk.Align.END;

			this.attach (entry_test, 4, 3, 3, 1);
		}
	}
}
