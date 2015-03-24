#!/bin/bash
set -eu

command -v vagrant >/dev/null 2>&1 || {
    echo >&2 "Please install vagrant from https://www.vagrantup.com/.  Aborting.";
    exit 1;
}

ROOT=$(dirname "${BASH_SOURCE[0]}")
ROOT=$(readlink -f "${ROOT}")
VISUAL_STUDIO_ISO="${ROOT}/vs2013.4_ce_enu.iso"
VISUAL_STUDIO_URL=http://download.microsoft.com/download/7/1/B/71BA74D8-B9A0-4E6C-9159-A8335D54437E/vs2013.4_ce_enu.iso

if [ ! -f "${VISUAL_STUDIO_ISO}" ]; then
    echo "Downloading Visual Studio Community 2013 Update 4 ISO, this may take a while..."
    wget -O "${VISUAL_STUDIO_ISO}" "${VISUAL_STUDIO_URL}"
else
    echo "Checking available Visual Studio Community 2013 Update 4 ISO..."
    if ! sha256sum -c --status vs2013.4_ce_enu.iso.sha256; then
        echo "Continuing download of Visual Studio Community 2013 Update 4 ISO, this may take a while..."
        wget --continue -O "${VISUAL_STUDIO_ISO}" "${VISUAL_STUDIO_URL}"
    fi
fi

echo "Checking for vagrant-windows plugin..."
if ! vagrant plugin list | grep --quiet vagrant-windows; then
    vagrant plugin install vagrant-windows
fi

echo "Checking for the required Vagrant box..."
if ! vagrant box list | grep --quiet "opentable/win-8.1-core-amd64-nocm.*virtualbox"; then
    vagrant box add --provider virtualbox --insecure opentable/win-8.1-core-amd64-nocm
fi

if [ ! -f "${ROOT}/Vagrantfile" ]; then
    echo "Preparing Vagrantfile..."
    sed "s|__VISUAL_STUDIO_ISO__|${VISUAL_STUDIO_ISO}|g" "${ROOT}/Vagrantfile.in" > "${ROOT}/Vagrantfile"
fi

echo "Ready"
