namespace Keyboard.Options
{
	class OptionTree : Gtk.TreeView
	{
		public uint option_group { get; construct; }
		
		public OptionTree (uint option_group)
		{
			Object (option_group: option_group);
			var store  = new Gtk.ListStore (2, typeof (bool), typeof (string));
			var toggle = new Gtk.CellRendererToggle ();
			var option_names = option_handler.get_options (option_group);
			
			Gtk.TreeIter iter;
			model = store;			
			
			toggle.toggled.connect (on_toggle);
			toggle.radio = ! option_handler.get_multiple_selection (option_group);

			// add the sections
			foreach (var name in option_names) {
				store.append (out iter);
				store.set (iter, 0, false, 1, name);
			}
			
			this.headers_visible = false;
			
			var column = new Gtk.TreeViewColumn ();
			column.pack_start (toggle, false);
			column.add_attribute (toggle, "active", 0);
			this.append_column (column);
			
			var text = new Gtk.CellRendererText ();
		    column = new Gtk.TreeViewColumn ();
		    column.pack_start (text, true);
		    column.add_attribute (text, "text", 1);
		    this.append_column (column);
		}
		
		public void set_option (uint option, bool status)
		{
			var store = model as Gtk.ListStore;
			
			Gtk.TreeIter iter;
			store.get_iter (out iter, new Gtk.TreePath.from_indices (option));
			store.set (iter, 0, status);
		}
		
		private void on_toggle (Gtk.CellRendererToggle toggle, string path)
		{
			var tree_path = new Gtk.TreePath.from_string (path);
			var store = model as Gtk.ListStore;
			
			// if it's a radio button, it'll always be true
			var on = !toggle.active || toggle.radio;
			
			Gtk.TreeIter iter;
			store.get_iter (out iter, tree_path);
			store.set (iter, 0, on);
			
			if (toggle.radio)
			{
				Gtk.TreeModelForeachFunc reset = ((model, path, iter) => {
					option_settings.remove (option_group, (path.get_indices ())[0]);
					store.set (iter, 0, false);
					return false;
				});
				
				store.foreach (reset);
				store.set (iter, 0, true);
				
				if (int.parse (path) > 0)
					option_settings.add (option_group, int.parse (path));
				
				option_settings.apply ();
				return;
			}
			
			if (on)
				option_settings.add (option_group, int.parse (path));
			else
				option_settings.remove (option_group, int.parse (path));
				
			option_settings.apply ();
		}
	}
}
