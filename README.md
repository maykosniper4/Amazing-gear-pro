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

To host on Vercel, import this repository and leave Root Directory at the repository root. The included `vercel.json` configures the Flutter build and serves `build/web`. The build script downloads the pinned Flutter SDK automatically. Pushes to the connected production branch trigger new deployments. If the project was imported before this configuration was added, redeploy the latest commit and use the production domain shown in the Vercel dashboard.

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
