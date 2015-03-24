# Build iridium-browser for Windows using Vagrant

## Prerequisites

- Install [Vagrant](https://www.vagrantup.com).
- Install [VirtualBox](https://www.virtualbox.org).
- Run `bootstrap.sh`.

## Setup

Start the Vagrant box:

    host$ vagrant up

This will also perform a checkout of the source code and start the compilation.
The resulting installer will be located on your host in folder `build_result`.

If the virtual machine asks you to go to PC settings to activate Windows, open
it and switch back to the desktop by moving the mouse to the top-left corner of
the screen and clicking the small desktop.
