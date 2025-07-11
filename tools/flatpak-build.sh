#!/bin/bash

which flatpak || sudo apt install flatpak
which flatpak-builder || sudo apt install flatpack-builder

flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install --user flathub org.godotengine.godot.BaseApp//4.4
flatpak install --user flathub org.freedesktop.Platform//24.08 
flatpak install --user flathub org.freedesktop.Sdk//24.08

flatpak-builder --user --install --force-clean build-dir tools/flatpak/net.canvoki.godot_dice_roller.yaml




