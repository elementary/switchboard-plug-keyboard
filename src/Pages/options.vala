namespace Pantheon.Keyboard.Options
{
	// global handler
	private OptionHandler option_handler;
	// global settings object
	private OptionSettings option_settings;
	
	class Page : Pantheon.Keyboard.AbstractPage
	{
		SectionSwitcher section_switcher;
		SectionDisplay  section_display;
		
		// reset all options
		public override void reset ()
		{
			option_settings.reset ();
			return;
		}
		
		// set the gui according to the current settings
		private void set_option_gui () 
		{
			for (int i = 0; i < option_settings.groups.length; i++)
				section_display.set_option (option_settings.groups[i], option_settings.options[i], true);
		}
		
		public Page ()
		{
			//option_handler  = new OptionHandler ();
			//option_settings = new OptionSettings ();
			//
			//section_switcher = new SectionSwitcher ();
			//section_display  = new SectionDisplay  ();
			//
			//this.attach (section_switcher, 0, 0, 1, 1);
			//this.attach (section_display,  1, 0, 1, 1);
			//
			//set_option_gui ();
			//
			//// connect switcher and diyplay
			//section_switcher.changed.connect ((i) => {
			//	section_display.selected = i;
			//});
			//
			//option_settings.external_change.connect (set_option_gui);
			//
			//section_display.apply_changes.connect (() => {
			//	option_settings.apply ();
			//});
			//
			//section_display.changed.connect ((state, group, option) => 
			//{
			//	if (state == true)
			//		option_settings.add (group, option);
			//	else
			//		option_settings.remove (group, option);
			//});
		}
	}
}
