namespace Pantheon.Keyboard.LayoutPage
{
	// widget to display/add/remove/move keyboard layouts
	// interacts with class SettingsLayout
	class Display : Gtk.Grid
	{

		LayoutSettings settings;
		Gtk.TreeView tree;
        Gtk.ToolButton up_button;
        Gtk.ToolButton down_button;
        Gtk.ToolButton add_button;
        Gtk.ToolButton remove_button;

		public Display ()
		{
			settings = LayoutSettings.get_instance ();

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

			add_button    = new Gtk.ToolButton (null, _("Add…"));
			remove_button = new Gtk.ToolButton (null, _("Remove"));
			up_button     = new Gtk.ToolButton (null, _("Move up"));
			down_button   = new Gtk.ToolButton (null, _("Move down"));

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
				update_buttons ();
			});

			remove_button.clicked.connect( () => {
				remove_item (tree);
				update_buttons ();
			});

			up_button.clicked.connect (() => {
				move_item (tree, true);
				update_buttons ();
			});

			down_button.clicked.connect (() => {
				move_item (tree, false);
				update_buttons ();
			});

			tree.cursor_changed.connect (() => {
				update_buttons ();
				settings.layouts.active = get_cursor_index ();
			});
		}

        public void reset_all ()
		{
			settings.reset_all ();
			tree.model = make_list_store ();
			update_buttons ();
		}

        /**
         * Returns the index of the selected layout in the UI.
         * In case the list contains no layouts, it returns -1.
         */
        int get_cursor_index () {
                Gtk.TreePath path;

				tree.get_cursor (out path, null);

				if (path == null)
				{
					return -1;
				}

				return (path.get_indices ())[0];
        }

        void update_buttons () {
                int index = get_cursor_index ();

                // if empty list
				if (index == -1)
				{
					up_button.sensitive     = false;
					down_button.sensitive   = false;
					remove_button.sensitive = false;
				} else {
				    up_button.sensitive     = (index != 0);
				    down_button.sensitive   = (index != settings.layouts.length - 1);
				    remove_button.sensitive = (settings.layouts.length > 0);
				}
        }

		Gtk.ListStore make_list_store () {
			Gtk.ListStore list_store = new Gtk.ListStore (3, typeof (string), typeof(uint), typeof(uint));
			Gtk.TreeIter iter;

			uint layout = 0, variant = 0;

            for (uint i = 0; i < settings.layouts.length; i++) {
			    string item = settings.layouts.get_layout (i).name;
				handler.from_code (item, out layout, out variant);
				item = handler.get_name (layout, variant);

				list_store.append (out iter);
				list_store.set (iter, 0, item);
				list_store.set (iter, 1, layout);
				list_store.set (iter, 2, variant);
			}

			return list_store;
		}

		void add_item (Gtk.TreeView tree, LayoutPage.AddLayout pop)
		{
			pop.layout_added.connect ((layout, variant) =>
			{
				Gtk.TreeIter iter;

				var name = handler.get_name (layout, variant);
				var code = handler.get_code (layout, variant);
				var list = tree.model as Gtk.ListStore;

                // TODO variant
				if (settings.layouts.add_layout (new Layout.XKB (code, "")))
				{
					list.append (out iter);
					list.set (iter, 0, name);
					list.set (iter, 1, layout);
					list.set (iter, 2, variant);

					tree.set_cursor (list.get_path (iter), null, false);
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

			settings.layouts.remove_active_layout ();
			(model as Gtk.ListStore).remove(iter);
		}

		void move_item (Gtk.TreeView tree, bool move_up)
		{
			Gtk.TreeModel model;
			Gtk.TreeIter  iter_current, iter_new;
			Gtk.TreePath  path_current;

			var select = tree.get_selection();
			select.get_selected (out model, out iter_current);
			path_current = model.get_path (iter_current);

			iter_new = iter_current;

			var store = model as Gtk.ListStore;

			if (move_up) {
			    if (model.iter_previous (ref iter_new) == false)
				    return;
			} else {
			    if (model.iter_next (ref iter_new) == false)
				    return;
			}

			store.swap (iter_current, iter_new);

			if (move_up) {
				settings.layouts.move_active_layout_up ();
			} else {
			    settings.layouts.move_active_layout_down ();
			}

			tree.set_cursor (model.get_path (iter_current), null, false);
		}
	}
}