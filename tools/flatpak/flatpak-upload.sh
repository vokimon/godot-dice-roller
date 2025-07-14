#!/bin/bash
# This scripts uploads flatpack files to flathub


#!/bin/bash
set -e

APP_ID=net.canvoki.godot_dice_roller
GITHUB_USER=vokimon

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FLATHUB_REPO_PATH="$SCRIPTPATH/flathub"

cd "$SCRIPTPATH"

run() {
    echo -e "\033[34;1m$@\033[0m"
    "$@"
}

# Clone flathub repo if missing
if [ ! -d "$FLATHUB_REPO_PATH/.git" ]; then
    echo "Local flathub repo not found. Cloning your fork..."
    if ! git clone "git@github.com:$GITHUB_USER/flathub.git" "$FLATHUB_REPO_PATH" --branch=new-pr; then
        echo "Could not clone your fork. Please fork https://github.com/flathub/flathub and try again."
        exit 1
    fi
fi

pushd "$FLATHUB_REPO_PATH" > /dev/null

# Checkout or create branch
if ! git rev-parse --verify "$APP_ID" >/dev/null 2>&1; then
    run git checkout -b "$APP_ID" origin/new-pr
else
    run git checkout "$APP_ID"
fi

popd > /dev/null

run install -Dm644 "${APP_ID}.yaml" $FLATHUB_REPO_PATH/

pushd "$FLATHUB_REPO_PATH" > /dev/null
run git add "${APP_ID}.yaml"
popd > /dev/null

echo
echo "Files copied and staged for commit in branch '$APP_ID'."
echo "To commit and push, run these commands:"
echo "  cd $FLATHUB_REPO_PATH"
echo "  git commit -m 'Add/update $APP_ID metadata'"
echo "  git push -u origin $APP_ID"
echo
echo "Then open a PR at:"
echo "https://github.com/$GITHUB_USER/flathub/compare/$APP_ID?expand=1"

