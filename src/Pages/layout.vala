namespace Keyboard.Layout
{
	// global handler
	LayoutHandler handler;
	
	class Page : AbstractPage
	{
		private Layout.Display display;
		private SettingsGroups settings;
		
		public override void reset ()
		{
			settings.reset_all ();
			display.reset_all ();
			return;
		}
		
		public Page (string title)
		{
			base (title);
			
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
			
			var button1 = new Gtk.RadioButton.with_label(null, _("the default layout"));
			var button2 = new Gtk.RadioButton.with_label_from_widget (button1, _("the previous window's layout"));
			
			this.attach (switch_main, 5, 0, 1, 1);
			this.attach (button1,     5, 1, 1, 1);
			this.attach (button2,     5, 2, 1, 1);
			
			settings = new Layout.SettingsGroups();
			
			// connect switch signals
			switch_main.active = settings.group_per_window;
			
			button1.sensitive = button2.sensitive = switch_main.active;
			label_2.sensitive = switch_main.active;
				
			switch_main.notify["active"].connect( () => {
				settings.group_per_window = switch_main.active;
				button1.sensitive = button2.sensitive = switch_main.active;
				label_2.sensitive = switch_main.active;
			} );
			
			settings.changed["group-per-window"].connect (() => {
				switch_main.active = settings.group_per_window;
				button1.sensitive = button2.sensitive = switch_main.active;
				label_2.sensitive = switch_main.active;
			} );
			
			// connect radio button signals
			if( settings.default_group >= 0 )
				button1.active = true;
			else
				button2.active = true;
				
			button1.toggled.connect (() => { settings.default_group =  0; } );
			button2.toggled.connect (() => { settings.default_group = -1; } );	
			
			settings.changed["default-group"].connect (() => 
			{
				if( settings.default_group >= 0 )
					button1.active = true;
				else
					button2.active = true;
			} );
			
			// tree view to display the current layouts
			display = new Layout.Display ();
		
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
