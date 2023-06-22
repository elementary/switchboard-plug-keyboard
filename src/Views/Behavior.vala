/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 elementary, Inc. (https://elementary.io)
 */

public class Pantheon.Keyboard.Behaviour.Page : Gtk.Box {
    construct {
        var label_repeat = new Granite.HeaderLabel (_("Repeat Keys"));

        var label_repeat_delay = new Gtk.Label (_("Delay:")) {
            halign = Gtk.Align.END
        };

        var label_repeat_speed = new Gtk.Label (_("Interval:")) {
            halign = Gtk.Align.END
        };

        var switch_repeat = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };

        var repeat_delay_adjustment = new Gtk.Adjustment (-1, 100, 900, 1, 0, 0);

        var scale_repeat_delay = new Gtk.Scale (HORIZONTAL, repeat_delay_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_repeat_delay.add_mark (500, Gtk.PositionType.BOTTOM, null);

        var repeat_speed_adjustment = new Gtk.Adjustment (-1, 10, 70, 1, 0, 0);

        var scale_repeat_speed = new Gtk.Scale (HORIZONTAL, repeat_speed_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_repeat_speed.add_mark (30, Gtk.PositionType.BOTTOM, null);
        scale_repeat_speed.add_mark (50, Gtk.PositionType.BOTTOM, null);

        var label_blink = new Granite.HeaderLabel (_("Cursor Blinking"));

        var label_blink_speed = new Gtk.Label (_("Speed:")) {
            halign = Gtk.Align.END
        };

        var label_blink_time = new Gtk.Label (_("Duration:")) {
            halign = Gtk.Align.END
        };

        var switch_blink = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };

        var blink_speed_adjustment = new Gtk.Adjustment (-1, 100, 2500, 10, 0, 0);

        var scale_blink_speed = new Gtk.Scale (HORIZONTAL, blink_speed_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_blink_speed.add_mark (1200, Gtk.PositionType.BOTTOM, null);

        var blink_time_adjustment = new Gtk.Adjustment (-1, 1, 29, 1, 0, 0);

        var scale_blink_time = new Gtk.Scale (HORIZONTAL, blink_time_adjustment) {
            draw_value = false,
            hexpand = true
        };
        scale_blink_time.add_mark (10, Gtk.PositionType.BOTTOM, null);
        scale_blink_time.add_mark (20, Gtk.PositionType.BOTTOM, null);

        var entry_test = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("Type to test your settings")
        };

        var repeat_grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        repeat_grid.attach (label_repeat, 0, 0);
        repeat_grid.attach (switch_repeat, 1, 0);
        repeat_grid.attach (label_repeat_delay, 0, 1);
        repeat_grid.attach (scale_repeat_delay, 1, 1);
        repeat_grid.attach (label_repeat_speed, 0, 2);
        repeat_grid.attach (scale_repeat_speed, 1, 2);

        var blink_grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        blink_grid.attach (label_blink, 0, 3);
        blink_grid.attach (switch_blink, 1, 3);
        blink_grid.attach (label_blink_speed, 0, 4);
        blink_grid.attach (scale_blink_speed, 1, 4);
        blink_grid.attach (label_blink_time, 0, 5);
        blink_grid.attach (scale_blink_time, 1, 5);

        var box = new Gtk.Box (VERTICAL, 24);
        box.add (repeat_grid);
        box.add (blink_grid);
        box.add (entry_test);

        var clamp = new Hdy.Clamp () {
            child = box
        };

        add (clamp);

        var gsettings_blink = new Settings ("org.gnome.desktop.interface");
        gsettings_blink.bind ("cursor-blink", switch_blink, "active", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-time", blink_speed_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-timeout", blink_time_adjustment, "value", SettingsBindFlags.DEFAULT);

        var gsettings_repeat = new Settings ("org.gnome.desktop.peripherals.keyboard");
        gsettings_repeat.bind ("repeat", switch_repeat, "active", SettingsBindFlags.DEFAULT);
        gsettings_repeat.bind ("delay", repeat_delay_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_repeat.bind ("repeat-interval", repeat_speed_adjustment, "value", SettingsBindFlags.DEFAULT);

        switch_blink.bind_property ("active", label_blink_speed, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", label_blink_time, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", scale_blink_speed, "sensitive", BindingFlags.DEFAULT);
        switch_blink.bind_property ("active", scale_blink_time, "sensitive", BindingFlags.DEFAULT);

        switch_repeat.bind_property ("active", label_repeat_delay, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", label_repeat_speed, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", scale_repeat_delay, "sensitive", BindingFlags.DEFAULT);
        switch_repeat.bind_property ("active", scale_repeat_speed, "sensitive", BindingFlags.DEFAULT);

        scale_repeat_delay.grab_focus (); /* We want entry unfocussed so that placeholder shows */
    }
}
