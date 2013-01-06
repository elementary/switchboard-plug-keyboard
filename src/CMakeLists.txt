find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED gthread-2.0 gtk+-3.0 pantheon granite)

add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.12.0" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and required packages to the List below to include them in the build
vala_precompile (VALA_C

    keyboard.vala
    
    Pages/behaviour.vala
    
    Pages/shortcuts.vala
    
    Pages/Shortcuts/settings.vala
    Pages/Shortcuts/tree.vala
    Pages/Shortcuts/display.vala
    
    Pages/layout.vala
    
    Pages/Layout/display.vala
    Pages/Layout/add_layout.vala
	Pages/Layout/handler.vala
	Pages/Layout/settings.vala
	
    ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
    gtk+-3.0
    pantheon
    granite
OPTIONS
    --thread
)

add_executable (${PLUGNAME} ${VALA_C})

# Installation
install (TARGETS ${PLUGNAME} DESTINATION ${PKGDATADIR})
