namespace Keyboard.Page
{
	class Layout : Gtk.Grid
	{
		// pop over widget to add a new keyboard layout
		private class AddLayout : Granite.Widgets.PopOver
		{
			public AddLayout()
			{
				var grid = new Gtk.Grid();
				
				grid.margin         = 12;
				grid.column_spacing = 12;
				grid.row_spacing    = 12;
				
				Gtk.Box content = get_content_area () as Gtk.Box;
				content.pack_start (grid, false, true, 0);
				
				// add some labels
				var label_language = new Gtk.Label (_("Language:"));
				var label_layout   = new Gtk.Label (_("Layout:"));
				
				label_language.valign = label_layout.valign = Gtk.Align.CENTER;
				label_language.halign = label_layout.halign = Gtk.Align.END;
				
				grid.attach (label_language, 0, 0, 1, 1);
				grid.attach (label_layout,   0, 1, 1, 1);
				
				var lang_list   = language_list_store ();
				var layout_list = layout_list_store ("Afghani");
				
				// combo boxes to select language and layout
				var language_box = new Gtk.ComboBox.with_model (lang_list);
				var layout_box   = new Gtk.ComboBox.with_model (layout_list);
				
				var renderer = new Gtk.CellRendererText ();
				
				language_box.pack_start (renderer, true);
				language_box.add_attribute (renderer, "text", 0);
				language_box.active = 0;
				
				layout_box.pack_start (renderer, true);
				layout_box.add_attribute (renderer, "text", 0);
				layout_box.active = 0;
				
				grid.attach (language_box, 1, 0, 1, 1);
				grid.attach (layout_box,   1, 1, 1, 1);
				
				// button box with 'add' and 'cancel' buttons
				var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
				
				var button_add    = new Gtk.Button.with_label (_("Add"));
				var button_cancel = new Gtk.Button.with_label (_("Cancel"));
				
				button_box.layout_style = Gtk.ButtonBoxStyle.END;
				
				button_box.pack_start (button_cancel);
				button_box.pack_start (button_add);
				
				grid.attach (button_box, 1, 2, 1, 1);
				
				button_add.clicked.connect( () =>
				{
					Value val1, val2;
					Gtk.TreeIter iter;
					this.hide ();
					
					language_box.get_active_iter (out iter);
					lang_list.get_value   (iter, 0, out val1);
					layout_box.get_active_iter (out iter);
					layout_list.get_value (iter, 0, out val2);

					layout_added ((string) val1, (string) val2, "bla");					
				} );
				
				button_cancel.clicked.connect( () =>
				{
					this.hide ();				
				} );
			}
			
			public signal void layout_added (string language, string layout, string code);
		}
		
		private class ListDisplay : Gtk.Grid
		{
			public ListDisplay ()
			{
				var list = new Gtk.ListStore (1, typeof(string));
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

				scroll.get_style_context().set_junction_sides(Gtk.JunctionSides.BOTTOM);
				tbar.get_style_context().add_class(Gtk.STYLE_CLASS_INLINE_TOOLBAR);
				tbar.get_style_context().set_junction_sides(Gtk.JunctionSides.TOP);

				var add_button = new Gtk.ToolButton(null, _("Add"));
				add_button.set_tooltip_text(_("Add"));
				add_button.set_icon_name("list-add-symbolic");
				tbar.insert(add_button, -1);

				var pop = new AddLayout ();

				add_button.clicked.connect( () =>
				{
					pop.move_to_widget (add_button);
					
					pop.layout_added.connect ((lang, layout, code) =>
					{
						Gtk.TreeIter iter;
						list.append (out iter);
						list.set (iter, 0, lang+" - "+layout);
					} );
				} );

				var remove_button = new Gtk.ToolButton(null, _("Remove"));
				remove_button.set_tooltip_text(_("Remove"));
				remove_button.set_icon_name("list-remove-symbolic");
				tbar.insert(remove_button, -1);
				
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
						(model as Gtk.ListStore).remove(iter);
					}
				} );
				
				this.attach (scroll, 0, 0, 1, 1);
				this.attach (tbar,   0, 1, 1, 1);
			}
		}
		
		public static Gtk.ListStore language_list_store()
		{
			Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
			Gtk.TreeIter iter;

			var file = File.new_for_path ("layouts.txt");

			if (!file.query_exists ())
			{
				stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
				return null as Gtk.ListStore;
			}

			try 
			{
				var dis = new DataInputStream (file.read ());
				
				string line;
				
				while ((line = dis.read_line (null)) != null)
				{
				    if( /\|.*\|/.match(line) )
				    {
				    	list_store.append (out iter);
						list_store.set (iter, 0, line.replace ("|", ""));	
				    }
				}
			}
			
			catch (Error e)
			{
				error ("%s", e.message);
			}
			
			return list_store;
		}
	
		public static Gtk.ListStore layout_list_store( string language)
		{
			Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
			Gtk.TreeIter iter;

			list_store.append (out iter);
			list_store.set (iter, 0, language + " " + _("(Default)"));	

			var file = File.new_for_path ("layouts.txt");

			if (!file.query_exists ())
			{
				stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
				return null as Gtk.ListStore;
			}

			try 
			{
				var dis = new DataInputStream (file.read ());
				
				string line;
				
				while ((line = dis.read_line (null)) != null)
				{
				    if (line == "|"+language+"|")
				    {
				    	while ((line = dis.read_line (null)) != null)
						{
							if( /\|.*\|/.match(line) )
							{
								break;
							}
							
							list_store.append (out iter);
							list_store.set (iter, 0, line);	
						}
						break;
				    }
				}
			}
			
			catch (Error e)
			{
				error ("%s", e.message);
			}
			
			return list_store;
		}
		
		public Layout ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.column_homogeneous = false;
			this.row_homogeneous    = false;
			
			// first some labels
			var label_1   = new Gtk.Label (_("Allow different layouts for individual windows:"));
			var label_2   = new Gtk.Label (_("New windows use:"));
			
			label_1.valign = Gtk.Align.CENTER;
			label_1.halign = Gtk.Align.END;
			label_2.valign = Gtk.Align.CENTER;
			label_2.halign = Gtk.Align.END;
			
			this.attach (label_1, 1, 0, 1, 1);
			this.attach (label_2, 1, 1, 1, 1);
			
			// widgets to change settings
			var switch_main = new Gtk.Switch();
			switch_main.expand = false;
			switch_main.halign = Gtk.Align.START;
			switch_main.valign = Gtk.Align.CENTER;
			
			var button1 = new Gtk.RadioButton.with_label(null, _("the default layout"));
			var button2 = new Gtk.RadioButton.with_label_from_widget (button1, _("the previous window's layout"));
			
			this.attach (switch_main, 2, 0, 1, 1);
			this.attach (button1, 2, 1, 1, 1);
			this.attach (button2, 2, 2, 1, 1);
			
			// tree view to display the current layouts
			var display = new ListDisplay ();
			
			this.attach (display, 0, 0, 1, 4);
			
			// Test entry
			var entry_test = new Granite.Widgets.HintedEntry (_("Type to test your layout..."));
		
			entry_test.hexpand = entry_test.vexpand = true;
			entry_test.valign  = Gtk.Align.END;
			entry_test.set_icon_from_stock (Gtk.EntryIconPosition.SECONDARY, Gtk.Stock.CLEAR);
		
			entry_test.icon_press.connect ((pos, event) => 
			{
				if (pos == Gtk.EntryIconPosition.SECONDARY) 
				{
					entry_test.set_text ("");
				}
			});
		
			this.attach (entry_test, 1, 3, 3, 1);
		}
	}
}
