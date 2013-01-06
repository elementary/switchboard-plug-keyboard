namespace Keyboard.Shortcuts
{
	private class Tree : Gtk.TreeView
	{
		public Tree ( string[] actions, Shortcuts.Settings.Schema[] schemas, string[] keys )
		{
			var store = new Gtk.ListStore (4, typeof (string),
			                                  typeof (string), 
			                                  typeof (Shortcuts.Settings.Schema), //hidden
			                                  typeof (string));                   //hidde
			Gtk.TreeIter iter;

			var settings = new Shortcuts.Settings ();

			// create list store
			for (int i = 0; i < actions.length; i++)
			{
				var shortcut = settings.get_val(schemas[i], keys[i]);
			
				store.append (out iter);
				store.set (iter, 0, actions[i], 
				                 1, shortcut,
				                 2, schemas[i],    // hidden
				                 3, keys[i], -1);  // hidden
			}
			
			var cell_desc = new Gtk.CellRendererText ();
			var cell_edit = new Gtk.CellRendererText ();
			cell_edit.editable = true;
			
			this.set_model (store);

			this.insert_column_with_attributes (-1, null, cell_desc, "text", 0);
			this.insert_column_with_attributes (-1, null, cell_edit, "text", 1);
			
			this.headers_visible = false;
			this.expand = true;
			
			cell_edit.edited.connect ((path, text) =>
			{
				Gtk.TreeIter iter2;
				GLib.Value schema, key;
				
				store.get_iter (out iter2, new Gtk.TreePath.from_string (path));
				store.get_value (iter2, 2, out schema);
				store.get_value (iter2, 3, out key);
				store.set (iter2, 1, text);
				
				settings.set_val((Shortcuts.Settings.Schema)schema, (string)key, text);
			} );
		}
	}
}
