# Amazing gear 2

A Flutter arcade game by Bereketab Mihiretab. Tap the left or right half of the screen to jump through brick gates and avoid floating obstacles. On desktop, use the arrow keys or A/D.

## Features

- Wider gates and gradually introduced moving obstacles
- Selectable gear skins and color themes
- Locally saved best score and preferences
- Sound effects, pause controls, and an About page
- Bounded audio requests and a game ticker that stops while idle or backgrounded

## Run

Install Flutter (this project was tested with Dart 3.14), then run:

```sh
flutter pub get
flutter run -d chrome
```

For Android, connect a device and run `flutter run`.

## Build

```sh
# Separate Android APKs by CPU architecture
flutter build apk --release --split-per-abi

# Static website, output in build/web
flutter build web --release
```

Windows users can also run `./build-apks.ps1`. Build outputs are intentionally excluded from Git.

The generated `build/web` directory can be deployed as a static site to Vercel. Uploading this repository alone does not deploy the website; configure a Flutter build environment or deploy the locally built web directory.

## Checks

```sh
flutter analyze
flutter test
```

## Publishing notes

Android release builds currently use the development signing configuration. Configure a private upload key before submitting to Google Play; never commit signing keys or passwords. iOS requires separate branding, signing, and device testing on macOS.

This project began as an Amazing Gear clone. Verify rights to the name and all graphics and audio before public distribution or commercial use. No license for third-party assets is granted by this repository.

## Developer

- Bereketab Mihiretab
- Email: bereketab00@gmail.com
- Telegram: @BereketabMihiretab
- Facebook: @bereketabmihiretab
