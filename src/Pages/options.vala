namespace Keyboard.Options
{
	// global handler
	private OptionHandler option_handler;
	// global settings object
	private OptionSettings option_settings;
	
	class Page : AbstractPage
	{
		public override void reset ()
		{
			// TODO: Implement this…
			return;
		}
		
		public Page (string title)
		{
			base (title);
			
			option_handler  = new OptionHandler ();
			option_settings = new OptionSettings ();
			
			var section_switcher = new SectionSwitcher ();
			var section_display  = new SectionDisplay  ();
			
			this.attach (section_switcher, 0, 0, 1, 1);
			this.attach (section_display,  1, 0, 1, 1);
			
			section_switcher.changed.connect ((i) => {
				section_display.selected = i;
			});
			
			for (int i = 0; i < option_settings.u_groups.length; i++)
				section_display.set_option (option_settings.u_groups[i],
											option_settings.u_options[i],
											true);
		}
	}
}
