/* libgnomekbd.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Gkbd", gir_namespace = "Gkbd", gir_version = "3.0", lower_case_cprefix = "gkbd_")]
namespace Gkbd {
	[CCode (cheader_filename = "libgnomekbd/gkbd-configuration.h", type_id = "gkbd_configuration_get_type ()")]
	public class Configuration : GLib.Object {
		[CCode (has_construct_function = false)]
		protected Configuration ();
		public void append_object (GLib.Object obj);
		public static string create_label_title (int group, GLib.HashTable<void*,void*> ln2cnt_map, string layout_name);
		public string extract_layout_name (int group);
		public void free_images (GLib.SList<Gdk.Pixbuf> images);
		public static Gkbd.Configuration @get ();
		public unowned GLib.SList<GLib.Object> get_all_objects ();
		public bool get_caps_lock_state ();
		public uint get_current_group ();
		public string get_current_tooltip ();
		public string get_group_name (uint group);
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_group_names ();
		public string get_image_filename (uint group);
		public unowned Gkbd.IndicatorConfig? get_indicator_config ();
		public unowned Gkbd.KeyboardConfig? get_keyboard_config ();
		public bool get_num_lock_state ();
		public bool get_scroll_lock_state ();
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_short_group_names ();
		public unowned Xkl.Engine get_xkl_engine ();
		public bool if_any_object_exists ();
		public bool if_flags_shown ();
		public GLib.SList<Gdk.Pixbuf> load_images ();
		public void lock_group (uint group);
		public void lock_next_group ();
		public void remove_object (GLib.Object obj);
		public void start_listen ();
		public void stop_listen ();
		public signal void changed ();
		public signal void group_changed (int object);
		public signal void indicators_changed ();
	}
	[CCode (cheader_filename = "libgnomekbd/gkbd-indicator.h", type_id = "gkbd_indicator_get_type ()")]
	public class Indicator : Gtk.Notebook, Atk.Implementor, Gtk.Buildable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public Indicator ();
		[CCode (array_length = false, array_null_terminated = true)]
		public static unowned string[] get_group_names ();
		public static string get_image_filename (uint group);
		public static double get_max_width_height_ratio ();
		public static unowned Xkl.Engine get_xkl_engine ();
		public void set_angle (double angle);
		public void set_parent_tooltips (bool ifset);
		[HasEmitter]
		public virtual signal void reinit_ui ();
	}
	[CCode (cheader_filename = "libgnomekbd/gkbd-keyboard-drawing.h", type_id = "gkbd_keyboard_drawing_get_type ()")]
	public class KeyboardDrawing : Gtk.DrawingArea, Atk.Implementor, Gtk.Buildable {
		[CCode (has_construct_function = false, type = "GtkWidget*")]
		public KeyboardDrawing ();
		[CCode (cname = "gkbd_keyboard_drawing_dialog_new", has_construct_function = false, type = "GtkWidget*")]
		public KeyboardDrawing.dialog_new ();
		public static void dialog_set_group (Gtk.Widget dialog, Xkl.ConfigRegistry registry, int group);
		public static void dialog_set_layout (Gtk.Widget dialog, Xkl.ConfigRegistry registry, string layout);
		public unowned string get_compat ();
		public unowned string get_geometry ();
		public unowned string get_keycodes ();
		public unowned string get_symbols ();
		public unowned string get_types ();
		public void print (Gtk.Window parent_window, string description);
		public bool render (Cairo.Context cr, Pango.Layout layout, double x, double y, double width, double height, double dpi_x, double dpi_y);
		public void set_groups_levels (Gkbd.KeyboardDrawingGroupLevel groupLevels);
		public void set_layout (string id);
		public void set_track_config (bool enable);
		public void set_track_modifiers (bool enable);
		public virtual signal void bad_keycode (uint keycode);
	}
	[CCode (cheader_filename = "libgnomekbd/gkbd-status.h", type_id = "gkbd_status_get_type ()")]
	public class Status : Gtk.StatusIcon {
		[CCode (has_construct_function = false, type = "GtkStatusIcon*")]
		public Status ();
		[CCode (array_length = false, array_null_terminated = true)]
		public static unowned string[] get_group_names ();
		public static string get_image_filename (uint group);
		public static unowned Xkl.Engine get_xkl_engine ();
		public void reinit_ui ();
	}
	[CCode (cheader_filename = "libgnomekbd/gkbd-desktop-config.h", has_type_id = false)]
	public struct DesktopConfig {
		public int default_group;
		public bool group_per_app;
		public bool handle_indicators;
		public bool layout_names_as_group_names;
		public bool load_extra_items;
		public weak GLib.Settings settings;
		public int config_listener_id;
		public weak Xkl.Engine engine;
		public bool activate ();
		public void init (Xkl.Engine engine);
		public void load ();
		public bool load_group_descriptions (Xkl.ConfigRegistry registry, string layout_ids, string variant_ids, string short_group_names, string full_group_names);
		public void lock_next_group ();
		public void lock_prev_group ();
		public void restore_group ();
		public void save ();
		public void start_listen (GLib.Callback func);
		public void stop_listen ();
		public void term ();
	}
	[CCode (cheader_filename = "libgnomekbd/gkbd-indicator-config.h", has_type_id = false)]
	public struct IndicatorConfig {
		public int secondary_groups_mask;
		public bool show_flags;
		public weak string font_family;
		public int font_size;
		public weak string foreground_color;
		public weak string background_color;
		public weak GLib.Settings settings;
		public weak GLib.SList<void*> image_filenames;
		public weak Gtk.IconTheme icon_theme;
		public int config_listener_id;
		public weak Xkl.Engine engine;
		public void activate ();
		public void free_image_filenames ();
		public string get_fg_color_for_widget (Gtk.Widget widget);
		public void get_font_for_widget (Gtk.Widget widget, string font_family, int font_size);
		public string get_images_file (Gkbd.KeyboardConfig kbd_config, int group);
		public void init (Xkl.Engine engine);
		public void load ();
		public void load_image_filenames (Gkbd.KeyboardConfig kbd_config);
		public void refresh_style ();
		public void save ();
		public void start_listen (GLib.Callback func);
		public void stop_listen ();
		public void term ();
	}
	[CCode (cheader_filename = "libgnomekbd/gkbd-keyboard-config.h", has_type_id = false)]
	public struct KeyboardConfig {
		public weak string model;
		public weak string layouts_variants;
		public weak string options;
		public weak GLib.Settings settings;
		public int config_listener_id;
		public weak Xkl.Engine engine;
		public bool activate ();
		[CCode (array_length = false, array_null_terminated = true)]
		public static string[] add_default_switch_option_if_necessary (string layouts_list, string options_list, bool was_appended);
		public bool equals (Gkbd.KeyboardConfig kbd_config2);
		public static unowned string format_full_description (string layout_descr, string variant_descr);
		public static bool get_descriptions (Xkl.ConfigRegistry config_registry, string name, string layout_short_descr, string layout_descr, string variant_short_descr, string variant_descr);
		public void init (Xkl.Engine engine);
		public void load (Gkbd.KeyboardConfig kbd_config_default);
		public void load_from_x_current (Xkl.ConfigRec buf);
		public void load_from_x_initial (Xkl.ConfigRec buf);
		public static unowned string merge_items (string parent, string child);
		public void save ();
		public static bool split_items (string merged, string parent, string child);
		public void start_listen (GLib.Callback func);
		public void stop_listen ();
		public void term ();
		public string to_string ();
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", has_type_id = false)]
	public struct KeyboardDrawingDoodad {
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", has_type_id = false)]
	public struct KeyboardDrawingGroupLevel {
		public int group;
		public int level;
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", has_type_id = false)]
	public struct KeyboardDrawingItem {
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", has_type_id = false)]
	public struct KeyboardDrawingKey {
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", has_type_id = false)]
	public struct KeyboardDrawingRenderContext {
		public weak Cairo.Context cr;
		public int angle;
		public weak Pango.Layout layout;
		public weak Pango.FontDescription font_desc;
		public int scale_numerator;
		public int scale_denominator;
		public Gdk.RGBA dark_color;
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", cprefix = "GKBD_KEYBOARD_DRAWING_POS_", has_type_id = false)]
	public enum KeyboardDrawingGroupLevelPosition {
		TOPLEFT,
		TOPRIGHT,
		BOTTOMLEFT,
		BOTTOMRIGHT,
		TOTAL,
		FIRST,
		LAST
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", cprefix = "GKBD_KEYBOARD_DRAWING_ITEM_TYPE_", has_type_id = false)]
	public enum KeyboardDrawingItemType {
		INVALID,
		KEY,
		KEY_EXTRA,
		DOODAD
	}
	[CCode (cheader_filename = "Gkbd-3.0.h", cname = "GKBD_DESKTOP_SCHEMA")]
	public const string DESKTOP_SCHEMA;
	[CCode (cheader_filename = "Gkbd-3.0.h", cname = "GKBD_KEYBOARD_DRAWING_H")]
	public const int KEYBOARD_DRAWING_H;
	[CCode (cheader_filename = "Gkbd-3.0.h", cname = "GKBD_KEYBOARD_SCHEMA")]
	public const string KEYBOARD_SCHEMA;
	[CCode (cheader_filename = "Gkbd-3.0.h")]
	public static void install_glib_log_appender ();
	[CCode (cheader_filename = "Gkbd-3.0.h")]
	public static Gdk.Rectangle? preview_load_position ();
	[CCode (cheader_filename = "Gkbd-3.0.h")]
	public static void preview_save_position (Gdk.Rectangle rect);
	[CCode (array_length = false, array_null_terminated = true, cheader_filename = "Gkbd-3.0.h")]
	public static string[] strv_append (string arr, string element);
	[CCode (cheader_filename = "Gkbd-3.0.h")]
	public static void strv_behead (string arr);
	[CCode (cheader_filename = "Gkbd-3.0.h")]
	public static bool strv_remove (string arr, string element);
}

