#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Install: brew install xcodegen" >&2
  exit 1
fi

BUILD_DIR="$ROOT_DIR/build"
DERIVED_DATA_PATH="$BUILD_DIR/DerivedData"
IPA_PATH="$BUILD_DIR/iosphoto-unsigned.ipa"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release-iphoneos/iosphoto.app"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "[1/4] Generating Xcode project with XcodeGen..."
xcodegen generate --spec project.yml

echo "[2/4] Building iOS app (Release, no code signing)..."
xcodebuild \
  -project iosphoto.xcodeproj \
  -scheme iosphoto \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  build

if [ ! -d "$APP_PATH" ]; then
  echo "Build succeeded but app bundle not found: $APP_PATH" >&2
  exit 1
fi

echo "[3/4] Packaging unsigned IPA..."
mkdir -p "$BUILD_DIR/Payload"
cp -R "$APP_PATH" "$BUILD_DIR/Payload/"
(
  cd "$BUILD_DIR"
  rm -f "$IPA_PATH"
  /usr/bin/zip -qry "$IPA_PATH" Payload
)
rm -rf "$BUILD_DIR/Payload"

echo "[4/4] Done."
echo "IPA_PATH=$IPA_PATH"
