#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-$(python3 scripts/read_version.py)}"
APP_NAME="KillSnail"
DERIVED_DATA="$ROOT_DIR/.build/DerivedData"
ARTIFACTS_DIR="$ROOT_DIR/.build/artifacts"
STAGING_DIR="$ROOT_DIR/.build/dmg-root"

xcodegen generate

xcodebuild \
  -project "$ROOT_DIR/KillSnail.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Release/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found at $APP_PATH" >&2
  exit 1
fi

rm -rf "$ARTIFACTS_DIR" "$STAGING_DIR"
mkdir -p "$ARTIFACTS_DIR" "$STAGING_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"

DMG_PATH="$ARTIFACTS_DIR/$APP_NAME-v$VERSION.dmg"
ZIP_PATH="$ARTIFACTS_DIR/$APP_NAME-v$VERSION.zip"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

create-dmg \
  --volname "$APP_NAME" \
  --window-size 640 420 \
  --icon-size 128 \
  --icon "$APP_NAME.app" 180 200 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 460 200 \
  --skip-jenkins \
  "$DMG_PATH" \
  "$STAGING_DIR"

shasum -a 256 "$DMG_PATH" "$ZIP_PATH" > "$ARTIFACTS_DIR/checksums.txt"

printf 'DMG_PATH=%s\nZIP_PATH=%s\n' "$DMG_PATH" "$ZIP_PATH"
