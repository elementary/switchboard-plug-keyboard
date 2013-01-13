namespace Keyboard.Layout
{
	// widget to display/add/remove/move keyboard layouts
	// interacts with class SettingsLayout
	class Display : Gtk.Grid
	{
		public Display ()
		{
			var settings = new SettingsLayouts ();
			var list = create_list_store (settings.layouts, true);
			var tree = new Gtk.TreeView.with_model (list);
			var cell = new Gtk.CellRendererText ();
		
			int count = settings.layouts.length - 1;
			
			tree.insert_column_with_attributes (-1, null, cell, "text", 0);
			tree.headers_visible = false;
			tree.expand = true;
			
			var scroll = new Gtk.ScrolledWindow(null, null);
			scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			scroll.shadow_type = Gtk.ShadowType.IN;
			scroll.add(tree);
			scroll.expand = true;
		
			var tbar = new Gtk.Toolbar();
			tbar.set_style(Gtk.ToolbarStyle.ICONS);
			tbar.set_icon_size(Gtk.IconSize.SMALL_TOOLBAR);
			tbar.set_show_arrow(false);
			tbar.hexpand = true;
			
			scroll.get_style_context().set_junction_sides(Gtk.JunctionSides.BOTTOM);
			tbar.get_style_context().add_class(Gtk.STYLE_CLASS_INLINE_TOOLBAR);
			tbar.get_style_context().set_junction_sides(Gtk.JunctionSides.TOP);

			var add_button    = new Gtk.ToolButton (null, _("Add"));
			var remove_button = new Gtk.ToolButton (null, _("Remove"));
			var up_button     = new Gtk.ToolButton (null, _("Move up"));
			var down_button   = new Gtk.ToolButton (null, _("Move down"));
			
			add_button.set_tooltip_text    (_("Add"));
			remove_button.set_tooltip_text (_("Remove"));
			up_button.set_tooltip_text     (_("Move up"));
			down_button.set_tooltip_text   (_("Move down"));
			
			add_button.set_icon_name    ("list-add-symbolic");
			remove_button.set_icon_name ("list-remove-symbolic");
			up_button.set_icon_name     ("go-up-symbolic");
			down_button.set_icon_name   ("go-down-symbolic");
			
			remove_button.sensitive = false;
			up_button.sensitive     = false;
			down_button.sensitive   = false;
			
			tbar.insert (add_button,    -1);
			tbar.insert (remove_button, -1);			
			tbar.insert (up_button,     -1);
			tbar.insert (down_button,   -1);
			
			this.attach (scroll, 0, 0, 1, 1);
			this.attach (tbar,   0, 1, 1, 1);	
			
			var pop = new AddLayout ();

			add_button.clicked.connect( () => {
				pop.move_to_widget (add_button);
				count++;
				add_item (settings, tree, pop);
			} );

			remove_button.clicked.connect( () => {
				count--;
				remove_item (settings, tree);
			} );
			
			up_button.clicked.connect (() => {
				move_item (settings, tree, 0);
			} );
			
			down_button.clicked.connect (() => {
				move_item (settings, tree, 1);
			} );
			
			tree.cursor_changed.connect (() =>
			{
				Gtk.TreePath path;
				
				tree.get_cursor (out path, null);
				
				if (path == null)
					return;
				
				int index = (path.get_indices ())[0];
				
				up_button.sensitive     = (index == 0)     ? false : true;
				down_button.sensitive   = (index == count) ? false : true;
				remove_button.sensitive = (count <= 0)     ? false : true;
			} );
			
			this.notify["count"].connect (() => {
				remove_button.sensitive = (count <= 0)     ? false : true;
			} );
		}
		
		void add_item (Layout.SettingsLayouts settings, Gtk.TreeView tree, Layout.AddLayout pop)
		{		
			pop.layout_added.connect ((lang, layout) =>
			{
				Gtk.TreeIter iter;
				
				var item = lang;
				
				if(layout != null)
					item += " - " + layout;
				
				var add = true;
				
				var list = tree.model as Gtk.ListStore;
				
				Gtk.TreeModelForeachFunc check = (model, path, iter) => 
				{
					Value cell1;
					list.get_value (iter, 0, out cell1);
					if ((string)cell1 == item)
					{
						add = false;
						return true;
					}
					return false;
				};
				
				list.foreach (check);
				
				if (add)
				{
					list.append (out iter);
					list.set (iter, 0, item);
					settings.add_layout (handler.code_from_name (lang, layout));
					tree.set_cursor (list.get_path(iter), null, false);
				} 
			} );
		}
		
		void remove_item (Layout.SettingsLayouts settings, Gtk.TreeView tree)
		{
			Gtk.TreeModel model;
			Gtk.TreeIter  iter;
			
			var select = tree.get_selection();
			select.get_selected (out model, out iter);
			
			GLib.Value val;
			model.get_value (iter, 0, out val);
				
			var layout = ((string) val).split(" - ");

			settings.remove_layout (handler.code_from_name(layout[0], layout[1]));	

			(model as Gtk.ListStore).remove(iter);
		}
		
		void move_item (Layout.SettingsLayouts settings, Gtk.TreeView tree, int dir)
		{
			Gtk.TreeModel model;
			Gtk.TreeIter  iter_current, iter_new;
			GLib.Value    val_current,  val_new;
			Gtk.TreePath  path_current;
			
			var select = tree.get_selection();
			select.get_selected (out model, out iter_current);
			path_current = model.get_path (iter_current);
			
			iter_new = iter_current;
			
			switch (dir) 
			{
				case 1: if (model.iter_next (ref iter_new) == false)
							return;
						break;
				case 0: if (model.iter_previous (ref iter_new) == false)
							return;
						break;
			}
			
			tree.set_cursor (model.get_path (iter_new), null, false);
			
			model.get_value (iter_current, 0, out val_current);
			model.get_value (iter_new,     0, out val_new);
			
			(model as Gtk.ListStore).set (iter_current, 0, (string)val_new);
			(model as Gtk.ListStore).set (iter_new,     0, (string)val_current);
			
			switch (dir) 
			{
				case 1: settings.layout_down ((path_current.get_indices()) [0]);
						break;
				case 0: settings.layout_up   ((path_current.get_indices()) [0]);
						break;
			}
		}
	}
}
