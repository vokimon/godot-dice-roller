#!/bin/bash

set -e

run() {
    echo -e "\033[34;1m$@\033[0m"
    "$@"
}

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
APP=net.canvoki.godot_dice_roller
YAML_FILE="${APP}.yaml"

cd $SCRIPTPATH

which flatpak || run sudo apt install flatpak
which flatpak-builder || run sudo apt install flatpak-builder
which yq || run sudo apt install yq

run flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

run flatpak install -y --user flathub \
    org.godotengine.godot.BaseApp//4.4 \
    org.freedesktop.Platform//24.08  \
    org.freedesktop.Sdk//24.08

ARCHIVE_URL=$(yq -r '.modules[].sources[] | select(.type == "archive") | .url' "$YAML_FILE")
echo "Computing the checksum for [$ARCHIVE_URL]"
SHA256=$(curl -sL "$ARCHIVE_URL" | sha256sum | awk '{print $1}')
echo Checksum: $SHA256
run yq -iy "(.modules[].sources[] | select(.type == \"archive\")) |= . + {\"sha256\": \"$SHA256\"}" -i "$YAML_FILE"

BUILD_DIR=".flatpak-builder/build"
REPO_DIR=".flatpak-builder/repo"

run flatpak-builder --repo=${REPO_DIR} ${BUILD_DIR} --force-clean ${APP}.yaml
run flatpak build-bundle ${REPO_DIR} ${APP}.flatpak ${APP}
run flatpak install --or-update --user -y ${APP}.flatpak
run flatpak run --command=flatpak-builder-lint org.flatpak.Builder appstream ${APP}.metainfo.xml
run flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest ${APP}.yaml
run flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo ${REPO_DIR}

run flatpak run ${APP}
run flatpak uninstall -y ${APP}

# This builds and installs without creating a .flatpak bundle inbetween
#run flatpak-builder --user --install --force-clean build-dir ${APP}.yaml


echo This adds the repo to the system (user wide) so we can see how it looks in discover or similar programs
echo flatpak remote-add --user --no-gpg-verify package-testing-repo ${REPO_DIR}


