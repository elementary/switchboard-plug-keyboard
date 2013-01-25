namespace Keyboard.Widgets
{
	class TryEntry : Granite.Widgets.HintedEntry
	{
		public TryEntry (string? text)
		{
			base ((text == null) ? "" : text);
			
			this.icon_release.connect ((pos, event) => 
			{
				if (pos == Gtk.EntryIconPosition.SECONDARY) 
				{
					this.set_text ("");
				}
			} );
			
			this.changed.connect (() =>
			{
				if (this.text == "")
					this.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "");
				else
					this.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
			} );
		}
	}
}
