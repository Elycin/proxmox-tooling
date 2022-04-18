#!/usr/bin/env bash

UPDATE_SCRIPT="https://gist.githubusercontent.com/Elycin/994cee6f0dd287901f06c2768e7cefd2/raw/caedbdad7532e352b6297950921234c5eb88ae31/update.sh"

function update_container {
    if command -v apt-get &>/dev/null; then
        update_apt
        exit
    fi

    if command -v dnf &>/dev/null; then
        update_dnf
        exit
    fi

    if command -v apk &>/dev/null; then
        update_alpine
    fi
}

function host {
    for i in $(pct list | awk '/[0-9]/{print $1}'); do 
        # Check container for pre-requisite things
        if_alpine_pre $i;

        # Download the file and run the update script.
        pct exec $i -- wget -O /tmp/filupdatee.sh $UPDATE_SCRIPT; 
        pct exec $i -- bash /tmp/update.sh
    fi
}

function if_alpine_pre {
    # Check if wget is installed on alpine
    if ! pct exec $1 -- which wget; then 
        apk add wget
    fi

    # Check if bash is installed on alpine.
    if ! pct exec $1 -- which bash; then 
        apk add wget
    fi
}

function update_alpine {
    apk update
}

function update_apt {
    apt-get update
    apt-get upgrade -y
    apt-get autoremove -y
    apt-get clean
}

function update_dnf {
    dnf upgrade -y
}

function alpine_install_wget {
    apk add wget
}

if [ -d "/etc/pve" ]; then
    echo "Proxmox host detected, running download command on each container."
    host
else
    echo "Container detected, running update sequence."
    update_container
fi