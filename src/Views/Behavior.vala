/*
* Copyright 2017-2019 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class Pantheon.Keyboard.Behaviour.Page : Pantheon.Keyboard.AbstractPage {
    private Settings gsettings_blink;
    private Settings gsettings_repeat;

    construct {
        var label_repeat = new Granite.HeaderLabel (_("Repeat Keys:"));
        label_repeat.halign = Gtk.Align.END;

        var label_repeat_delay = new Gtk.Label (_("Delay:"));
        label_repeat_delay.halign = Gtk.Align.END;

        var label_repeat_speed = new Gtk.Label (_("Interval:"));
        label_repeat_speed.halign = Gtk.Align.END;

        var label_repeat_ms1 = new Gtk.Label (_("milliseconds"));
        label_repeat_ms1.halign = Gtk.Align.START;

        var label_repeat_ms2 = new Gtk.Label (_("milliseconds"));
        label_repeat_ms2.halign = Gtk.Align.START;

        var switch_repeat = new Gtk.Switch ();
        switch_repeat.halign = Gtk.Align.START;
        switch_repeat.valign = Gtk.Align.CENTER;

        var repeat_delay_adjustment = new Gtk.Adjustment (-1, 100, 900, 1, 0, 0);

        var scale_repeat_delay = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, repeat_delay_adjustment);
        scale_repeat_delay.draw_value = false;
        scale_repeat_delay.hexpand = true;
        scale_repeat_delay.add_mark (500, Gtk.PositionType.BOTTOM, null);

        var repeat_speed_adjustment = new Gtk.Adjustment (-1, 10, 70, 1, 0, 0);

        var scale_repeat_speed = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, repeat_speed_adjustment);
        scale_repeat_speed.draw_value = false;
        scale_repeat_speed.hexpand = true;
        scale_repeat_speed.add_mark (30, Gtk.PositionType.BOTTOM, null);
        scale_repeat_speed.add_mark (50, Gtk.PositionType.BOTTOM, null);

        var spin_repeat_delay = new Gtk.SpinButton.with_range (100, 900, 1);

        var spin_repeat_speed = new Gtk.SpinButton.with_range (10, 70, 1);

        var label_blink = new Granite.HeaderLabel (_("Cursor Blinking:"));
        label_blink.halign = Gtk.Align.END;
        label_blink.margin_top = 24;

        var label_blink_speed = new Gtk.Label (_("Speed:"));
        label_blink_speed.halign = Gtk.Align.END;

        var label_blink_time = new Gtk.Label (_("Duration:"));
        label_blink_time.halign = Gtk.Align.END;

        var label_blink_ms = new Gtk.Label (_("milliseconds"));
        label_blink_ms.halign = Gtk.Align.START;

        var label_blink_s = new Gtk.Label (_("seconds"));
        label_blink_s.halign = Gtk.Align.START;

        var switch_blink = new Gtk.Switch ();
        switch_blink.halign = Gtk.Align.START;
        switch_blink.valign = Gtk.Align.CENTER;
        switch_blink.margin_top = 24;

        var blink_speed_adjustment = new Gtk.Adjustment (-1, 100, 2300, 10, 0, 0);

        var scale_blink_speed = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, blink_speed_adjustment);
        scale_blink_speed.draw_value = false;
        scale_blink_speed.hexpand = true;
        scale_blink_speed.add_mark (1200, Gtk.PositionType.BOTTOM, null);

        var blink_time_adjustment = new Gtk.Adjustment (-1, 1, 29, 1, 0, 0);

        var scale_blink_time = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, blink_time_adjustment);
        scale_blink_time.draw_value = false;
        scale_blink_time.hexpand = true;
        scale_blink_time.add_mark (10, Gtk.PositionType.BOTTOM, null);
        scale_blink_time.add_mark (20, Gtk.PositionType.BOTTOM, null);

        var spin_blink_speed = new Gtk.SpinButton.with_range (100, 2500, 10);

        var spin_blink_time = new Gtk.SpinButton.with_range (1, 29, 1);

        var entry_test = new Gtk.Entry ();
        entry_test.margin_top = 24;
        entry_test.placeholder_text = (_("Type to test your settings"));
        entry_test.hexpand = true;

        attach (label_repeat, 0, 0, 1, 1);
        attach (switch_repeat, 1, 0, 1, 1);
        attach (label_repeat_delay, 0, 1, 1, 1);
        attach (scale_repeat_delay, 1, 1, 1, 1);
        attach (spin_repeat_delay, 2, 1, 1, 1);
        attach (label_repeat_ms1, 3, 1, 1, 1);
        attach (label_repeat_speed, 0, 2, 1, 1);
        attach (scale_repeat_speed, 1, 2, 1, 1);
        attach (spin_repeat_speed, 2, 2, 1, 1);
        attach (label_repeat_ms2, 3, 2, 1, 1);
        attach (label_blink, 0, 3, 1, 1);
        attach (switch_blink, 1, 3, 1, 1);
        attach (label_blink_speed, 0, 4, 1, 1);
        attach (scale_blink_speed, 1, 4, 1, 1);
        attach (spin_blink_speed, 2, 4, 1, 1);
        attach (label_blink_ms, 3, 4, 1, 1);
        attach (label_blink_time, 0, 5, 1, 1);
        attach (scale_blink_time, 1, 5, 1, 1);
        attach (spin_blink_time, 2, 5, 1, 1);
        attach (label_blink_s, 3, 5, 1, 1);
        attach (entry_test, 1, 6, 1, 1);

        gsettings_blink = new Settings ("org.gnome.desktop.interface");
        gsettings_blink.bind ("cursor-blink", switch_blink, "active", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-time", blink_speed_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-time", spin_blink_speed, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-timeout", blink_time_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-timeout", spin_blink_time, "value", SettingsBindFlags.DEFAULT);

        gsettings_repeat = new Settings ("org.gnome.desktop.peripherals.keyboard");
        gsettings_repeat.bind ("repeat", switch_repeat, "active", SettingsBindFlags.DEFAULT);
        gsettings_repeat.bind ("delay", repeat_delay_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_repeat.bind ("delay", spin_repeat_delay, "value", SettingsBindFlags.DEFAULT);
        gsettings_repeat.bind ("repeat-interval", repeat_speed_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_repeat.bind ("repeat-interval", spin_repeat_speed, "value", SettingsBindFlags.DEFAULT);

        switch_blink.bind_property ("active", label_blink_speed, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", label_blink_time, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", scale_blink_speed, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", scale_blink_time, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", spin_blink_speed, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", spin_blink_time, "sensitive", BindingFlags.DEFAULT);

        switch_repeat.bind_property ("active", label_repeat_delay, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", label_repeat_speed, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", scale_repeat_delay, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", scale_repeat_speed, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", spin_repeat_delay, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", spin_repeat_speed, "sensitive", BindingFlags.DEFAULT);

        scale_repeat_delay.grab_focus (); /* We want entry unfocussed so that placeholder shows */
    }

    public override void reset () {
        gsettings_blink.reset ("cursor-blink");
        gsettings_blink.reset ("cursor-blink-time");
        gsettings_blink.reset ("cursor-blink-timeout");

        gsettings_repeat.reset ("delay");
        gsettings_repeat.reset ("repeat");
        gsettings_repeat.reset ("repeat-interval");

        return;
    }
}
