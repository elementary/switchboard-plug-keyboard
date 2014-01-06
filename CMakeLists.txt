# This a sample CMakeLists.txt for compiling plug for Switchboard
# http://elementaryos.org/docs/developer-guide/cmake 

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)

# Set the Properties of your Plug

# Set the Name of the plug, should be an executable command, lowercase, no spaces 
set (PLUGNAME "keyboard")
# Set the Category of the Plug, one of:
# personal, hardware, network, system
set (PLUGCATEGORY "hardware")
# Set the Title to use for the Plug in the Overview and in the Titlebar
set (PLUGTITLE "Keyboard")
# The symbolic name of the Icon to use for the plug
set (PLUGICON "preferences-desktop-keyboard")

project (${PLUGNAME})

#########################################################
# Only alter stuff below if you know what you are doing #
#########################################################

include (GNUInstallDirs)
set (DATADIR "${CMAKE_INSTALL_FULL_LIBDIR}/switchboard")
set (PKGDATADIR "${DATADIR}/hardware/pantheon-${PLUGNAME}")
set (GETTEXT_PACKAGE "${PLUGNAME}-plug")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Configure file
configure_file (${CMAKE_SOURCE_DIR}/config.vala.cmake ${CMAKE_BINARY_DIR}/src/config.vala)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

# Files
file (GLOB resources "${CMAKE_CURRENT_SOURCE_DIR}/data/*")

# Comment this out to enable C compiler warnings
add_definitions (-w)

# Traslation stuff
add_subdirectory (po)
# Info-plug
install (FILES ${resources} DESTINATION ${PKGDATADIR})

add_subdirectory(src)