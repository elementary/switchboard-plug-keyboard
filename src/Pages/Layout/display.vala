namespace Pantheon.Keyboard.Layout
{
	// widget to display/add/remove/move keyboard layouts
	// interacts with class SettingsLayout
	class Display : Gtk.Grid
	{
		private signal void update_buttons ();

		private SettingsLayouts settings;
		private Gtk.TreeView tree;

		public Display ()
		{
			settings = new SettingsLayouts ();
			var list = make_list_store ();
			tree     = new Gtk.TreeView.with_model (list);
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

			var add_button    = new Gtk.ToolButton (null, _("Add…"));
			var remove_button = new Gtk.ToolButton (null, _("Remove"));
			var up_button     = new Gtk.ToolButton (null, _("Move up"));
			var down_button   = new Gtk.ToolButton (null, _("Move down"));

			add_button.set_tooltip_text    (_("Add…"));
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
				// uncomment when reverting to popover
				//pop.move_to_widget (add_button);
				// and remove this line
				pop.show_all ();
				add_item (tree, pop);
			} );

			remove_button.clicked.connect( () => {
				remove_item (tree);
				update_buttons ();
			} );

			up_button.clicked.connect (() => {
				move_item (tree, 0);
				update_buttons ();
			} );

			down_button.clicked.connect (() => {
				move_item (tree, 1);
				update_buttons ();
			} );

			tree.cursor_changed.connect (() => {
				update_buttons ();
			} );

			this.update_buttons.connect (() =>
			{
				Gtk.TreePath path;

				tree.get_cursor (out path, null);

				if (path == null)
				{
					up_button.sensitive     = false;
					down_button.sensitive   = false;
					remove_button.sensitive = false;
					return;
				}

				int index = (path.get_indices ())[0];
				int count = settings.layouts.length - 1;

				up_button.sensitive     = (index != 0);
				down_button.sensitive   = (index != count);
				remove_button.sensitive = (count > 0);
			} );
		}

		private Gtk.ListStore make_list_store ()
		{
			Gtk.ListStore list_store = new Gtk.ListStore (3, typeof (string), typeof(uint), typeof(uint));
			Gtk.TreeIter iter;

			uint layout = 0, variant = 0;

			foreach (string item in settings.layouts)
			{
				handler.from_code (item, out layout, out variant);
				item = handler.get_name (layout, variant);

				list_store.append (out iter);
				list_store.set (iter, 0, item);
				list_store.set (iter, 1, layout);
				list_store.set (iter, 2, variant);
			}

			return list_store;
		}

		public void reset_all ()
		{
			settings.reset_all ();
			tree.model = make_list_store ();
			update_buttons ();
		}

		void add_item (Gtk.TreeView tree, Layout.AddLayout pop)
		{
			pop.layout_added.connect ((layout, variant) =>
			{
				Gtk.TreeIter iter;

				var name = handler.get_name (layout, variant);
				var code = handler.get_code (layout, variant);
				var list = tree.model as Gtk.ListStore;

				if (settings.add_layout (code))
				{
					list.append (out iter);
					list.set (iter, 0, name);
					list.set (iter, 1, layout);
					list.set (iter, 2, variant);

					tree.set_cursor (list.get_path(iter), null, false);
					update_buttons ();
				}
			} );
		}

		void remove_item (Gtk.TreeView tree)
		{
			Gtk.TreeModel model;
			Gtk.TreeIter  iter;

			var select = tree.get_selection();
			select.get_selected (out model, out iter);

			GLib.Value layout, variant;
			model.get_value (iter, 1, out layout);
			model.get_value (iter, 2, out variant);

			settings.remove_layout (handler.get_code ((uint)layout, (uint)variant));
			stdout.printf ("%s\n", handler.get_code ((uint)layout, (uint)variant));
			(model as Gtk.ListStore).remove(iter);
		}

		void move_item (Gtk.TreeView tree, int dir)
		{
			Gtk.TreeModel model;
			Gtk.TreeIter  iter_current, iter_new;
			Gtk.TreePath  path_current;

			var select = tree.get_selection();
			select.get_selected (out model, out iter_current);
			path_current = model.get_path (iter_current);

			iter_new = iter_current;

			var store = model as Gtk.ListStore;

			switch (dir)
			{
				case 1: if (model.iter_next (ref iter_new) == false)
							return;
						break;
				case 0: if (model.iter_previous (ref iter_new) == false)
							return;
						break;
			}

			store.swap (iter_current, iter_new);

			tree.set_cursor (model.get_path (iter_current), null, false);

			switch (dir)
			{
				case 1:
						settings.layout_down ((path_current.get_indices()) [0]);
						break;
				case 0:
						settings.layout_up   ((path_current.get_indices()) [0]);
						break;
			}
		}
	}
}