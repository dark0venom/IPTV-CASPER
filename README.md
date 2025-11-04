# IPTV Casper

A modern **cross-platform** IPTV player built with Flutter.

## 🌍 Supported Platforms

- ✅ **Windows** (10/11)
- ✅ **macOS** (10.14+)
- ✅ **Linux** (GTK 3.0+)
- ✅ **Android** (5.0+)
- ✅ **iOS** (12.0+)
- ✅ **Web** (PWA)

## ✨ Features

- 📺 Play IPTV channels from M3U/M3U8 playlists
- 🎬 Full video player controls (play, pause, volume, fullscreen)
- 📋 Channel list with search and filtering
- ⭐ Favorite channels with persistence
- 🎨 Modern dark theme UI
- 💾 Cross-platform storage for playlists and settings
- 🔍 Group-based filtering
- 🌐 Works on desktop, mobile, and web

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Platform-specific requirements (see [MULTIPLATFORM.md](MULTIPLATFORM.md))

### Quick Start

1. Install Flutter SDK
2. Clone/download the repository
3. Run `flutter pub get` to install dependencies
4. Choose your platform:
   ```bash
   # Windows
   flutter run -d windows
   
   # macOS
   flutter run -d macos
   
   # Linux
   flutter run -d linux
   
   # Android
   flutter run -d <device-id>
   
   # iOS
   flutter run -d <device-id>
   
   # Web
   flutter run -d chrome
   ```

### Usage

1. Launch the application
2. Add a playlist URL or import an M3U file
3. Browse and select channels
4. Enjoy watching!

## Building for Release

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

### Mobile
```bash
# Android (APK)
flutter build apk --release

# iOS
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

See [MULTIPLATFORM.md](MULTIPLATFORM.md) for detailed platform-specific instructions.

## License

MIT License
