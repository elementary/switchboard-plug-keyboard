xkbconf = dependency('xkeyboard-config')
xkb_base = xkbconf.get_pkgconfig_variable('xkb_base')

conf_data = configuration_data()
conf_data.set('XKB_BASE', xkb_base)
config_file = configure_file (
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

plug_files = files(
    'Plug.vala',
    'Widgets/Shortcuts/Tree.vala',
    'Widgets/Shortcuts/DisplayTree.vala',
    'Widgets/Shortcuts/CustomTree.vala',
    'Widgets/Layout/Display.vala',
    'Widgets/Layout/AddLayoutPopover.vala',
    'Views/Shortcuts.vala',
    'Views/Layout.vala',
    'Views/Behavior.vala',
    'Views/AbstractPage.vala',
    'Shortcuts/Shortcut.vala',
    'Shortcuts/Settings.vala',
    'Shortcuts/List.vala',
    'Shortcuts/CustomShortcutSettings.vala',
    'Layout/XkbModifier.vala',
    'Layout/Settings.vala',
    'Layout/Handler.vala',
    'Layout/AdvancedSettingsPanel.vala',
    'Layout/AdvancedSettingsGrid.vala',
    'Dialogs/ConflictDialog.vala'
)

switchboard_dep = dependency('switchboard-2.0')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

gnome_keyboard_ui_dep = meson.get_compiler('c').find_library('gnomekbdui')

shared_module(
    meson.project_name(),
    plug_files,
    config_file,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libxml-2.0'),
        dependency('libgnomekbd'),
        gnome_keyboard_ui_dep,
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'hardware')
)
