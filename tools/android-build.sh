#!/bin/bash

APPNAME=${APPNAME:=$(cat fastlane/metadata/en-US/title.txt)}
APPVERSION=$(grep '## ' CHANGES.md | head -n1 | cut -d " " -f 2)
APPFILE=$(echo $APPNAME | sed "s/[[:blank:]]//g")
KEYSTORE=${KEYSTORE:=vokimon.keystore}
KEYNAME=${KEYNAME:=vokimon}
GODOT_BIN=${GODOT_BIN:=../Godot*}
GODOT_EXPORT=${GODOT_EXPORT:=build/${APPFILE}.apk}
FINAL_EXPORT=${FINAL_EXPORT:=build/${APPFILE}-${APPVERSION}.apk}

run() {
    echo -e "\033[34m== ${@}\033[0m"
    "${@}"
}

mkdir -p build

# Generar clave de firma
# keytool -genkey -v -v -keystore ${KEYSTORE} -alias ${KEYNAME} -keyalg RSA -keysize 2048 -validity 20000

# Ver clave de firma
# keytool  -list -keystore ${KEYSTORE}

# Export project for Android
run $GODOT_BIN -v --headless --path . --export-release Android --quit

# Alinear ficheros, Android>=11, jarsigner<34 (ubuntu instala el 33)
run mv "${FINAL_EXPORT}" "${GODOT_EXPORT}"
run zipalign -f -v 4 "${GODOT_EXPORT}" "${FINAL_EXPORT}"

# Firmar
run apksigner sign --ks ${KEYSTORE} --ks-key-alias ${KEYNAME} "${FINAL_EXPORT}"

# Instalar -r replace -g grant all -d allow downgrade -t test packages
run adb install -r -t -g -d "${FINAL_EXPORT}"

