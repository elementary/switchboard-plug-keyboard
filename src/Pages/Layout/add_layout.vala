namespace Pantheon.Keyboard.Layout
{
	// pop over widget to add a new keyboard layout
	class AddLayout : Gtk.Dialog
	{
		public signal void layout_added (int language, int layout = 0);

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
			var lang_list   = create_list_store (handler.get_layouts ());
			var layout_list = create_list_store (handler.get_variants (0));

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

			language_box.changed.connect( () =>
			{
				var active = language_box.active;
				layout_box.model = create_list_store (handler.get_variants (active));
				layout_box.active = 0;
			} );

			// add buttons
			var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
			button_box.layout_style = Gtk.ButtonBoxStyle.END;
			button_box.spacing      = 5;
			button_box.margin       = 1;

			var button_add    = new Gtk.Button.with_label (_("Add Layout"));
			var button_cancel = new Gtk.Button.with_label (_("Cancel"));

			button_box.add (button_cancel);
			button_box.add (button_add);

			grid.attach (button_box, 0, 2, 2, 1);

			button_cancel.clicked.connect (() => {
				this.hide ();
			} );

			button_add.clicked.connect (() =>
			{
				this.hide ();
				layout_added (language_box.active, layout_box.active);
			} );
		}
	}
}