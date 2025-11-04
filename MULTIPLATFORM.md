# 🌍 IPTV Casper - Multi-Platform Guide

## Supported Platforms

IPTV Casper now supports **ALL Flutter platforms**:

- ✅ **Windows** (10/11)
- ✅ **macOS** (10.14+)
- ✅ **Linux** (GTK 3.0+)
- ✅ **Android** (API 21+, Android 5.0+)
- ✅ **iOS** (12.0+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

---

## 🚀 Platform-Specific Setup

### Windows

**Requirements:**
- Windows 10/11
- Visual Studio 2019+ with C++ tools

**Run:**
```powershell
flutter run -d windows
```

**Build:**
```powershell
flutter build windows --release
```

**Output:** `build\windows\runner\Release\iptv_casper.exe`

---

### macOS

**Requirements:**
- macOS 10.14 (Mojave) or later
- Xcode 13.0+
- CocoaPods

**Setup:**
```bash
cd macos
pod install
cd ..
```

**Run:**
```bash
flutter run -d macos
```

**Build:**
```bash
flutter build macos --release
```

**Output:** `build/macos/Build/Products/Release/iptv_casper.app`

---

### Linux

**Requirements:**
- GTK 3.0+
- Required packages:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

**Run:**
```bash
flutter run -d linux
```

**Build:**
```bash
flutter build linux --release
```

**Output:** `build/linux/x64/release/bundle/`

---

### Android

**Requirements:**
- Android SDK
- Android Studio or Android command-line tools
- Java JDK 11+

**Setup:**
```bash
flutter doctor --android-licenses
```

**Run:**
```bash
flutter run -d <device-id>
```

**Build APK:**
```bash
flutter build apk --release
```

**Build App Bundle:**
```bash
flutter build appbundle --release
```

**Output:** 
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

---

### iOS

**Requirements:**
- macOS with Xcode 13.0+
- iOS device or simulator
- Apple Developer account (for device deployment)

**Setup:**
```bash
cd ios
pod install
cd ..
```

**Run:**
```bash
flutter run -d <device-id>
```

**Build:**
```bash
flutter build ios --release
```

**Note:** iOS builds require code signing. Open `ios/Runner.xcworkspace` in Xcode to configure signing.

---

### Web

**Requirements:**
- Modern web browser
- Chrome for debugging recommended

**Run:**
```bash
flutter run -d chrome
# or
flutter run -d web-server --web-port 8080
```

**Build:**
```bash
flutter build web --release
```

**Output:** `build/web/`

**Deploy:** Upload the `build/web/` folder to any web hosting service.

---

## 📱 Platform-Specific Features

### Desktop (Windows, macOS, Linux)
- ✅ Full window controls
- ✅ Keyboard shortcuts
- ✅ File system access
- ✅ Native menus (macOS)
- ✅ System tray support (planned)

### Mobile (Android, iOS)
- ✅ Touch gestures
- ✅ Landscape orientation optimized
- ✅ Background playback (planned)
- ✅ Picture-in-Picture (planned)
- ✅ Casting support (planned)

### Web
- ✅ Responsive design
- ✅ Progressive Web App (PWA)
- ✅ Share functionality
- ⚠️ Limited file access (browser security)
- ⚠️ Some streams may not work (CORS)

---

## 🔧 Quick Commands

### Check Connected Devices
```bash
flutter devices
```

### Run on Specific Platform
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Android
flutter run -d <android-device-id>

# iOS
flutter run -d <ios-device-id>

# Web
flutter run -d chrome
flutter run -d edge
flutter run -d firefox
```

### Build for All Platforms
```bash
# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release

# Mobile
flutter build apk --release
flutter build ios --release

# Web
flutter build web --release
```

---

## 📦 Distribution

### Windows
- Use Inno Setup or NSIS to create installer
- Or distribute as portable ZIP

### macOS
- Create DMG with `create-dmg` tool
- Or distribute as `.app` bundle
- Sign with Apple Developer certificate for distribution

### Linux
- Create `.deb` package: Use `flutter_to_debian`
- Create `.rpm` package: Use `flutter_to_rpm`
- Create Snap: Use `snapcraft`
- Create Flatpak: Use `flatpak-builder`
- AppImage: Use `appimagetool`

### Android
- Upload APK to website for direct download
- Publish to Google Play Store (requires developer account)
- Distribute via alternative app stores

### iOS
- Publish to Apple App Store (requires Apple Developer account)
- Distribute via TestFlight for beta testing

### Web
- Deploy to any static hosting:
  - GitHub Pages
  - Netlify
  - Vercel
  - Firebase Hosting
  - AWS S3 + CloudFront

---

## 🎨 Responsive UI

The app automatically adapts to different screen sizes:

- **Desktop (>1024px)**: Side-by-side layout
- **Tablet (600-1024px)**: Adaptive layout
- **Mobile (<600px)**: Stacked layout
- **Web**: Responsive grid

---

## ⚙️ Platform Configuration

### Enable Platforms
```bash
# Enable all platforms
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter config --enable-web

# Check configuration
flutter config
```

### Create Platform Files (if missing)
```bash
flutter create --platforms=windows,macos,linux,android,ios,web .
```

---

## 🐛 Platform-Specific Troubleshooting

### Windows
- **Issue**: Build fails
- **Solution**: Install Visual Studio C++ tools, run `flutter doctor`

### macOS
- **Issue**: Pod install fails
- **Solution**: Run `sudo gem install cocoapods`, then `pod install`

### Linux
- **Issue**: Missing GTK
- **Solution**: `sudo apt-get install libgtk-3-dev`

### Android
- **Issue**: License not accepted
- **Solution**: `flutter doctor --android-licenses`

### iOS
- **Issue**: Code signing failed
- **Solution**: Open Xcode, configure Team and Bundle ID

### Web
- **Issue**: CORS errors on streams
- **Solution**: Use CORS proxy or backend server

---

## 📊 Platform Feature Matrix

| Feature | Windows | macOS | Linux | Android | iOS | Web |
|---------|---------|-------|-------|---------|-----|-----|
| Video Playback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| M3U Parser | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| File Picker | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| Persistence | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Fullscreen | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Background Play | ➖ | ➖ | ➖ | 🔜 | 🔜 | ➖ |
| PiP Mode | ➖ | ✅ | ➖ | 🔜 | 🔜 | ➖ |
| Native Menus | ➖ | ✅ | ➖ | ➖ | ➖ | ➖ |

✅ Supported | ⚠️ Limited | 🔜 Planned | ➖ Not Applicable

---

## 🎯 Recommended Platform for Development

- **Primary Development**: Windows/macOS (best tooling)
- **Testing**: Use all platforms you plan to support
- **Release**: Test on real devices before distribution

---

## 📞 Platform-Specific Support

For platform-specific issues, check:
- Windows: `windows/` folder
- macOS: `macos/` folder
- Linux: `linux/` folder
- Android: `android/` folder
- iOS: `ios/` folder
- Web: `web/` folder

Each platform has its own configuration files and build settings.

---

## 🚀 Getting Started

1. **Install Flutter SDK** for your platform
2. **Enable desired platforms**: `flutter config --enable-<platform>-desktop`
3. **Run flutter doctor**: Fix any issues
4. **Install dependencies**: `flutter pub get`
5. **Choose platform**: `flutter devices`
6. **Run**: `flutter run -d <device>`
7. **Build**: `flutter build <platform> --release`

---

Happy cross-platform development! 🌍✨
