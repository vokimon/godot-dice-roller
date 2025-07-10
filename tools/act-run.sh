#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

run() {
    echo -e "\033[34m$@\033[0m"
    "$@"
}
step() {
    echo -e "\033[36;1m== $@\033[0m"
}
die() {
    echo -e "\033[31;1m== $@\033[0m"
    exit -1
}

# Working dir in the root of the project
cd $SCRIPTPATH/..

[ -e tools/act ] || {
    step Act binary not found downloading...
    run curl -L https://github.com/nektos/act/releases/latest/download/act_Linux_x86_64.tar.gz -o act.tar.gz  &&
    run tar xfz act.tar.gz act &&
    run mv act tools/ &&
    run rm act.tar.gz || echo failed
}

[ -e .act-secrets ] || {
    cat > .act-secrets <<EOF
# base62 -w0 your.keystore
ANDROID_KEYSTORE_RELEASE_BASE64=
ANDROID_KEYSTORE_RELEASE_ALIAS=
ANDROID_KEYSTORE_RELEASE_PASSWORD=
ANDROID_KEYSTORE_DEBUG_BASE64=
ANDROID_KEYSTORE_DEBUG_ALIAS=
ANDROID_KEYSTORE_DEBUG_PASSWORD=
# https://itch.io/user/settings/api-keys
BUTLER_API_KEY=
ITCHIO_USERNAME=
ITCHIO_GAME=
EOF
    die No .act-secrets found, created an empty one, fill the secret variables
}

tools/act -W .github/workflows/publish-app.yaml --secret-file .act-secrets

