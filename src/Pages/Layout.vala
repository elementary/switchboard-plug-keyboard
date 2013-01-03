namespace Keyboard.Page
{
	// global handlers
	LayoutHandler handler;
	
	class Layout : Gtk.Grid
	{
		public Layout ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.column_homogeneous = false;
			this.row_homogeneous    = false;
			
			handler  = new LayoutHandler ();
			
			// first some labels
			var label_1   = new Gtk.Label (_("Allow different layouts for individual windows:"));
			var label_2   = new Gtk.Label (_("New windows use:"));
			
			label_1.valign = Gtk.Align.CENTER;
			label_1.halign = Gtk.Align.END;
			label_2.valign = Gtk.Align.CENTER;
			label_2.halign = Gtk.Align.END;
			
			this.attach (label_1, 1, 0, 1, 1);
			this.attach (label_2, 1, 1, 1, 1);
			
			// widgets to change settings
			var switch_main = new Gtk.Switch();
			switch_main.expand = false;
			switch_main.halign = Gtk.Align.START;
			switch_main.valign = Gtk.Align.CENTER;
			
			var button1 = new Gtk.RadioButton.with_label(null, _("the default layout"));
			var button2 = new Gtk.RadioButton.with_label_from_widget (button1, _("the previous window's layout"));
			
			this.attach (switch_main, 2, 0, 1, 1);
			this.attach (button1, 2, 1, 1, 1);
			this.attach (button2, 2, 2, 1, 1);
			
			var settings = new Page.SettingsGroups();
			
			switch_main.active = settings.group_per_window;
			
			switch_main.notify["active"].connect( () => {
				settings.group_per_window = switch_main.active;
				
				button1.sensitive = button2.sensitive = switch_main.active;
				label_2.sensitive = switch_main.active;
			} );
			
			if( settings.default_group >= 0 )
				button1.active = true;
			else
				button2.active = true;
				
			button1.toggled.connect (() => { settings.default_group =  0; } );
			button2.toggled.connect (() => { settings.default_group = -1; } );	
			
			// tree view to display the current layouts
			var display = new ListDisplay ();
			
			this.attach (display, 0, 0, 1, 4);
			
			// Test entry
			var entry_test = new Granite.Widgets.HintedEntry (_("Type to test your layout..."));
			
			entry_test.hexpand = entry_test.vexpand = true;
			entry_test.valign  = Gtk.Align.END;
			entry_test.set_icon_from_stock (Gtk.EntryIconPosition.SECONDARY, Gtk.Stock.CLEAR);
			
			entry_test.icon_press.connect ((pos, event) => 
			{
				if (pos == Gtk.EntryIconPosition.SECONDARY) 
				{
					entry_test.set_text ("");
				}
			});
			
			this.attach (entry_test, 1, 3, 3, 1);
		} 
	}
	
	// creates a list store from a string vector, optionally converts the layout code
	// to a readable name
	Gtk.ListStore create_list_store (string[] strv, bool convert = false)
	{
		Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iter;

		foreach (string str in strv)
		{
			string item;
			
			if(convert)
				item = handler.name_from_code (str);
			else
				item = str;

			list_store.append (out iter);
			list_store.set (iter, 0, item);	
		}
		
		return list_store;
	}
}
