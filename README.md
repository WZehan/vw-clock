# VW Clock

Volkswagen-style infotainment clock pages built with plain HTML, CSS, and JavaScript.

Live site: https://vw-clock.wangzehan.cn/

Video demos:

- [Bilibili](https://www.bilibili.com/video/BV1Qyj36fEBF)
- [YouTube](https://www.youtube.com/watch?v=CmAB6F3wauc)

## Overview

This project implements three clock display styles inspired by Volkswagen in-car infotainment screens. It is designed as a lightweight single-page web app and uses the system time for all clock displays.

The page is intentionally dependency-free so it can run in older embedded WebView environments, including Android 5.1-based car head units.

## Features

- Three clock styles in one page.
- Tap or click anywhere on the screen to switch between styles.
- Analog clocks use the device system time.
- Date display formats are customized per style.
- Dotted world map background asset for the infotainment-style screens.
- Smooth digital clock sweep effect using SVG.
- No build step or external runtime dependency.

## Clock Styles

1. Analog clock with dotted world map background, central gradient dial, jumping second hand, and mirrored bottom tick reflection.
2. Analog clock on a pure black background with white hour/minute hands, red jumping second hand, and `yyyy-mm-dd` date.
3. Digital clock with a sweeping second-hand trail, dotted world map background, and `yyyy.mm.dd` date.

## Files

- `index.html` - Main application file containing markup, styles, and clock logic.
- `assets/dotted-world-map.png` - Generated dotted world map image.
- `assets/dotted-world-map-alpha.png` - Transparent-background version used by the clock UI.
- `assets/app-icon-source.png` - Source image for the Android launcher icon.
- `android/` - Minimal native Android WebView shell.
- `scripts/build-apk.sh` - Script for packaging the Android APK without Gradle.
- `scripts/make-icons.py` - Script for generating Android launcher icon densities.

## Local Preview

Run a local static server from the project root:

```bash
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000/
```

## Android APK

The project includes a minimal native Android WebView shell. It loads the local `index.html` from APK assets and does not use Flutter, Cordova, or other large runtimes.

Compatibility:

- `minSdkVersion`: 14, compatible with Android 4.0+
- Android 5.1 car head units are supported
- Landscape fullscreen WebView
- Signed with APK v1/v2/v3 schemes; v1 signing keeps Android 4/5 installation compatibility

Build the APK:

```bash
sh scripts/build-apk.sh
```

The generated APK is written to:

```text
dist/vw-clock.apk
```

The build script expects a local Android SDK at either `$ANDROID_HOME` or `~/Library/Android/sdk`, with Android build tools `34.0.0` and platform `android-34` installed. The app still targets old devices through `minSdkVersion=14`.

To regenerate launcher icon density assets from `assets/app-icon-source.png`:

```bash
/Users/zehanwang/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 scripts/make-icons.py
```

## Compatibility Notes

The implementation avoids modern framework dependencies and keeps JavaScript syntax compatible with older WebViews. CSS and SVG are used for the visual effects, with fallbacks kept simple for embedded browser environments.
