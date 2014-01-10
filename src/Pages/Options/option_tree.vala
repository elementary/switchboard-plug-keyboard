namespace Pantheon.Keyboard.Options
{
	class OptionTree : Gtk.TreeView
	{
		public uint option_group { get; construct; }
		
		public signal void changed (bool state, uint group, uint option);
		public signal void apply_changes ();
		
		Gtk.TreeModelForeachFunc _reset;
			
		public OptionTree (uint option_group)
		{
			Object (option_group: option_group);
			
			var store  = new Gtk.ListStore (2, typeof (bool), typeof (string));
			var toggle = new Gtk.CellRendererToggle ();
			var option_names = option_handler.get_options (option_group);
			
			_reset = ((model, path, iter) => {
				changed (false, option_group, (path.get_indices ())[0]);
				store.set (iter, 0, false);
				return false;
			});
		
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
		
		public void reset ()
		{
			var store = model as Gtk.ListStore;
			store.foreach (_reset);
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
			
			// if it's a radio button, it'll always be active
			var state = !toggle.active || toggle.radio;
			
			if (toggle.radio)
				reset ();
			
			Gtk.TreeIter iter;
			store.get_iter (out iter, tree_path);
			store.set (iter, 0, state);
			
			if (!(toggle.radio && int.parse (path) == 0))
				changed (state, option_group, int.parse (path));
			apply_changes ();
		}
	}
}