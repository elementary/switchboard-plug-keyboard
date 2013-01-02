namespace Keyboard.Page
{
	class Shortcuts : Gtk.Grid
	{
		public Shortcuts ()
		{
			this.row_spacing    = 12;
			this.column_spacing = 12;
			this.margin         = 20;
			this.expand         = true;
		
			/*
			 * Where to find shortcuts in dconf:
			 *
			 * -> org.gnome.mutter.keybindings
			 * -> org.gnome.settings-daemon.plugins.media-keys
			 * -> org.gnome.desktop.wm.keybindings
			 			close
			 			lower
			 			maximize
			 			minimize
			 			move to workspace x, right, left
			 			switch to workspace x, right, left
			 			toggle-maximize/shaded/on-all-workspaces
			 			show-desktop: shows workspace switcher
			 * -> org.pantheon.desktop.gala.behavior
			 			expose all windows
			 			expose windows
			 			move to first workspace
			 			move to last workspace
			 			zoom in
			 			zoom out
			 * -> org.gnome.settings-daemon.plugins.power (managed in power plug)
			 *
			 *
			 */
		}
	}
}
