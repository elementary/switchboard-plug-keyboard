/*
* Copyright 2017-2022 elementary, Inc. (https://elementary.io)
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

public class Pantheon.Keyboard.Behaviour.Page : Gtk.Grid {
    private Settings gsettings_blink;
    private Settings gsettings_repeat;

    construct {
        var label_repeat = new Granite.HeaderLabel (_("Repeat Keys:")) {
            halign = Gtk.Align.END
        };

        var label_repeat_delay = new Gtk.Label (_("Delay:")) {
            halign = Gtk.Align.END
        };

        var label_repeat_speed = new Gtk.Label (_("Interval:")) {
            halign = Gtk.Align.END
        };

        var label_repeat_ms1 = new Gtk.Label (_("milliseconds")) {
            halign = Gtk.Align.START
        };

        var label_repeat_ms2 = new Gtk.Label (_("milliseconds")) {
            halign = Gtk.Align.START
        };

        var switch_repeat = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };

        var repeat_delay_adjustment = new Gtk.Adjustment (-1, 100, 900, 1, 0, 0);

        var scale_repeat_delay = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, repeat_delay_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_repeat_delay.add_mark (500, Gtk.PositionType.BOTTOM, null);

        var repeat_speed_adjustment = new Gtk.Adjustment (-1, 10, 70, 1, 0, 0);

        var scale_repeat_speed = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, repeat_speed_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_repeat_speed.add_mark (30, Gtk.PositionType.BOTTOM, null);
        scale_repeat_speed.add_mark (50, Gtk.PositionType.BOTTOM, null);

        var spin_repeat_delay = new Gtk.SpinButton.with_range (100, 900, 1);

        var spin_repeat_speed = new Gtk.SpinButton.with_range (10, 70, 1);

        var label_blink = new Granite.HeaderLabel (_("Cursor Blinking:")) {
            halign = Gtk.Align.END,
            margin_top = 24
        };

        var label_blink_speed = new Gtk.Label (_("Speed:")) {
            halign = Gtk.Align.END
        };

        var label_blink_time = new Gtk.Label (_("Duration:")) {
            halign = Gtk.Align.END
        };

        var label_blink_ms = new Gtk.Label (_("milliseconds")) {
            halign = Gtk.Align.START
        };

        var label_blink_s = new Gtk.Label (_("seconds")) {
            halign = Gtk.Align.START
        };

        var switch_blink = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER,
            margin_top = 24
        };

        var blink_speed_adjustment = new Gtk.Adjustment (-1, 100, 2500, 10, 0, 0);

        var scale_blink_speed = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, blink_speed_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_blink_speed.add_mark (1200, Gtk.PositionType.BOTTOM, null);

        var blink_time_adjustment = new Gtk.Adjustment (-1, 1, 29, 1, 0, 0);

        var scale_blink_time = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, blink_time_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_blink_time.add_mark (10, Gtk.PositionType.BOTTOM, null);
        scale_blink_time.add_mark (20, Gtk.PositionType.BOTTOM, null);

        var spin_blink_speed = new Gtk.SpinButton.with_range (100, 2500, 10);

        var spin_blink_time = new Gtk.SpinButton.with_range (1, 29, 1);

        var entry_test = new Gtk.Entry () {
            margin_top = 24,
            hexpand = true,
            placeholder_text = (_("Type to test your settings"))
        };

        column_spacing = 12;
        row_spacing = 12;
        attach (label_repeat, 0, 0);
        attach (switch_repeat, 1, 0);
        attach (label_repeat_delay, 0, 1);
        attach (scale_repeat_delay, 1, 1);
        attach (spin_repeat_delay, 2, 1);
        attach (label_repeat_ms1, 3, 1);
        attach (label_repeat_speed, 0, 2);
        attach (scale_repeat_speed, 1, 2);
        attach (spin_repeat_speed, 2, 2);
        attach (label_repeat_ms2, 3, 2);
        attach (label_blink, 0, 3);
        attach (switch_blink, 1, 3);
        attach (label_blink_speed, 0, 4);
        attach (scale_blink_speed, 1, 4);
        attach (spin_blink_speed, 2, 4);
        attach (label_blink_ms, 3, 4);
        attach (label_blink_time, 0, 5);
        attach (scale_blink_time, 1, 5);
        attach (spin_blink_time, 2, 5);
        attach (label_blink_s, 3, 5);
        attach (entry_test, 1, 6);

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
}
