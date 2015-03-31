# Build iridium-browser for Windows using Vagrant

## Prerequisites

- Make sure you have at least 75 GB free disk space.
- Install [Vagrant](https://www.vagrantup.com).
- Install [VirtualBox](https://www.virtualbox.org).
- Run `bootstrap.sh`. This will download the Visual Studio Community 2013
  Update 4 ISO image (about 7 GB), the Windows Vagrant box (about 3.6 GB)
  and install the necessary Vagrant plugin.

## Setup

Start the Vagrant box:

    host$ vagrant up

This will also perform a checkout of the source code and start the compilation.
The resulting installer will be located on your host in folder `build_result`.

If the virtual machine asks you to go to PC settings to activate Windows, open
it and switch back to the desktop by moving the mouse to the top-left corner of
the screen and clicking the small desktop.

## Compile changes

After you did some changes to the code, you can login to the virtual machine and
trigger compilation.

    host$ vagrant ssh
    guest$ ninja -C develop/src/out/Release chrome

If you also modified `.gyp` files, you will have to recreate the build scripts
before compiling.

    guest$ c:\vagrant\scripts\windows\080_runhooks.cmd

**IMPORTANT**: If you run `vagrant provision`, all local changes will be reset
               and overwritten with the default iridium-browser patches!

## Build installer

To compile the code and build a new installer, you can use one of the
provisioning scripts:

    host$ vagrant ssh
    guest$ c:\vagrant\scripts\windows\100_compile_release.cmd

## Troubleshooting

If you receive this error while starting the virtual machine:
```
A host only network interface you're attempting to configure via DHCP
already has a conflicting host only adapter with DHCP enabled. The
DHCP on this adapter is incompatible with the DHCP settings. Two
host only network interfaces are not allowed to overlap, and each
host only network interface can have only one DHCP server. Please
reconfigure your host only network or remove the virtual machine
using the other host only network.
```

the network configuration in `Vagrantfile` must be changed from

    config.vm.network "private_network", type: "dhcp"

to

    config.vm.network "private_network", ip: "1.2.3.4"

where `1.2.3.4` is a local IP address that can be reached from your host.
