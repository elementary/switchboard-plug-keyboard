# Switchboard Keyboard Plug
[![l10n](https://l10n.elementary.io/widgets/switchboard/switchboard-plug-keyboard/svg-badge.svg)](https://l10n.elementary.io/projects/switchboard/switchboard-plug-keyboard)

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libswitchboard-2.0-dev
* libgnomekbd-dev
* libgranite-dev
* libgtk-3-dev
* libxklavier-dev
* libxml2-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
