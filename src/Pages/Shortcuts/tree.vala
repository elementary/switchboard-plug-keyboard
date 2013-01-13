namespace Keyboard.Shortcuts
{
	// contains the shortcuts and handels all changes in gsettings
	private class Tree : Gtk.TreeView
	{
		string[] actions;
		Schema[] schemas;
		string[] keys;
		
		public Tree (Groups group)
		{
			list.get_group (group, out actions, out schemas, out keys);
			
			// create list store
			var store = new Gtk.ListStore (4, typeof (string),
			                                  typeof (string), 
			                                  typeof (Schema),
			                                  typeof (string));

			Gtk.TreeIter iter;
			
			for (int i = 0; i < actions.length; i++)
			{
				var shortcut = settings.get_val(schemas[i], keys[i]);
			
				store.append (out iter);
				store.set (iter, 0, actions[i], 
				                 1, shortcut.to_readable(),
				                 2, schemas[i],    // hidden
				                 3, keys[i], -1);  // hidden
			}
			
			// create tree view
			var cell_desc = new Gtk.CellRendererText ();
			var cell_edit = new Gtk.CellRendererAccel ();
			
			cell_edit.editable   = true;
			cell_edit.accel_mode = Gtk.CellRendererAccelMode.OTHER;
			
			this.set_model (store);

			this.insert_column_with_attributes (-1, null, cell_desc, "text", 0);
			this.insert_column_with_attributes (-1, null, cell_edit, "text", 1);
			
			this.headers_visible = false;
			this.expand          = true;
			
			// signals
			cell_edit.accel_edited.connect ((path, key, mods) => 
			{
				var shortcut = new Shortcut (key, mods);
				change_shortcut (path, shortcut);
			} );
			
			cell_edit.accel_cleared.connect ((path) => 
			{
				change_shortcut (path, (Shortcut) null);
			} );
		}
		
		// change a shortcut in the list store and gsettings
		private bool change_shortcut (string path, Shortcut? shortcut)
		{
			Gtk.TreeIter  iter;
			GLib.Value    val, schema;
			
			if (shortcut != null && (list.conflicts (shortcut) || !shortcut.valid ()))
				return false;
			
			model.get_iter (out iter, new Gtk.TreePath.from_string (path));
				
			model.get_value (iter, 3, out val);
			model.get_value (iter, 2, out schema);

			if (shortcut == null)
			{
				(model as Gtk.ListStore).set (iter, 1, _("Disabled"));
				settings.set_val((Schema)schema, (string)val, new Shortcut(0, (Gdk.ModifierType)0));
				return true;
			}
			
			(model as Gtk.ListStore).set (iter, 1, shortcut.to_readable ());
				
			settings.set_val((Schema)schema, (string)val, shortcut);
			
			return true;
		}
	}
}
