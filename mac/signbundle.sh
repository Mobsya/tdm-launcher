#/bin/bash -ex

DEST=$1
IDENTITY="$2"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


if [[ $DEST =~ \.dmg$ ]]; then
    DMG="$1"
    DMG_DIR="$(mktemp -d)"
    DEST="$DMG_DIR/ThymioDeviceManager.app"
fi

# Make the top Level Bundle Out of the Launcher Bundle
mkdir -p "$DEST"
cp -R ./ThymioDeviceManager.app/* "$DEST"


realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

add_to_group() {
    defaults write "$1" "com.apple.security.application-groups" -array "P97H86YL8K.TDMLauncher"
}

sign() {
    if [ -z "$IDENTITY" ]; then
        echo "Identity not provided, not signing"
    else
        codesign --verify --strict --verbose=4 --timestamp  -s "$IDENTITY" "$@"
    fi
}

defaults write $(realpath "$DEST/Contents/Info.plist") NSPrincipalClass -string NSApplication
#defaults write $(realpath "$DEST/Contents/Info.plist") NSHighResolutionCapable -string True
add_to_group $(realpath "$DEST/Contents/Info.plist")
chmod 644 $(realpath "$DEST/Contents/Info.plist")

MAIN_DIR="$DEST/Contents/MacOS"


for binary in "thymio-device-manager" "tdmlauncher"
do
    echo "Signing $MAIN_DIR/$binary"
    sign -i org.mobsya.TDMLauncher.$binary --options=runtime $(realpath "$MAIN_DIR/$binary")
done

if [ -n "$DMG" ]; then
    test -f "$1" && rm "$DMG"
    create-dmg \
    --volname "Thymio Device Manager" \
    --background "$DIR/background.png" \
    --window-pos 200 120 \
    --window-size 640 480 \
    --icon-size 100 \
    --icon "ThymioDeviceManager.app" 100 300 \
    --hide-extension "ThymioDeviceManager.app" \
    --app-drop-link 500 300 \
    "$DMG" \
    "$DMG_DIR/ThymioDeviceManager.app"

    sign -f "$1"
fi
