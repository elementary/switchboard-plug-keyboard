namespace Keyboard.Shortcuts
{
	private class Tree : Gtk.TreeView
	{
		public Tree ( string[] actions, Shortcuts.Settings.Schema[] schemas, string[] keys )
		{
			var store = new Gtk.ListStore (4, typeof (string),
			                                  typeof (string), 
			                                  typeof (Shortcuts.Settings.Schema),
			                                  typeof (string));
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

			this.set_model (store);

			this.insert_column_with_attributes (-1, null, cell_desc, "text", 0);
			this.insert_column_with_attributes (-1, null, cell_edit, "text", 1);
			
			this.headers_visible = false;
			this.expand = true;

			this.key_press_event.connect ((event) =>
			{
				Gtk.TreeModel model;
				Gtk.TreeIter  iter1;
			
				var select = this.get_selection ();
				select.get_selected (out model, out iter1);
			
				GLib.Value val, schema, key;
				model.get_value (iter1, 0, out val);
				store.get_value (iter1, 2, out schema);
				store.get_value (iter1, 3, out key);
				
				string str = "";

				if ( 0 != event.is_modifier) return true;
				
				if ((event.state & Gdk.ModifierType.MOD1_MASK)    > 0) str += "<Alt>";
				if ((event.state & Gdk.ModifierType.CONTROL_MASK) > 0) str += "<Ctrl>";
				if ((event.state & Gdk.ModifierType.SHIFT_MASK)   > 0) str += "<Shift>";
				if ((event.state & Gdk.ModifierType.MOD5_MASK)    > 0) str += "<Meta>";	
				if ((event.state & (Gdk.ModifierType) 201326656)  > 0) str += "<Super>";
				
				var km = Gdk.Keymap.get_default ();
				
				var kmk = Gdk.KeymapKey() {
					keycode = (uint)(event.hardware_keycode), 
					group   = 0,
					level   = 0
				};
				
				str += Gdk.keyval_name (km.lookup_key(kmk)).up ();
				
				if (event.keyval == Gdk.Key.BackSpace)
					str = "";
					
				store.set (iter1, 1, from_dconf (str));
				
				settings.set_val((Shortcuts.Settings.Schema)schema, (string)key, str);
				
				return true;
			} );
		}
	}
}
