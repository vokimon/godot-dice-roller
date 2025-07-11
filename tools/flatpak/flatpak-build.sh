#!/bin/bash

run() {
    echo -e "\033[34;1m$@\033[0m"
    "$@"
}

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
APP=net.canvoki.godot_dice_roller

cd $SCRIPTPATH

which flatpak || run sudo apt install flatpak
which flatpak-builder || run sudo apt install flatpak-builder

run flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

run flatpak install -y --user flathub \
    org.godotengine.godot.BaseApp//4.4 \
    org.freedesktop.Platform//24.08  \
    org.freedesktop.Sdk//24.08


run flatpak-builder --force-clean --repo=repo-dir build-dir ${APP}.yaml
run flatpak build-bundle repo-dir ${APP}.flatpak ${APP}
run flatpak install --or-update --user ${APP}.flatpak

# This builds and installs without creating a .flatpak bundle inbetween
#run flatpak-builder --user --install --force-clean build-dir ${APP}.yaml

run flatpak run ${APP}

