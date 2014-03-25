namespace Pantheon.Keyboard.Shortcuts
{
	// contains the shortcuts and handels all changes in gsettings
	private class Tree : Gtk.TreeView
	{
		private string[] actions;
		private Schema[] schemas;
		private string[] keys;
		
		// quick access to one item in the tree view
		public bool get_item (uint i, out string action, out Schema schema, out string key)
		{
			action = null;
			schema = (Schema) null;
			key    = null;
			
			if (i < actions.length)
			{
				action = actions[i];
				schema = schemas[i];
				key    = keys[i];
				return true;
			}
			return false;
		}
		
		public Tree (SectionID group)
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
				
				// simply ignore missing keys/schemas
				if (shortcut == null)
					continue;

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
			// debug
			//this.insert_column_with_attributes (-1, null, cell_desc, "text", 2);
			//this.insert_column_with_attributes (-1, null, cell_edit, "text", 3);
			
			this.headers_visible = false;
			this.expand          = true;
			
			this.get_column (0).expand = true;
			
			this.button_press_event.connect ((event) =>
			{
				if (event.window != this.get_bin_window ())
					return false;
    
				Gtk.TreePath path;
				
				if (this.get_path_at_pos ((int) event.x,
                                          (int) event.y,
                                          out path, null,
                                          null, null))
				{
					Gtk.TreeViewColumn col = this.get_column (1);
					this.grab_focus ();
					this.set_cursor (path, col, true);
				}
				
				return true;
			} );
			
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
		public bool change_shortcut (string path, Shortcut? shortcut)
		{
			Gtk.TreeIter  iter;
			GLib.Value    key, schema, name;
			
			model.get_iter (out iter, new Gtk.TreePath.from_string (path));
			
			model.get_value (iter, 0, out name);
			model.get_value (iter, 2, out schema);
			model.get_value (iter, 3, out key);
			

			if (shortcut != null)
			{
				// new shortcut is old shortcut?
				if (shortcut.is_equal (settings.get_val ((Schema)schema, (string)key)))
					return true;
				
				string conflict_accel;
				int    conflict_group;
				int    conflict_path;
				
				string conflict_command, conflict_relocatable_schema;
				
				// check if shortcut is already used
				if (list.conflicts (shortcut, out conflict_accel, out conflict_group, out conflict_path))
				{
					string conflict_action;
					Schema conflict_schema;
					string conflict_key;
					
					// get some info about the conflicting item
					(trees[conflict_group] as Tree).get_item (conflict_path, out conflict_action, out conflict_schema, out conflict_key);
					
					var msg = new ConflictDialog (shortcut.to_readable (), conflict_action, (string) name);
					msg.reassign.connect (() => {
						(trees[conflict_group] as Tree).change_shortcut (conflict_path.to_string (), (Shortcut) null);
						change_shortcut (path, shortcut);
					});
					msg.show ();
					
					return false;
				} else if (CustomShortcutSettings.shortcut_conflicts (shortcut, out conflict_command, out conflict_relocatable_schema)) {
                    var msg = new ConflictDialog (shortcut.to_readable (), conflict_command, (string) name);
		            msg.reassign.connect (() => {
		                CustomShortcutSettings.edit_shortcut (conflict_relocatable_schema, (new Shortcut ()).to_readable ());
	                    (trees [SectionID.CUSTOM] as CustomTree).load_and_display_custom_shortcuts ();
	                    change_shortcut (path, shortcut);
		            });
		            msg.show ();
		            return false;
                }
                
				if (!shortcut.valid ())
					return false;
			}
			
			// unset/disable shortcut
			if (shortcut == null)
			{
				(model as Gtk.ListStore).set (iter, 1, _("Disabled"));
				settings.set_val((Schema)schema, (string)key, new Shortcut(0, (Gdk.ModifierType)0));
				return true;
			}
			
			(model as Gtk.ListStore).set (iter, 1, shortcut.to_readable ());
			settings.set_val((Schema)schema, (string)key, shortcut);
			return true;
		}
	}
}
