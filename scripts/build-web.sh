#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Match the SDK used to develop and test the game.
flutter_version="3.50.1"
flutter_sdk="${TMPDIR:-/tmp}/amazing-gear-flutter-${flutter_version}"

if [[ ! -x "${flutter_sdk}/bin/flutter" ]]; then
  git clone --depth 1 --branch "${flutter_version}" \
    https://github.com/flutter/flutter.git "${flutter_sdk}"
fi

export PATH="${flutter_sdk}/bin:${PATH}"
export CI=true
flutter config --no-analytics
flutter pub get
flutter build web --release
test -f build/web/index.html
test -f build/web/flutter_bootstrap.js
