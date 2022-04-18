#!/usr/bin/env bash

UPDATE_SCRIPT="https://raw.githubusercontent.com/Elycin/proxmox-tooling/main/update-containers.sh"

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
        exit
    fi
}

function host {
    for i in $(pct list | awk '/[0-9]/{print $1}'); do
        # Check container for pre-requisite things
        if_alpine_pre $i

        # Download the file and run the update script.
        pct exec $i -- wget -O /tmp/filupdatee.sh $UPDATE_SCRIPT
        pct exec $i -- bash /tmp/update.sh
    done
}

function if_alpine_pre {
    if pct exec $1 -- which apk; then
        echo "ALPINE LINUX CONTAINER DETECTED ON THE HOST, GOING TO CHECK IF IT HAS TOOLS."

        # Check if wget is installed on alpine
        if ! pct exec $1 -- which wget; then
            apk add wget
        fi

        # Check if bash is installed on alpine.
        if ! pct exec $1 -- which bash; then
            apk add wget
        fi
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
