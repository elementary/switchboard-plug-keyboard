namespace Keyboard.Page
{
	// widget to display/add/remove/move keyboard layouts
	// interacts with class SettingsLayout
	class ListDisplay : Gtk.Grid
	{
		public ListDisplay ()
		{
			var settings = new SettingsLayouts ();
			var list = create_list_store (settings.layouts, true);
			var tree = new Gtk.TreeView.with_model (list);
			var cell = new Gtk.CellRendererText ();
		
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
			
			tbar.insert (add_button,    -1);
			tbar.insert (remove_button, -1);			
			tbar.insert (up_button,     -1);
			tbar.insert (down_button,   -1);
			
			this.attach (scroll, 0, 0, 1, 1);
			this.attach (tbar,   0, 1, 1, 1);	
			
			// add a new layout, also 3 nested lambdas should be avoided...
			var pop = new AddLayout ();

			add_button.clicked.connect( () =>
			{
				pop.move_to_widget (add_button);
					
				pop.layout_added.connect ((lang, layout) =>
				{
					Gtk.TreeIter iter;
					list.append (out iter);
					
					var item = lang;
					
					if(layout != null)
						item += " - " + layout;
					
					var add = true;
					
					Gtk.TreeModelForeachFunc print_row = (model, path, iter) => 
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
					
					list.foreach (print_row);
					
					if (add)
					{
						list.set (iter, 0, item);
						settings.add_layout (handler.code_from_name (lang, layout));
					}
				} );
			} );

			// remove the selected layouts
			remove_button.clicked.connect( () =>
			{
				var sel = tree.get_selection();
				weak Gtk.TreeModel model;
				List<Gtk.TreePath> paths = sel.get_selected_rows (out model);
				List<Gtk.TreeIter?> iters = null;
					
				foreach (Gtk.TreePath path in paths)
				{
					Gtk.TreeIter iter;
					if (model.get_iter(out iter, path))
					{
						iters.prepend(iter);
					}
				}

				foreach (Gtk.TreeIter iter in iters)
				{
					Value val;
					model.get_value (iter, 0, out val);
					
					var layout = ((string) val).split(" - ");
	
					settings.remove_layout (handler.code_from_name(layout[0], layout[1]));	

					(model as Gtk.ListStore).remove(iter);
				}
			} );
		}
	}
}
