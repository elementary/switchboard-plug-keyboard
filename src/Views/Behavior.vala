/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 elementary, Inc. (https://elementary.io)
 */

public class Keyboard.Behaviour.Page : Gtk.Box {
    construct {
        var onscreen_keyboard_header = new Granite.HeaderLabel (_("Show On-screen Keyboard"));

        var onscreen_keyboard_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };

        var onscreen_keyboard_settings = new Gtk.LinkButton.with_label ("", _("On-screen keyboard settings…")) {
            halign = Gtk.Align.START,
            has_tooltip = false
        };

        var onscreen_keyboard_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        onscreen_keyboard_grid.attach (onscreen_keyboard_header, 0, 0);
        onscreen_keyboard_grid.attach (onscreen_keyboard_settings, 0, 1);
        onscreen_keyboard_grid.attach (onscreen_keyboard_switch, 1, 0, 1, 2);

        var scale_provider = new Gtk.CssProvider ();
        scale_provider.load_from_resource ("/io/elementary/switchboard/keyboard/Behavior.css");

        var label_repeat = new Granite.HeaderLabel (_("Repeat Keys"));

        var label_repeat_delay = new Gtk.Label (_("Delay:")) {
            halign = Gtk.Align.END
        };

        var label_repeat_speed = new Gtk.Label (_("Interval:")) {
            halign = Gtk.Align.END
        };

        var switch_repeat = new Gtk.Switch () {
            halign = END,
            valign = CENTER
        };

        var repeat_delay_adjustment = new Gtk.Adjustment (-1, 100, 900, 1, 0, 0);

        var scale_repeat_delay = new Gtk.Scale (HORIZONTAL, repeat_delay_adjustment) {
            digits = 0,
            hexpand = true
        };
        scale_repeat_delay.add_mark (500, Gtk.PositionType.BOTTOM, null);
        scale_repeat_delay.get_style_context ().add_provider (scale_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var repeat_speed_adjustment = new Gtk.Adjustment (-1, 10, 70, 1, 0, 0);

        var scale_repeat_speed = new Gtk.Scale (HORIZONTAL, repeat_speed_adjustment) {
            digits = 0,
            hexpand = true
        };
        scale_repeat_speed.add_mark (30, Gtk.PositionType.BOTTOM, null);
        scale_repeat_speed.add_mark (50, Gtk.PositionType.BOTTOM, null);
        scale_repeat_speed.get_style_context ().add_provider (scale_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var label_blink = new Granite.HeaderLabel (_("Cursor Blinking"));

        var label_blink_speed = new Gtk.Label (_("Speed:")) {
            halign = Gtk.Align.END
        };

        var label_blink_time = new Gtk.Label (_("Duration:")) {
            halign = Gtk.Align.END
        };

        var switch_blink = new Gtk.Switch () {
            halign = END,
            valign = CENTER
        };

        var blink_speed_adjustment = new Gtk.Adjustment (-1, 100, 2500, 10, 0, 0);

        var scale_blink_speed = new Gtk.Scale (HORIZONTAL, blink_speed_adjustment) {
            digits = 0,
            hexpand = true
        };
        scale_blink_speed.add_mark (1200, Gtk.PositionType.BOTTOM, null);
        scale_blink_speed.get_style_context ().add_provider (scale_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var blink_time_adjustment = new Gtk.Adjustment (-1, 1, 29, 1, 0, 0);

        var scale_blink_time = new Gtk.Scale (HORIZONTAL, blink_time_adjustment) {
            digits = 0,
            hexpand = true
        };
        scale_blink_time.add_mark (10, Gtk.PositionType.BOTTOM, null);
        scale_blink_time.add_mark (20, Gtk.PositionType.BOTTOM, null);
        scale_blink_time.get_style_context ().add_provider (scale_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var stickykeys_header = new Granite.HeaderLabel (_("Sticky Keys"));

        var stickykeys_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true,
            valign = CENTER
        };

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var stickykeys_subtitle = new Gtk.Label (
            _("Use ⌘, Alt, Ctrl, or Shift keys in sequence")
        ) {
            wrap = true,
            xalign = 0
        };
        stickykeys_subtitle .get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var stickykeys_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        stickykeys_grid.attach (stickykeys_header, 0, 0);
        stickykeys_grid.attach (stickykeys_subtitle, 0, 1);
        stickykeys_grid.attach (stickykeys_switch, 1, 0, 1, 2);

        var slowkeys_header = new Granite.HeaderLabel (_("Slow Keys"));

        var slowkeys_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true,
            valign = CENTER
        };

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var slowkeys_subtitle = new Gtk.Label (
            _("Don't accept keypresses unless held")
        ) {
            wrap = true,
            xalign = 0
        };
        slowkeys_subtitle .get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var slowkeys_adjustment = new Gtk.Adjustment (0, 0, 1000, 1, 1, 1);

        var slowkeys_scale = new Gtk.Scale (HORIZONTAL, slowkeys_adjustment) {
            digits = 0
        };
        slowkeys_scale.add_mark (300, Gtk.PositionType.BOTTOM, null);
        slowkeys_scale.get_style_context ().add_provider (scale_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var slowkeys_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        slowkeys_grid.attach (slowkeys_header, 0, 0);
        slowkeys_grid.attach (slowkeys_subtitle, 0, 1);
        slowkeys_grid.attach (slowkeys_switch, 1, 0, 1, 2);
        slowkeys_grid.attach (slowkeys_scale, 0, 2, 2);

        var bouncekeys_header = new Granite.HeaderLabel (_("Bounce Keys"));

        var bouncekeys_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true,
            valign = CENTER
        };

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var bouncekeys_subtitle = new Gtk.Label (
            _("Ignore fast duplicate keypresses")
        ) {
            wrap = true,
            xalign = 0
        };
        bouncekeys_subtitle .get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var bouncekeys_adjustment = new Gtk.Adjustment (0, 0, 1000, 1, 1, 1);

        var bouncekeys_scale = new Gtk.Scale (HORIZONTAL, bouncekeys_adjustment) {
            digits = 0
        };
        bouncekeys_scale.add_mark (300, Gtk.PositionType.BOTTOM, null);
        bouncekeys_scale.get_style_context ().add_provider (scale_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var bouncekeys_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        bouncekeys_grid.attach (bouncekeys_header, 0, 0);
        bouncekeys_grid.attach (bouncekeys_subtitle, 0, 1);
        bouncekeys_grid.attach (bouncekeys_switch, 1, 0, 1, 2);
        bouncekeys_grid.attach (bouncekeys_scale, 0, 2, 2);

        var events_header = new Granite.HeaderLabel (_("Event Alerts"));

        // FIXME: Replace with Granite.HeaderLabel secondary_text in Gtk4
        var events_subtitle = new Gtk.Label (
            _("Play a sound or flash the screen. %s").printf (
                "<a href='settings://sound/output'>%s</a>".printf (
                    _("Sound Settings…")
                )
            )
        ) {
            use_markup = true,
            wrap = true,
            xalign = 0
        };
        events_subtitle.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var togglekeys_check = new Gtk.CheckButton.with_label (_("Caps Lock ⇪ or Num Lock keys are pressed"));
        var bouncekeys_check = new Gtk.CheckButton.with_label (_("Bounce Keys are rejected"));
        var stickykeys_check = new Gtk.CheckButton.with_label (_("Sticky Keys are pressed"));
        var slowkeys_check = new Gtk.CheckButton.with_label (_("Slow Keys are rejected"));

        var events_checks_box = new Gtk.Box (VERTICAL, 6) {
            margin_top = 12
        };
        events_checks_box.add (togglekeys_check);
        events_checks_box.add (stickykeys_check);
        events_checks_box.add (bouncekeys_check);
        events_checks_box.add (slowkeys_check);

        var events_box = new Gtk.Box (VERTICAL, 0);
        events_box.add (events_header);
        events_box.add (events_subtitle);
        events_box.add (events_checks_box);

        var entry_test = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("Type to test your settings")
        };

        var repeat_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        repeat_grid.attach (label_repeat, 0, 0);
        repeat_grid.attach (switch_repeat, 1, 0);
        repeat_grid.attach (label_repeat_delay, 0, 1);
        repeat_grid.attach (scale_repeat_delay, 1, 1);
        repeat_grid.attach (label_repeat_speed, 0, 2);
        repeat_grid.attach (scale_repeat_speed, 1, 2);

        var blink_grid = new Gtk.Grid () {
            column_spacing = 12
        };
        blink_grid.attach (label_blink, 0, 0);
        blink_grid.attach (switch_blink, 1, 0);
        blink_grid.attach (label_blink_speed, 0, 1);
        blink_grid.attach (scale_blink_speed, 1, 1);
        blink_grid.attach (label_blink_time, 0, 2);
        blink_grid.attach (scale_blink_time, 1, 2);

        var box = new Gtk.Box (VERTICAL, 18);
        box.add (onscreen_keyboard_grid);
        box.add (blink_grid);
        box.add (repeat_grid);
        box.add (stickykeys_grid);
        box.add (bouncekeys_grid);
        box.add (slowkeys_grid);
        box.add (events_box);
        box.add (entry_test);

        var clamp = new Hdy.Clamp () {
            child = box,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };

        var scrolled = new Gtk.ScrolledWindow (null, null) {
            child = clamp
        };

        add (scrolled);

        onscreen_keyboard_settings.clicked.connect (() => {
            try {
                var appinfo = AppInfo.create_from_commandline ("onboard-settings", null, NONE);
                appinfo.launch (null, null);
            } catch (Error e) {
                critical ("Unable to launch onboard-settings: %s", e.message);
            }
        });

        var applications_settings = new Settings ("org.gnome.desktop.a11y.applications");
        applications_settings.bind ("screen-keyboard-enabled", onscreen_keyboard_switch, "active", DEFAULT);

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

        var a11y_settings = new Settings ("org.gnome.desktop.a11y.keyboard");
        a11y_settings.bind ("bouncekeys-enable", bouncekeys_switch, "active", DEFAULT);
        a11y_settings.bind ("bouncekeys-enable", bouncekeys_check, "sensitive", GET);
        a11y_settings.bind ("bouncekeys-enable", bouncekeys_scale, "sensitive", GET);
        a11y_settings.bind ("bouncekeys-beep-reject", bouncekeys_check, "active", DEFAULT);
        a11y_settings.bind ("bouncekeys-delay", bouncekeys_adjustment, "value", DEFAULT);

        a11y_settings.bind ("slowkeys-enable", slowkeys_switch, "active", DEFAULT);
        a11y_settings.bind ("slowkeys-enable", slowkeys_check, "sensitive", GET);
        a11y_settings.bind ("slowkeys-enable", slowkeys_scale, "sensitive", GET);
        a11y_settings.bind ("slowkeys-beep-reject", slowkeys_check, "active", DEFAULT);
        a11y_settings.bind ("slowkeys-delay", slowkeys_adjustment, "value", DEFAULT);

        a11y_settings.bind ("stickykeys-enable", stickykeys_switch, "active", DEFAULT);
        a11y_settings.bind ("stickykeys-enable", stickykeys_check, "sensitive", GET);
        a11y_settings.bind ("stickykeys-modifier-beep", stickykeys_check, "active", DEFAULT);

        a11y_settings.bind ("togglekeys-enable", togglekeys_check, "active", DEFAULT);

        scale_repeat_delay.grab_focus (); /* We want entry unfocussed so that placeholder shows */
    }
}
