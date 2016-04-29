namespace Pantheon.Keyboard.LayoutPage
{
    class Xkb_modifier {
        public string name;
        private string active_command;
        public signal void active_command_updated ();
        private string default_command;

        public string [] xkb_option_commands;
        public string [] option_descriptions;

        public Xkb_modifier (string name = "") {
            this.name = name;
        }


        public string get_active_command () {
            if ( active_command == null ) {
                return default_command;
            } else {
                return active_command;
            }
        }

        public void set_active_command ( string val ) {
                if ( val == active_command ) {
                    return;
                }
                if ( val in xkb_option_commands ) {
                    active_command = val;
                }
        }

        public void update_active_command ( string val ) {
                if ( val == active_command ) {
                    return;
                }
                if ( val in xkb_option_commands ) {
                    active_command = val;
                    active_command_updated ();
                }
        }

        public void set_default_command ( string val ) {
            if ( val in xkb_option_commands ) {
                default_command = val;
            } else {
                return;
            }
        }

        public string get_default_command () {
            return default_command;
        }

        public void append_xkb_option ( string xkb_command, string description ){
            xkb_option_commands += xkb_command;
            option_descriptions += description;
        }
    }
}



