xkbconf = dependency('xkeyboard-config')
xkb_base = xkbconf.get_pkgconfig_variable('xkb_base')

conf_data = configuration_data()
conf_data.set('XKB_BASE', xkb_base)
conf_data.set('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf_data.set('GETTEXT_PACKAGE', meson.project_name() + '-plug')
config_file = configure_file (
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

plug_files = files(
    'Plug.vala',
    'Widgets/Shortcuts/ShortcutListBox.vala',
    'Widgets/Shortcuts/CustomShortcutListBox.vala',
    'Widgets/Layout/Display.vala',
    'Widgets/Layout/AdvancedSettingsPanel.vala',
    'Widgets/InputMethod/LanguagesRow.vala',
    'Widgets/InputMethod/EnginesRow.vala',
    'Widgets/InputMethod/Utils.vala',
    'Views/Shortcuts.vala',
    'Views/Layout.vala',
    'Views/InputMethod.vala',
    'Views/Behavior.vala',
    'Shortcuts/Shortcut.vala',
    'Shortcuts/Settings.vala',
    'Shortcuts/ShortcutsList.vala',
    'Shortcuts/CustomShortcutSettings.vala',
    'Shortcuts/ConflictsManager.vala',
    'Xkb/XkbModifier.vala',
    'Xkb/Handler.vala',
    'InputSources/SourceSettings.vala',
    'InputSources/InputSource.vala',
    'InputMethod/AddEnginesList.vala',
    'InputMethod/Installer/UbuntuInstaller.vala',
    'InputMethod/Installer/InstallList.vala',
    'InputMethod/Installer/aptd-client.vala',
    'Dialogs/ProgressDialog.vala',
    'Dialogs/InstallEngineDialog.vala',
    'Dialogs/ConflictDialog.vala',
    'Dialogs/AddLayoutDialog.vala',
    'Dialogs/AddEngineDialog.vala'
)

switchboard_dep = dependency('switchboard-3')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

posix_dep = meson.get_compiler('vala').find_library('posix')

ibus_dep = dependency('ibus-1.0')
if(ibus_dep.version().version_compare('>=1.5.19'))
    add_project_arguments(['--define', 'IBUS_1_5_19'], language: 'vala')
endif

shared_module(
    meson.project_name(),
    plug_files,
    config_file,
    gresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite-7'),
        dependency('gtk4'),
        dependency('libadwaita-1'),
        dependency('libxml-2.0'),
        posix_dep,
        ibus_dep,
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'hardware')
)
