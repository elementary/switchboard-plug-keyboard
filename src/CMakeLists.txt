find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED gthread-2.0 gtk+-3.0>=3.10 switchboard-2.0 granite libxml-2.0 libgnomekbdui libgnomekbd)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.22.0" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and required packages to the List below to include them in the build
vala_precompile (VALA_C ${CMAKE_PROJECT_NAME}
    Keyboard.vala

    Behavior/Settings.vala

    Dialogs/ConflictDialog.vala

    Layout/AdvancedSettingsPanel.vala
    Layout/AdvancedSettingsGrid.vala
    Layout/Handler.vala
    Layout/Settings.vala
    Layout/XkbModifier.vala

    Shortcuts/CustomShortcutSettings.vala
    Shortcuts/List.vala
    Shortcuts/Settings.vala
    Shortcuts/Shortcut.vala

    Views/AbstractPage.vala
    Views/Behavior.vala
    Views/Layout.vala
    Views/Shortcuts.vala

    Widgets/Layout/AddLayoutPopover.vala
    Widgets/Layout/Display.vala

    Widgets/Shortcuts/CustomTree.vala
    Widgets/Shortcuts/Display.vala
    Widgets/Shortcuts/DisplayTree.vala
    Widgets/Shortcuts/SectionSwitcher.vala
    Widgets/Shortcuts/Tree.vala

    ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
    gtk+-3.0
    gdk-x11-3.0
    switchboard-2.0
    granite
    libxml-2.0
    libgnomekbd
OPTIONS
    --thread
    --vapidir=${CMAKE_SOURCE_DIR}/vapi/
)

add_library (${CMAKE_PROJECT_NAME} MODULE ${VALA_C})
target_link_libraries(${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES}) 


# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} DESTINATION ${PKGDATADIR})
