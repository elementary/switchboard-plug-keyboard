namespace Pantheon.Keyboard.Options
{
	// simple tree view containing a list of sections
	// changing the section changes the tree view
	// displayed on the right
	class SectionSwitcher : Gtk.ScrolledWindow
	{
		// section has been changed to i
		public signal void changed (int i);
		
		public SectionSwitcher ()
		{
			var tree  = new Gtk.TreeView ();
			var store = new Gtk.ListStore (1, typeof(string));
			
			Gtk.TreeIter iter;
			
			var section_names = option_handler.get_groups ();
			
			// add the sections
			foreach (var name in section_names) {
				store.append (out iter);
				store.set (iter, 0, name);
			}
		
			var cell_desc = new Gtk.CellRendererText ();
			
			tree.set_model (store);
			tree.headers_visible = false;
			tree.insert_column_with_attributes (-1, null, cell_desc, "text", 0);
			tree.set_cursor (new Gtk.TreePath.first (), null, false);

			this.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.shadow_type = Gtk.ShadowType.IN;
			this.add (tree);
			this.expand = true;
			
			// when cursor changes, emit signal "changed" with correct index
			tree.cursor_changed.connect (() => {
				Gtk.TreePath path;
				tree.get_cursor (out path, null);
				changed (path.get_indices ()[0]);
			});
		}
	}
}