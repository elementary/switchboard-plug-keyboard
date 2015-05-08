find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED gthread-2.0 gtk+-3.0>=3.10 switchboard-2.0 granite)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.22.0" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and required packages to the List below to include them in the build
vala_precompile (VALA_C ${CMAKE_PROJECT_NAME}
    keyboard.vala
    page.vala

    Pages/behaviour.vala
    Pages/Behaviour/settings.vala

    Pages/layout.vala   
    Pages/Layout/display.vala
    Pages/Layout/add_layout.vala
    Pages/Layout/handler.vala
    Pages/Layout/settings.vala
    
    Pages/shortcuts.vala 
    Pages/Shortcuts/settings.vala
    Pages/Shortcuts/tree.vala
    Pages/Shortcuts/display.vala
    Pages/Shortcuts/shortcut.vala
    Pages/Shortcuts/list.vala
    Pages/Shortcuts/section_switcher.vala
    Pages/Shortcuts/custom_tree.vala
    Pages/Shortcuts/custom_shortcut_settings.vala
    Pages/Shortcuts/conflict_dialog.vala
    Pages/Shortcuts/display_tree.vala
    
    Pages/options.vala
    Pages/Options/section_switcher.vala
    Pages/Options/option_handler.vala
    Pages/Options/section_display.vala
    Pages/Options/option_tree.vala
    Pages/Options/option_settings.vala

    ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
    gtk+-3.0
    switchboard-2.0
    granite
OPTIONS
    --thread
)

add_library (${CMAKE_PROJECT_NAME} MODULE ${VALA_C})
target_link_libraries(${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES}) 


# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} DESTINATION ${PKGDATADIR})
