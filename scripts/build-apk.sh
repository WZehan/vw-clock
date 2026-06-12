#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDK_DIR="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
BUILD_TOOLS="$SDK_DIR/build-tools/34.0.0"
ANDROID_JAR="$SDK_DIR/platforms/android-34/android.jar"
OUT_DIR="$ROOT_DIR/dist"
BUILD_DIR="$ROOT_DIR/android/build"
WEB_ASSETS="$BUILD_DIR/assets"
GEN_DIR="$BUILD_DIR/gen"
OBJ_DIR="$BUILD_DIR/obj"
DEX_DIR="$BUILD_DIR/dex"
CLASSES_JAR="$BUILD_DIR/classes.jar"
KEYSTORE="$ROOT_DIR/android/debug-release.keystore"
APK_UNSIGNED="$BUILD_DIR/vw-clock-unsigned.apk"
APK_ALIGNED="$BUILD_DIR/vw-clock-aligned.apk"
APK_FINAL="$OUT_DIR/vw-clock.apk"

rm -rf "$BUILD_DIR" "$OUT_DIR"
mkdir -p "$WEB_ASSETS/assets" "$GEN_DIR" "$OBJ_DIR" "$DEX_DIR" "$OUT_DIR"

cp "$ROOT_DIR/index.html" "$WEB_ASSETS/index.html"
cp "$ROOT_DIR/assets/dotted-world-map-alpha.png" "$WEB_ASSETS/assets/dotted-world-map-alpha.png"

"$BUILD_TOOLS/aapt" package -f -m \
  -J "$GEN_DIR" \
  -M "$ROOT_DIR/android/AndroidManifest.xml" \
  -S "$ROOT_DIR/android/res" \
  -A "$WEB_ASSETS" \
  -I "$ANDROID_JAR" \
  -F "$APK_UNSIGNED"

javac -source 8 -target 8 \
  -bootclasspath "$ANDROID_JAR" \
  -classpath "$ANDROID_JAR" \
  -d "$OBJ_DIR" \
  "$GEN_DIR/cn/wangzehan/vwclock/R.java" \
  "$ROOT_DIR/android/src/cn/wangzehan/vwclock/MainActivity.java"

jar cf "$CLASSES_JAR" -C "$OBJ_DIR" .

"$BUILD_TOOLS/d8" --min-api 14 --lib "$ANDROID_JAR" --output "$DEX_DIR" "$CLASSES_JAR"

cd "$DEX_DIR"
"$BUILD_TOOLS/aapt" add "$APK_UNSIGNED" classes.dex
cd "$ROOT_DIR"

"$BUILD_TOOLS/zipalign" -f -p 4 "$APK_UNSIGNED" "$APK_ALIGNED"

if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair \
    -keystore "$KEYSTORE" \
    -storepass vwclock \
    -keypass vwclock \
    -alias vwclock \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=VW Clock,O=VW Clock,C=CN"
fi

"$BUILD_TOOLS/apksigner" sign \
  --ks "$KEYSTORE" \
  --ks-key-alias vwclock \
  --ks-pass pass:vwclock \
  --key-pass pass:vwclock \
  --v4-signing-enabled false \
  --out "$APK_FINAL" \
  "$APK_ALIGNED"

"$BUILD_TOOLS/apksigner" verify --min-sdk-version 14 "$APK_FINAL"

ls -lh "$APK_FINAL"
