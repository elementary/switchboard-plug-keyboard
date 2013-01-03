namespace Keyboard.Page
{
		// pop over widget to add a new keyboard layout
		class AddLayout : Granite.Widgets.PopOver
		{
			public signal void layout_added (string language, string? layout = null);
			
			public AddLayout()
			{
				var grid = new Gtk.Grid();
				
				grid.margin         = 12;
				grid.column_spacing = 12;
				grid.row_spacing    = 12;
				
				Gtk.Box content = this.get_content_area ();
				content.pack_start (grid, false, true, 0);
				
				// add some labels
				var label_language = new Gtk.Label (_("Language:"));
				var label_layout   = new Gtk.Label (_("Layout:"));

				label_language.valign = label_layout.valign = Gtk.Align.CENTER;
				label_language.halign = label_layout.halign = Gtk.Align.END;
				
				grid.attach (label_language, 0, 0, 1, 1);
				grid.attach (label_layout,   0, 1, 1, 1);
				
				// list stores
				var lang_list   = create_list_store (handler.language_names);
				var layout_list = create_list_store (handler.variants (handler.language_names[0]));
				
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
				
				language_box.changed.connect( () => {
					Value val;
					Gtk.TreeIter iter;
					
					language_box.get_active_iter (out iter);
					lang_list.get_value (iter, 0, out val);
					
					layout_box.model = create_list_store (handler.variants((string) val));
					layout_box.active = 0;
				} );
				
				// add 'apply' and 'close' buttons
				this.add_button (Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
				this.add_button (Gtk.Stock.APPLY, Gtk.ResponseType.APPLY);
				
				this.response.connect( (source, response_id) =>
				{
					Value val1, val2;
					Gtk.TreeIter iter;
					
					this.hide ();
					
					if (response_id != Gtk.ResponseType.APPLY) {
						return;
					}
					
					language_box.get_active_iter (out iter);
					language_box.model.get_value (iter, 0, out val1);
					layout_box.get_active_iter   (out iter);
					layout_box.model.get_value   (iter, 0, out val2);

					if ((string)val2 == _("(Default)"))
						layout_added ((string) val1);
					else
						layout_added ((string) val1, (string) val2);		
				} );
			}
		}
}
