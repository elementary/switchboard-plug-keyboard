namespace Keyboard.Shortcuts
{
	// main class
	class Page : Gtk.Grid
	{
		public Page ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.expand         = true;
		
			var notebook = new Granite.Widgets.StaticNotebook ();
		
			notebook.append_page (new Display (windows ()),     new Gtk.Label (_("Windows")));
			notebook.append_page (new Display (workspaces ()),  new Gtk.Label (_("Workspaces")));
			notebook.append_page (new Display (screenshots ()), new Gtk.Label (_("Screenshots")));
			notebook.append_page (new Display (media ()),       new Gtk.Label (_("Media")));
			notebook.append_page (new Display (a11y ()),        new Gtk.Label (_("Accessibility")));

			this.attach (notebook, 0, 0, 1, 1);
		}

		private Gtk.TreeView windows ()
		{
			string[] actions = {
				_("Close"),
				_("Lower"),
				_("Maximize"),
				_("Unmaximize"),
				_("Toggle Maximized"),
				_("Minimize"),
				_("Toggle Fullscreen"),
				_("Tile Left"),
				_("Tile Right"),
				_("Toggle Shaded"),
				_("Toggle on all Workspaces"),
				_("Toggle always on Top"),
				_("Expose Windows"),
				_("Expose all Windows")
			};
		
			Settings.Schema[] schemas = {
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.MUTTER,
				Settings.Schema.MUTTER,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.GALA,
				Settings.Schema.GALA
			};
		
			string[] keys = {
				"close",
				"lower",
				"maximize",
				"unmaximize",
				"toggle-maximized",
				"minimize",
				"toggle-fullscreen",
				"toggle-tiled-left",
				"toggle-tiled-right",
				"toggle-shaded",
				"toggle-on-all-workspaces",
				"toggle-above",
				"expose-windows",
				"expose-all-windows"
			};
		
			return new Shortcuts.Tree( actions, schemas, keys );
		}
		
		private Gtk.TreeView workspaces ()
		{
			string[] actions = {
				_("Switch to first"),
				_("Switch to new"),
				_("Switch to workspace 1"),
				_("Switch to workspace 2"),
				_("Switch to workspace 3"),
				_("Switch to workspace 4"),
				_("Switch to workspace 5"),
				_("Switch to workspace 6"),
				_("Switch to workspace 7"),
				_("Switch to workspace 8"),
				_("Switch to workspace 9"),
				_("Switch to left"),
				_("Switch to right"),
				_("Move to workspace 1"),
				_("Move to workspace 2"),
				_("Move to workspace 3"),
				_("Move to workspace 4"),
				_("Move to workspace 5"),
				_("Move to workspace 6"),
				_("Move to workspace 7"),
				_("Move to workspace 8"),
				_("Move to workspace 9"),
				_("Move to left"),
				_("Move to right"),
				_("Show Workspace Switcher")
			};
			
			Settings.Schema[] schemas = {
				Settings.Schema.GALA,
				Settings.Schema.GALA,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM,
				Settings.Schema.WM
			};
		
			string[] keys = {
				"move-to-workspace-first",
				"move-to-workspace-last",
				"switch-to-workspace-1",
				"switch-to-workspace-2",
				"switch-to-workspace-3",
				"switch-to-workspace-4",
				"switch-to-workspace-5",
				"switch-to-workspace-6",
				"switch-to-workspace-7",
				"switch-to-workspace-8",
				"switch-to-workspace-9",
				"switch-to-workspace-left",
				"switch-to-workspace-right",
				"move-to-workspace-1",
				"move-to-workspace-2",
				"move-to-workspace-3",
				"move-to-workspace-4",
				"move-to-workspace-5",
				"move-to-workspace-6",
				"move-to-workspace-7",
				"move-to-workspace-8",
				"move-to-workspace-9",
				"move-to-workspace-left",
				"move-to-workspace-right",
				"show-desktop"
			};
		
			return new Shortcuts.Tree( actions, schemas, keys );
		}

		private Gtk.TreeView screenshots ()
		{
			string[] actions = {
				_("Take a Screenshot"),
				_("Save Screenshot to Clipboard"),
				_("Take a Screenshot of a Window"),
				_("Save Window-Screenshot to Clipboard"),
				_("Take a Screenshot of an Area"),
				_("Save Area-Screenshot to Clipboard")
			};

			Settings.Schema[] schemas = {
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA
			};
		
			string[] keys = {
				"screenshot",
				"screenshot-clip",
				"window-screenshot",
				"window-screenshot-clip",
				"area-screenshot",
				"area-screenshot-clip"
			};
		
			return new Shortcuts.Tree( actions, schemas, keys );
		}
		
		private Gtk.TreeView media ()
		{
			string[] actions = {
				_("Volume Up"),
				_("Volume Down"),
				_("Mute"),
				_("Launch Media Player"),
				_("Play"),
				_("Pause"),
				_("Stop"),
				_("Previous Track"),
				_("Next Track"),
				_("Eject")
			};

			Settings.Schema[] schemas = {
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA
			};
		
			string[] keys = {
				"volume-up",
				"volume-down",
				"volume-mute",
				"media",
				"play",
				"pause",
				"stop",
				"next",
				"previous",
				"eject"
			};
		
			return new Shortcuts.Tree( actions, schemas, keys );
		}
		
		private Gtk.TreeView a11y ()
		{
			string[] actions = {
				_("Decrease Text Size"),
				_("Increase Text Size"),
				_("Toggle Magnifier"),
				_("Magnifier Zoom in"),
				_("Magnifier Zoom out"),
				_("Toggle On Screen Keyboard"),
				_("Toggle Screenreader"),
				_("Toggle High Contrast")
				
			};

			Settings.Schema[] schemas = {
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA,
				Settings.Schema.MEDIA
			};
		
			string[] keys = {
				"decrease-text-size",
				"increase-text-size",
				"magnifier",
				"magnifier-zoom-in",
				"magnifier-zoom-out",
				"on-screen-keyboard",
				"screenreader",
				"toggle-contrast"
			};
		
			return new Shortcuts.Tree( actions, schemas, keys );
		}
	}
}
