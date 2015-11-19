namespace Pantheon.Keyboard.Options {
	public class Item : GLib.Object {
		public string label { public get; private set; }
		public string option { public get; private set; }
		public bool multiple_selection { public get; private set; }
		public HashTable<string, string> table { public get; private set; }

		public Item (string label, string option, bool multiple_selection) {
			table = new HashTable<string, string> (str_hash, str_equal);
			this.label = label;
			this.option = option;
			this.multiple_selection = multiple_selection;

			if (multiple_selection == false) {
				table.@set (_("None"), option+":");
			}
		}

		public new void @set (string key, string value) {
			table.@set (key, value);
		}
	}

	// class that parses the layout file, provides lists of languages and
	// options, and converts between layout names and their gsettings codes	
	class OptionHandler : GLib.Object {
		List<Item> items;

		public uint length {
			get {return items.length ();}
		}

		public OptionHandler () {
			generate_items ();
		}

		public string[] get_groups () {
			string[] names = null;
			foreach (var item in items) {
				names += item.label;
			}

			return names;
		}

		public string[] get_options (uint index) {
			string[] options = null;
			var opts = items.nth_data (index).table.get_keys ();
			foreach (var option in opts) {
				options += option;
			}

			return options;
		}

		public bool get_multiple_selection (uint index) {
			return items.nth_data (index).multiple_selection;
		}

		public string? get_code (uint index, uint v) {
			var item = items.nth (index).data;
			return item.table.get_values ().nth_data (v);
		}

		public string get_name (uint index, uint v) {
			return items.nth_data (index).table.get_keys ().nth_data (v);
		}

		public bool from_code (string code, out uint l, out uint v) {
			var parts = code.split (":", 2);
			l = v = 0;
			if (parts[0] == null || parts[1] == null)
				return false;

			foreach (var item in items) {
				v = 0;

				foreach (var val in item.table.get_values ()) {
					if (val == code)
						return true;

					v++;
				}

				l++;
			}

			return false;
		}

		private void generate_items () {
			items = new List<Item> ();

			var item = new Item (_("Ctrl key position"), "ctrl", true);
			item.set (_("Caps Lock as Ctrl"), "ctrl:nocaps");
			item.set (_("Left Ctrl as Meta"), "ctrl:lctrl_meta");
			item.set (_("Swap Ctrl and Caps Lock"), "ctrl:swapcaps");
			item.set (_("At left of 'A'"), "ctrl:ac_ctrl");
			item.set (_("At bottom left"), "ctrl:aa_ctrl");
			item.set (_("Right Ctrl as Right Alt"), "ctrl:rctrl_ralt");
			item.set (_("Menu as Right Ctrl"), "ctrl:menu_rctrl");
			item.set (_("Right Alt as Right Ctrl"), "ctrl:ctrl_ralt");
			items.append (item);

			item = new Item (_("Numeric keypad layout selection"), "keypad", false);
			item.set (_("Legacy"), "keypad:legacy");
			item.set (_("Unicode additions (arrows and math operators)"), "keypad:oss");
			item.set (_("Unicode additions (arrows and math operators). Math operators on default level"), "keypad:future");
			item.set (_("Legacy Wang 724"), "keypad:legacy_wang");
			item.set (_("Wang 724 keypad with Unicode additions (arrows and math operators)"), "keypad:oss_wang");
			item.set (_("Wang 724 keypad with Unicode additions (arrows and math operators). Math operators on default level"), "keypad:future_wang");
			item.set (_("Hexadecimal"), "keypad:hex");
			item.set (_("ATM/phone-style"), "keypad:atm");
			items.append (item);

			item = new Item (_("Numeric keypad delete key behaviour"), "kpdl", false);
			item.set (_("Legacy key with dot"), "kpdl:dot");
			item.set (_("Legacy key with comma"), "kpdl:comma");
			item.set (_("Four-level key with dot"), "kpdl:dotoss");
			item.set (_("Four-level key with dot, latin-9 restriction"), "kpdl:dotoss_latin9");
			item.set (_("Four-level key with comma"), "kpdl:commaoss");
			item.set (_("Four-level key with momayyez"), "kpdl:momayyezoss");
			item.set (_("Four-level key with abstract separators"), "kpdl:kposs");
			item.set (_("Semi-colon on third level"), "kpdl:semi");
			items.append (item);

			item = new Item (_("Alt/Win key behavior"), "altwin", false);
			item.set (_("Add the standard behavior to Menu key"), "altwin:menu");
			item.set (_("Alt and Meta are on Alt keys"), "altwin:meta_alt");
			item.set (_("Control is mapped to Win keys (and the usual Ctrl keys)"), "altwin:ctrl_win");
			item.set (_("Control is mapped to Alt keys, Alt is mapped to Win keys"), "altwin:ctrl_alt_win");
			item.set (_("Meta is mapped to Win keys"), "altwin:meta_win");
			item.set (_("Meta is mapped to Left Win"), "altwin:left_meta_win");
			item.set (_("Hyper is mapped to Win-keys"), "altwin:hyper_win");
			item.set (_("Alt is mapped to Right Win, Super to Menu"), "altwin:alt_super_win");
			item.set (_("Alt is mapped to Win keys (and the usual Alt keys)"), "altwin:alt_win");
			item.set (_("Alt is swapped with Win"), "altwin:swap_alt_win");
			items.append (item);

			item = new Item (_("Miscellaneous compatibility options"), "compat", true);
			item.set (_("Default numeric keypad keys"), "numpad:pc");
			item.set (_("Numeric keypad keys always enter digits (as in Mac OS)"), "numpad:mac");
			item.set (_("Shift with numeric keypad keys works as in MS Windows"), "numpad:microsoft");
			item.set (_("Shift does not cancel Num Lock, chooses 3rd level instead"), "numpad:shift3");
			item.set (_("Special keys (Ctrl+Alt+<key>) handled in a server"), "srvrkeys:none");
			item.set (_("Apple Aluminium Keyboard: emulate PC keys (Print, Scroll Lock, Pause, Num Lock)"), "apple:alupckeys");
			item.set (_("Shift cancels Caps Lock"), "shift:breaks_caps");
			item.set (_("Enable extra typographic characters"), "misc:typo");
			item.set (_("Both Shift-Keys together toggle Caps Lock"), "shift:both_capslock");
			item.set (_("Both Shift-Keys together activate Caps Lock, one Shift-Key deactivates"), "shift:both_capslock_cancel");
			item.set (_("Both Shift-Keys together toggle ShiftLock"), "shift:both_shiftlock");
			item.set (_("Toggle PointerKeys with Shift + NumLock"), "keypad:pointerkeys");
			item.set (_("Allow breaking grabs with keyboard actions (warning: security risk)"), "grab:break_actions");
			items.append (item);

			item = new Item (_("Adding currency signs to certain keys"), "eurosign", true);
			item.set (_("Euro on E"), "eurosign:e");
			item.set (_("Euro on 2"), "eurosign:2");
			item.set (_("Euro on 4"), "eurosign:4");
			item.set (_("Euro on 5"), "eurosign:5");
			item.set (_("Rupee on 4"), "rupeesign:4");
			items.append (item);

			item = new Item (_("Using space key to input non-breakable space character"), "nbsp", false);
			item.set (_("Usual space at any level"), "nbsp:none");
			item.set (_("Non-breakable space character at second level"), "nbsp:level2");
			item.set (_("Non-breakable space character at third level"), "nbsp:level3");
			item.set (_("Non-breakable space character at third level, nothing at fourth leve"), "nbsp:level3s");
			item.set (_("Non-breakable space character at third level, thin non-breakable space character at fourth level"), "nbsp:level3n");
			item.set (_("Non-breakable space character at fourth level"), "nbsp:level4");
			item.set (_("Non-breakable space character at fourth level, thin non-breakable space character at sixth level"), "nbsp:level4n");
			item.set (_("Non-breakable space character at fourth level, thin non-breakable space character at sixth level (via Ctrl+Shift)"), "nbsp:level4nl");
			item.set (_("Zero-width non-joiner character at second level"), "nbsp:zwnj2");
			item.set (_("Zero-width non-joiner character at second level, zero-width joiner character at third level"), "nbsp:zwnj2zwj3");
			item.set (_("Zero-width non-joiner character at second level, zero-width joiner character at third level, non-breakable space character at fourth level"), "nbsp:zwnj2zwj3nb4");
			item.set (_("Zero-width non-joiner character at second level, non-breakable space character at third level"), "nbsp:zwnj2nb3");
			item.set (_("Zero-width non-joiner character at second level, non-breakable space character at third level, nothing at fourth level"), "nbsp:zwnj2nb3s");
			item.set (_("Zero-width non-joiner character at second level, non-breakable space character at third level, zero-width joiner at fourth level"), "nbsp:zwnj2nb3zwj4");
			item.set (_("Zero-width non-joiner character at second level, non-breakable space character at third level, thin non-breakable space at fourth level"), "nbsp:zwnj2nb3nnb4");
			item.set (_("Zero-width non-joiner character at third level, zero-width joiner at fourth level"), "nbsp:zwnj3zwj4");
			items.append (item);

			item = new Item (_("Adding Esperanto circumflexes (supersigno)"), "esperanto", false);
			item.set (_("To the corresponding key in a Qwerty keyboard"), "esperanto:qwerty");
			item.set (_("To the corresponding key in a Dvorak keyboard"), "esperanto:dvorak");
			item.set (_("To the corresponding key in a Colemak layout"), "esperanto:colemak");
			items.append (item);

			item = new Item (_("Key sequence to kill the X server"), "terminate", true);
			item.set (_("Control + Alt + Backspace"), "terminate:ctrl_alt_bksp");
			items.append (item);
		}
	}
}
