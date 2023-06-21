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

        var spin_repeat_delay = new Gtk.SpinButton.with_range (100, 900, 1);

        var spin_repeat_speed = new Gtk.SpinButton.with_range (10, 70, 1);

        var label_blink = new Granite.HeaderLabel (_("Cursor Blinking"));

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

        var spin_blink_speed = new Gtk.SpinButton.with_range (100, 2500, 10);

        var spin_blink_time = new Gtk.SpinButton.with_range (1, 29, 1);

        var sticky_keys_header = new Granite.HeaderLabel (_("Sticky Keys"));

        var sticky_keys_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true,
            valign = CENTER
        };

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var sticky_keys_subtitle = new Gtk.Label (
            _("Use Alt, Ctrl, or Shift keys in sequence")
        ) {
            wrap = true,
            xalign = 0
        };
        sticky_keys_subtitle .get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var sticky_keys_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        sticky_keys_grid.attach (sticky_keys_header, 0, 0);
        sticky_keys_grid.attach (sticky_keys_subtitle, 0, 1);
        sticky_keys_grid.attach (sticky_keys_switch, 1, 0, 1, 2);

        var slow_keys_header = new Granite.HeaderLabel (_("Slow Keys"));

        var slow_keys_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true,
            valign = CENTER
        };

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var slow_keys_subtitle = new Gtk.Label (
            _("Delay between key presses")
        ) {
            wrap = true,
            xalign = 0
        };
        slow_keys_subtitle .get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var slow_keys_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        slow_keys_grid.attach (slow_keys_header, 0, 0);
        slow_keys_grid.attach (slow_keys_subtitle, 0, 1);
        slow_keys_grid.attach (slow_keys_switch, 1, 0, 1, 2);

        var bounce_keys_header = new Granite.HeaderLabel (_("Bounce Keys"));

        var bounce_keys_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true,
            valign = CENTER
        };

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var bounce_keys_subtitle = new Gtk.Label (
            _("Ignore fast duplicate keypresses ")
        ) {
            wrap = true,
            xalign = 0
        };
        bounce_keys_subtitle .get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var bounce_keys_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        bounce_keys_grid.attach (bounce_keys_header, 0, 0);
        bounce_keys_grid.attach (bounce_keys_subtitle, 0, 1);
        bounce_keys_grid.attach (bounce_keys_switch, 1, 0, 1, 2);

        var events_header = new Granite.HeaderLabel (_("Event alerts"));

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var events_subtitle = new Gtk.Label (
            _("Play a sound or flash the screen. %s").printf (
                "<a href='settings:///sound/output'>%s</a>".printf (
                    _("Sound Settings…")
                )
            )
        ) {
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        events_subtitle.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var lock_check = new Gtk.CheckButton.with_label (_("Caps Lock ⇪ or Num Lock keys are pressed"));
        var bounce_keys_check = new Gtk.CheckButton.with_label (_("Bounce Keys are rejected"));
        var sticky_keys_check = new Gtk.CheckButton.with_label (_("Sticky Keys are pressed"));
        var slow_keys_check = new Gtk.CheckButton.with_label (_("Slow Keys are rejected"));

        var events_checks_box = new Gtk.Box (VERTICAL, 6) {
            margin_top = 12
        };
        events_checks_box.add (lock_check);
        events_checks_box.add (bounce_keys_check);
        events_checks_box.add (sticky_keys_check);
        events_checks_box.add (slow_keys_check);

        var events_box = new Gtk.Box (VERTICAL, 0);
        events_box.add (events_header);
        events_box.add (events_subtitle);
        events_box.add (events_checks_box);

        // var delay_label = new Granite.HeaderLabel (_("Typing Delays"));
        // var typing_label = new Granite.HeaderLabel (_("Fast Typing"));

        // var sk_delay_adjustment = new Gtk.Adjustment (0, 0, 2001, 1, 1, 1);
        // var bk_delay_adjustment = new Gtk.Adjustment (0, 0, 2001, 1, 1, 1);

        // var sk_delay = delay_box.add_scale (_("Delay length"), sk_delay_adjustment);

        // var bk_delay = typing_box.add_scale (_("Delay length"), bk_delay_adjustment);

        // Accessibility.Plug.keyboard_settings.bind ("slowkeys-beep-press", sk_pressed, "active", SettingsBindFlags.DEFAULT);
        // Accessibility.Plug.keyboard_settings.bind ("slowkeys-beep-accept", sk_accepted, "active", SettingsBindFlags.DEFAULT);
        // Accessibility.Plug.keyboard_settings.bind ("slowkeys-delay", sk_delay_adjustment, "value", SettingsBindFlags.DEFAULT);

        // Accessibility.Plug.keyboard_settings.bind ("bouncekeys-delay", bk_delay_adjustment, "value", SettingsBindFlags.DEFAULT);

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
        repeat_grid.attach (spin_repeat_delay, 2, 1);
        repeat_grid.attach (label_repeat_ms1, 3, 1);
        repeat_grid.attach (label_repeat_speed, 0, 2);
        repeat_grid.attach (scale_repeat_speed, 1, 2);
        repeat_grid.attach (spin_repeat_speed, 2, 2);
        repeat_grid.attach (label_repeat_ms2, 3, 2);

        var blink_grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        blink_grid.attach (label_blink, 0, 3);
        blink_grid.attach (switch_blink, 1, 3);
        blink_grid.attach (label_blink_speed, 0, 4);
        blink_grid.attach (scale_blink_speed, 1, 4);
        blink_grid.attach (spin_blink_speed, 2, 4);
        blink_grid.attach (label_blink_ms, 3, 4);
        blink_grid.attach (label_blink_time, 0, 5);
        blink_grid.attach (scale_blink_time, 1, 5);
        blink_grid.attach (spin_blink_time, 2, 5);
        blink_grid.attach (label_blink_s, 3, 5);

        var box = new Gtk.Box (VERTICAL, 24);
        box.add (repeat_grid);
        box.add (blink_grid);
        box.add (bounce_keys_grid);
        box.add (sticky_keys_grid);
        box.add (slow_keys_grid);
        box.add (events_box);
        box.add (entry_test);

        var clamp = new Hdy.Clamp () {
            child = box
        };

        add (clamp);

        var gsettings_blink = new Settings ("org.gnome.desktop.interface");
        gsettings_blink.bind ("cursor-blink", switch_blink, "active", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-time", blink_speed_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-time", spin_blink_speed, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-timeout", blink_time_adjustment, "value", SettingsBindFlags.DEFAULT);
        gsettings_blink.bind ("cursor-blink-timeout", spin_blink_time, "value", SettingsBindFlags.DEFAULT);

        var gsettings_repeat = new Settings ("org.gnome.desktop.peripherals.keyboard");
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

        var a11y_settings = new Settings ("org.gnome.desktop.a11y.keyboard");
        a11y_settings.bind ("bouncekeys-enable", bounce_keys_switch, "active", DEFAULT);
        a11y_settings.bind ("bouncekeys-enable", bounce_keys_check, "sensitive", GET);
        a11y_settings.bind ("bouncekeys-beep-reject", bounce_keys_check, "active", DEFAULT);

        a11y_settings.bind ("slowkeys-enable", slow_keys_switch, "active", DEFAULT);
        a11y_settings.bind ("slowkeys-enable", slow_keys_check, "sensitive", GET);
        a11y_settings.bind ("slowkeys-beep-reject", slow_keys_check, "active", DEFAULT);

        a11y_settings.bind ("stickykeys-enable", sticky_keys_switch, "active", DEFAULT);
        a11y_settings.bind ("stickykeys-enable", sticky_keys_check, "sensitive", GET);
        a11y_settings.bind ("stickykeys-modifier-beep", sticky_keys_check, "active", DEFAULT);

        a11y_settings.bind ("togglekeys-enable", lock_check, "active", DEFAULT);

        scale_repeat_delay.grab_focus (); /* We want entry unfocussed so that placeholder shows */
    }
}
