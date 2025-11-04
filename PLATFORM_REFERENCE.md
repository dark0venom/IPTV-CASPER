# 🌍 IPTV Casper - Multi-Platform Quick Reference

## Platform Status: ✅ ALL PLATFORMS SUPPORTED

| Platform | Status | Min Version | Build Command |
|----------|--------|-------------|---------------|
| 🪟 Windows | ✅ Ready | 10/11 | `flutter build windows --release` |
| 🍎 macOS | ✅ Ready | 10.14+ | `flutter build macos --release` |
| 🐧 Linux | ✅ Ready | GTK 3.0+ | `flutter build linux --release` |
| 📱 Android | ✅ Ready | API 21+ | `flutter build apk --release` |
| 📱 iOS | ✅ Ready | 12.0+ | `flutter build ios --release` |
| 🌐 Web | ✅ Ready | Modern browsers | `flutter build web --release` |

---

## Quick Commands

### Enable All Platforms
```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter config --enable-web
```

### Check Available Devices
```bash
flutter devices
```

### Run on Platform
```bash
flutter run -d windows    # Windows
flutter run -d macos      # macOS
flutter run -d linux      # Linux
flutter run -d chrome     # Web
flutter run               # Android/iOS (auto-detect)
```

### Build Release
```bash
# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release

# Mobile
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android Bundle
flutter build ios --release        # iOS

# Web
flutter build web --release
```

---

## Platform Requirements

### Windows
- Visual Studio 2019+ with C++ tools
- Windows 10 SDK

### macOS
- Xcode 13.0+
- CocoaPods: `sudo gem install cocoapods`

### Linux
- GTK 3.0+
- Build tools: `sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev`

### Android
- Android SDK
- Android Studio or command-line tools
- Java JDK 11+

### iOS
- macOS with Xcode 13.0+
- Apple Developer account (for devices)

### Web
- Modern browser (Chrome recommended)

---

## Platform-Specific Setup

### iOS & macOS (CocoaPods)
```bash
cd ios && pod install && cd ..      # iOS
cd macos && pod install && cd ..    # macOS
```

### Android (Licenses)
```bash
flutter doctor --android-licenses
```

### Linux (Dependencies)
```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

---

## Output Locations

| Platform | Output Path |
|----------|-------------|
| Windows | `build\windows\runner\Release\iptv_casper.exe` |
| macOS | `build/macos/Build/Products/Release/iptv_casper.app` |
| Linux | `build/linux/x64/release/bundle/` |
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Android Bundle | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | `build/ios/Release-iphoneos/Runner.app` |
| Web | `build/web/` |

---

## Interactive Setup Script

Run the multi-platform setup script:
```powershell
.\setup-multiplatform.ps1
```

This provides an interactive menu for:
- Running on any platform
- Building for any platform
- Enabling platforms
- Running diagnostics

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Flutter not found | Add to PATH, restart terminal |
| Platform not enabled | Run `flutter config --enable-<platform>-desktop` |
| Build fails | Run `flutter doctor` and fix issues |
| Missing dependencies | Run `flutter pub get` |
| Android license errors | Run `flutter doctor --android-licenses` |
| iOS signing errors | Open Xcode, configure Team |
| Web CORS errors | Use backend proxy or CORS-enabled server |

---

## Documentation Files

- **MULTIPLATFORM.md** - Complete platform guide
- **MULTIPLATFORM_COMPLETE.txt** - Implementation summary
- **INSTALL.md** - Installation instructions
- **README.md** - Project overview (updated)
- **QUICKSTART.md** - Quick reference

---

## Feature Matrix

✅ = Fully Supported | ⚠️ = Limited | ➖ = Not Applicable

| Feature | Win | Mac | Lin | And | iOS | Web |
|---------|-----|-----|-----|-----|-----|-----|
| Video Player | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| M3U Parser | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Search | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Favorites | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Storage | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| File Picker | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| Fullscreen | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Testing Checklist

Before release, test on:
- [ ] Windows 10/11
- [ ] macOS (Intel & Apple Silicon)
- [ ] Linux (Ubuntu/Fedora/etc.)
- [ ] Android device (various screen sizes)
- [ ] iOS device (iPhone & iPad)
- [ ] Web browsers (Chrome, Firefox, Safari, Edge)

---

## Distribution Checklist

- [ ] Build release version
- [ ] Test on target platform
- [ ] Create installer/package (desktop)
- [ ] Generate icons (all sizes)
- [ ] Update version number
- [ ] Create release notes
- [ ] Sign code (macOS/iOS required)
- [ ] Upload to store or hosting

---

## Project Location
```
C:\Users\rekca\OneDrive\Desktop\IPTV CASPER
```

---

## Getting Started (New Developers)

1. **Clone/Download** the project
2. **Install Flutter** for your OS
3. **Run** `flutter pub get`
4. **Enable platforms** you want to support
5. **Check** `flutter doctor`
6. **Run** `.\setup-multiplatform.ps1`
7. **Select** your platform
8. **Build & Test!**

---

Happy Cross-Platform Development! 🌍✨

Last Updated: November 3, 2025
