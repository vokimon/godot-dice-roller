APPNAME=${APPNAME:=$(cat fastlane/metadata/en-US/title.txt)}
KEYSTORE=${KEYSTORE:=vokimon.keystore}
KEYNAME=${KEYNAME:=vokimon}
GODOT_BIN=${GODOT_BIN:=../Godot*}
GODOT_EXPORT=${GODOT_EXPORT:=${APPNAME}.apk}
FINAL_EXPORT=${GODOT_EXPORT:=${APPNAME}-aligned.apk}

# Generar clave de firma
# keytool -genkey -v -v -keystore ${KEYSTORE} -alias ${KEYNAME} -keyalg RSA -keysize 2048 -validity 20000

# Ver clave de firma
# keytool  -list -keystore ${KEYSTORE}

# Export project for Android
$GODOT_BIN -v --headless --path . --export-release Android --quit

# Alinear ficheros, Android>=11, jarsigner<34 (ubuntu instala el 33)
zipalign -f -v 4 "${GODOT_EXPORT}" "${FINAL_EXPORT}"

# Firmar
apksigner sign --ks ${KEYSTORE} --ks-key-alias ${KEYNAME} "${FINAL_EXPORT}"

# Instalar -r replace -g grant all -d allow downgrade -t test packages
adb install -r -t -g -d "${FINAL_EXPORT}"

