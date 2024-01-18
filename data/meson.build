i18n.merge_file(
    input: 'keyboard.metainfo.xml.in',
    output: 'io.elementary.settings.keyboard.metainfo.xml',
    po_dir: meson.source_root() / 'po' / 'extra',
    type: 'xml',
    install: true,
    install_dir: datadir / 'metainfo'
)

install_data(
    'keyboard.gschema.xml',
    install_dir: datadir / 'glib-2.0' / 'schemas',
    rename: 'io.elementary.settings.keyboard.gschema.xml'
)
