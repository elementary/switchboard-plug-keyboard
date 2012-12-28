all: keyboard keyboard.plug
	cp keyboard      /usr/lib/plugs/pantheon/keyboard/
	cp keyboard.plug /usr/lib/plugs/pantheon/keyboard/

keyboard: keyboard.vala
	valac --pkg gtk+-3.0 --pkg granite --pkg pantheon keyboard.vala

uninstall:
	rm -R /usr/lib/plugs/pantheon/keyboard/
