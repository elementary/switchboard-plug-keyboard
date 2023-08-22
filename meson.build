project(
    'keyboard',
    'vala', 'c',
    version: '3.2.1'
)

gettext_name = meson.project_name() + '-plug'
gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)


add_project_arguments(
    ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
    language: 'vala'
)

gresources = gnome.compile_resources(
    'gresources', join_paths ('data', 'gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(glib_compile_schemas: true)
