# Switchboard Keyboard Plug

## Building and Installation
You'll need the following dependencies:

    cmake
    libgranite-dev
    libswitchboard-2.0-dev
    libxml2-dev
    libgnomekbd-dev
    libxklavier-dev
    valac

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`, then execute with `switchboard`

    sudo make install
    switchboard
