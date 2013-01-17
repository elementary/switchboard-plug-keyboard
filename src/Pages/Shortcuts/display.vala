namespace Keyboard.Shortcuts
{
	// creates a grid containing a tree view and an inline toolbar
	class Display : Gtk.Grid
	{
		int selected;
		
		Gtk.ScrolledWindow scroll;
		Tree[] trees;
		
		public Display (Tree[] t)
		{
			selected = 0;
			
			trees = t;
			
			scroll = new Gtk.ScrolledWindow(null, null);
			scroll.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			scroll.shadow_type = Gtk.ShadowType.IN;
			scroll.expand = true;
			scroll.add (trees[selected]);
	
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
		
			add_button.set_tooltip_text    (_("Add"));
			remove_button.set_tooltip_text (_("Remove"));
			
			add_button.set_icon_name    ("list-add-symbolic");
			remove_button.set_icon_name ("list-remove-symbolic");
		
			tbar.insert (add_button,    -1);
			tbar.insert (remove_button, -1);

			this.attach (scroll, 0, 0, 1, 1);
			//this.attach (tbar,   0, 1, 1, 1);
		}
		
		public bool change_selection (int new_selection)
		{
			scroll.remove (trees[selected]);
			scroll.add    (trees[new_selection]);
			
			selected = new_selection;
			scroll.show_all ();
			
			return true;
		}
	}
}
