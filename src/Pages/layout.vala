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

			// first some labels
			var label_1   = new Gtk.Label (_("Allow different layouts for individual windows:"));
			var label_2   = new Gtk.Label (_("New windows use:"));

			label_1.valign = Gtk.Align.CENTER;
			label_1.halign = Gtk.Align.END;
			label_2.valign = Gtk.Align.CENTER;
			label_2.halign = Gtk.Align.END;

			this.attach (label_1, 4, 0, 1, 1);
			this.attach (label_2, 4, 1, 1, 1);

			// widgets to change settings
			var switch_main = new Gtk.Switch();
			switch_main.expand = false;
			switch_main.halign = Gtk.Align.START;
			switch_main.valign = Gtk.Align.CENTER;

			var button1 = new Gtk.RadioButton.with_label(null, _("Default layout"));
			var button2 = new Gtk.RadioButton.with_label_from_widget (button1, _("Previous window's layout"));

			this.attach (switch_main, 5, 0, 1, 1);
			this.attach (button1,     5, 1, 1, 1);
			this.attach (button2,     5, 2, 1, 1);

			settings = LayoutSettings.get_instance ();

			button1.sensitive = button2.sensitive = switch_main.active;
			label_2.sensitive = switch_main.active;

			switch_main.notify["active"].connect( () => {
                //TODO
			} );
			// tree view to display the current layouts
			display = new LayoutPage.Display ();

			this.attach (display, 0, 0, 4, 4);

			// Test entry
			var entry_test = new Granite.Widgets.HintedEntry (_("Type to test your layout…"));

			entry_test.has_clear_icon = true;
			entry_test.hexpand = entry_test.vexpand = true;
			entry_test.valign  = Gtk.Align.END;

			this.attach (entry_test, 4, 3, 3, 1);
		}
	}

	// creates a list store from a string vector
	Gtk.ListStore create_list_store (string[] strv)
	{
		Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iter;

		foreach (string item in strv) {
			list_store.append (out iter);
			list_store.set (iter, 0, item);
		}

		return list_store;
	}
}