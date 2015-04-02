#!/bin/bash
set -eu

command -v vagrant >/dev/null 2>&1 || {
    echo >&2 "Please install vagrant from https://www.vagrantup.com/.  Aborting.";
    exit 1;
}

SHA256SUM=sha256sum
command -v ${SHA256SUM} >/dev/null 2>&1 || {
    # OSX doesn't provide a "sha256sum" binary
    SHA256SUM="shasum -a 256"
}

realpath() {
    OURPWD=$PWD
    cd "$(dirname "$1")"
    LINK=$(readlink "$(basename "$1")")
    while [ "$LINK" ]; do
        cd "$(dirname "$LINK")"
        LINK=$(readlink "$(basename "$1")")
    done
    REALPATH="$PWD/$(basename "$1")"
    cd "$OURPWD"
    echo "$REALPATH"
}

ROOT=$(dirname "${BASH_SOURCE[0]}")
if [ "${ROOT}" = "." ]; then
    ROOT=
fi
ROOT=$(realpath "${ROOT}")

VISUAL_STUDIO_ISO="${ROOT}/vs2013.4_ce_enu.iso"
VISUAL_STUDIO_URL=http://download.microsoft.com/download/7/1/B/71BA74D8-B9A0-4E6C-9159-A8335D54437E/vs2013.4_ce_enu.iso

if [ ! -f "${VISUAL_STUDIO_ISO}" ]; then
    echo "Downloading Visual Studio Community 2013 Update 4 ISO, this may take a while..."
    curl -L -o "${VISUAL_STUDIO_ISO}" "${VISUAL_STUDIO_URL}"
else
    echo "Checking available Visual Studio Community 2013 Update 4 ISO..."
    if ! ${SHA256SUM} -c --status vs2013.4_ce_enu.iso.sha256; then
        echo "Continuing download of Visual Studio Community 2013 Update 4 ISO, this may take a while..."
        curl -C - -L -o "${VISUAL_STUDIO_ISO}" "${VISUAL_STUDIO_URL}"
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
