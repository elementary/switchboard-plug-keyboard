namespace Keyboard.Shortcuts
{
	class SectionSwitcher : Gtk.ScrolledWindow
	{
		public SectionSwitcher ()
		{
			var tree  = new Gtk.TreeView ();
			var store = new Gtk.ListStore (1, typeof(string));
			
			Gtk.TreeIter iter;
		
			
			for (int group = 0; group < SectionID.COUNT; group++)
			{
				store.append (out iter);
				store.set (iter, 0, section_names[group]);
			}
		
			var cell_desc = new Gtk.CellRendererText ();
	
			tree.set_model (store);
			tree.headers_visible = false;
			tree.insert_column_with_attributes (-1, null, cell_desc, "text", 0);
		
			this.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.shadow_type = Gtk.ShadowType.IN;
			this.add(tree);
			this.expand = true;
			
			tree.cursor_changed.connect (() => {
				Gtk.TreePath path;
				tree.get_cursor (out path, null);
				changed (path.get_indices ()[0]);
			} );
		}
		
		public signal void changed (int i);
	}
}
