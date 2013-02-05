namespace Keyboard.Options
{
	class SectionDisplay : Gtk.ScrolledWindow
	{
		OptionTree[] trees;
		
		public SectionDisplay ()
		{
			for (int i = 0; i < option_handler.length; i++)
				trees += new OptionTree (i);
				
			this.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
			this.shadow_type = Gtk.ShadowType.IN;
			this.expand = true;
			
			this.add (trees[0]);
		}
		
		public void set_option (uint group, uint option, bool status)
		{
			trees[group].set_option (option, status);
		}
		
		public uint selected
		{
			get {
				var tree = get_child () as OptionTree;
				return (tree != null) ? tree.option_group : 0;
			}
			set {
				this.remove (trees[selected]);
				this.add    (trees[value]);

				this.show_all ();
			}
		}
	}
}
