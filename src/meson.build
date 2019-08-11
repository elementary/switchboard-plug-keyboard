plug_files = files(
    'Plug.vala',
    'Widgets/Shortcuts/Tree.vala',
    'Widgets/Shortcuts/SectionSwitcher.vala',
    'Widgets/Shortcuts/DisplayTree.vala',
    'Widgets/Shortcuts/Display.vala',
    'Widgets/Shortcuts/ApplicationTree.vala',
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
    'Shortcuts/ApplicationShortcutSettings.vala',
    'Shortcuts/CustomShortcutSettings.vala',
    'Layout/XkbModifier.vala',
    'Layout/Settings.vala',
    'Layout/Handler.vala',
    'Layout/AdvancedSettingsPanel.vala',
    'Layout/AdvancedSettingsGrid.vala',
    'Dialogs/ConflictDialog.vala',
    'Behavior/Settings.vala'
)

switchboard_dep = dependency('switchboard-2.0')

gnome_keyboard_ui_dep = meson.get_compiler('c').find_library('gnomekbdui')

shared_module(
    meson.project_name(),
    plug_files,
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
    install_dir : join_paths(switchboard_dep.get_pkgconfig_variable('plugsdir'), 'hardware')
)
