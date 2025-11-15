# IPTV Casper

A modern, **professional-grade cross-platform IPTV player** built with Flutter, featuring a beautiful responsive UI, floating window support, and comprehensive Xtream Codes API integration.

## 🌍 Supported Platforms

- ✅ **Windows** (10/11) - Full desktop support with floating window
- ✅ **macOS** (10.14+) - Native experience with always-on-top
- ✅ **Linux** (GTK 3.0+) - Complete desktop features
- ✅ **Android** (5.0+) - Mobile-optimized UI
- ✅ **iOS** (12.0+) - Touch-friendly interface
- ✅ **Web** (PWA) - Browser-based access

## ✨ Key Features

### 🎬 Playback & Streaming
- 📺 **Multiple Input Sources**
  - M3U/M3U8 playlist support (URL or local file)
  - Xtream Codes API integration with authentication
  - Direct stream URL playback
- 🎥 **Content Types**
  - Live TV channels
  - Video on Demand (VOD)
  - TV Series with episode browsing
- 🎮 **Full Playback Controls**
  - Play, pause, seek, volume control
  - Fullscreen mode with auto-hide controls
  - Multiple format support (HLS, RTMP, HTTP)
  - Hardware-accelerated decoding

### 🪟 Floating Window (Picture-in-Picture)
- � **Detached Player Window** - Watch in a separate always-on-top window
- 📌 **Pin/Unpin Toggle** - Control always-on-top behavior
- 🔄 **Auto-Sync** - Automatically updates when you change channels
- 🎯 **Smart Controls** - Drag, resize, play/pause directly in floating window
- ⚙️ **Size Presets** - Small, Medium, Large, HD, or custom sizing
- 💻 **Multi-Monitor Support** - Works across all displays

### 🎨 User Interface
- � **Beautiful Themes** - Modern dark theme (default) and light theme
- � **Fully Responsive** - Adapts perfectly to any screen size
- ✨ **Smooth Animations** - Professional 60 FPS transitions
- 🎯 **Material Design 3** - Latest design guidelines
- 🖼️ **Custom Branding** - Blue-purple gradient logo and icons

### 📋 Channel Management
- 🔍 **Smart Search** - Real-time search across channels
- � **Category Filtering** - Browse by groups/categories
- ⭐ **Favorites System** - Mark and access favorite channels quickly
- 🎭 **Channel Logos** - Beautiful thumbnail previews
- 📊 **Playing Indicator** - See what's currently playing

### 💾 Data & Security
- 🔐 **Encrypted Storage** - Secure credential storage
- 💾 **Cross-Platform Persistence** - Settings and favorites saved
- 🔄 **Auto-Reconnect** - Smart connection recovery
- 📱 **Multiple Playlists** - Manage multiple IPTV providers

### 📺 Electronic Program Guide (EPG) **[NEW in v1.1.0]**
- 📅 **Full EPG Support** - XMLTV and Xtream Codes EPG integration
- 🎬 **Program Information** - Current and upcoming shows with descriptions
- ⏱️ **Live Progress** - Real-time progress bars for current programs
- 📖 **Program Details** - Episode info, cast, ratings, and more
- ⏮️ **Catch-up Indicators** - See which programs support time-shifting

### 🔴 Recording & Catch-up **[NEW in v1.1.0]**
- ⏺️ **Stream Recording** - Record live TV to local files
- 📅 **Scheduled Recording** - EPG-based automatic recording
- 🎥 **Quality Selection** - Choose from Low, Medium, High, or Original quality
- 📼 **Recording Library** - Manage and playback your recordings
- ⏮️ **Catch-up TV** - Watch previously aired programs
- 🕐 **Time-shift** - Rewind to program start

### 🌍 Multi-language Support **[NEW in v1.1.0]**
- 🇬🇧 **English** - Full UI translation
- 🇪🇸 **Spanish** - Traducción completa
- 🇫🇷 **French** - Traduction complète
- 🇩🇪 **German** - Vollständige Übersetzung
- 🇸🇦 **Arabic** - ترجمة كاملة مع دعم RTL
- 🔄 **Easy Switching** - Change language on the fly

### 🎨 Theme Customization **[NEW in v1.1.0]**
- 🌈 **6 Theme Presets** - IPTV Casper, Modern Dark, Ocean, Forest, Sunset, Midnight
- 🎨 **Custom Themes** - Create your own color schemes
- 🌓 **Light & Dark** - Each theme has light and dark variants
- 👁️ **Live Preview** - See themes before applying

### ⌨️ Keyboard Shortcuts **[NEW in v1.1.0]**
- ⚡ **Fully Configurable** - Customize all keyboard shortcuts
- 🎮 **Default Shortcuts** - Intuitive defaults for playback, navigation, window control
- 🔧 **Visual Editor** - Easy-to-use shortcut configuration
- 📝 **Quick Reference** - Built-in shortcut guide

### 👨‍👩‍👧 Parental Controls **[NEW in v1.1.0]**
- 🔒 **PIN Protection** - Secure with 4-digit PIN
- 🎬 **Content Ratings** - Filter by G, PG, PG-13, R, NC-17
- 🚫 **Channel Blocking** - Block specific channels or categories
- ⏰ **Time Restrictions** - Limit viewing times by day of week
- 🔐 **Protected Settings** - Require PIN for settings access

## 🚀 Quick Start

### For Users (Pre-built Release)
1. Download the latest release from [GitHub Releases](https://github.com/dark0venom/IPTV-CASPER/releases)
2. Extract the archive
3. Run `iptv_casper.exe` (Windows) or the appropriate executable for your platform
4. Add your IPTV playlist or Xtream Codes credentials
5. Start watching!

### For Developers

#### Prerequisites
- **Flutter SDK** (>=3.0.0, recommended 3.35.7+)
- **Dart** (>=3.0.0, recommended 3.9.2+)
- Platform-specific requirements:
  - **Windows**: Windows 10/11, Visual Studio 2019 or later
  - **macOS**: macOS 10.14+, Xcode 12.0+
  - **Linux**: GTK 3.0+, appropriate build tools
  - **Android**: Android Studio, Android SDK (API 21+)
  - **iOS**: Xcode, CocoaPods

#### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/dark0venom/IPTV-CASPER.git
   cd IPTV-CASPER
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on your platform**
   ```bash
   # Windows
   flutter run -d windows
   
   # macOS
   flutter run -d macos
   
   # Linux
   flutter run -d linux
   
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   ```

### 📺 How to Use

1. **Add a Playlist**
   - Click "Add Playlist" button
   - Choose input method:
     - **M3U URL**: Enter playlist URL
     - **M3U File**: Import local file
     - **Xtream Codes**: Enter server URL, username, and password

2. **Browse Content**
   - Browse Live TV, VOD, or Series tabs
   - Use search to find specific channels
   - Filter by category/group
   - Mark favorites with ⭐

3. **Watch Content**
   - Click any channel to start playback
   - Use player controls (play/pause, volume, seek)
   - Press `F` or click fullscreen button for immersive mode

4. **Use Floating Window** (Desktop only)
   - Click Picture-in-Picture button (📺) in toolbar
   - Floating window appears with always-on-top enabled
   - Drag title bar to move, resize from corner
   - Click pin (📌) to toggle always-on-top
   - Window auto-updates when you change channels

## 🏗️ Building for Production

### Desktop Platforms

#### Windows
```powershell
# Build release
flutter build windows --release

# Create production package (includes installer)
.\create-production-package.ps1
```

The installer will be in `installer-output/` directory.

#### macOS
```bash
flutter build macos --release
```

#### Linux
```bash
flutter build linux --release
```

### Mobile Platforms

#### Android
```bash
# APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

See [MULTIPLATFORM.md](MULTIPLATFORM.md) for detailed build instructions and [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md) for deployment guides.

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick setup guide
- **[FLOATING_WINDOW_GUIDE.md](FLOATING_WINDOW_GUIDE.md)** - Floating window feature documentation
- **[GUI_FEATURES.md](GUI_FEATURES.md)** - UI/UX feature overview
- **[MULTIPLATFORM.md](MULTIPLATFORM.md)** - Platform-specific setup
- **[XTREAM_CODES_API_REFERENCE.md](XTREAM_CODES_API_REFERENCE.md)** - API integration guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and updates
- **[PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)** - Deployment guide

## 🛠️ Tech Stack

- **Framework**: Flutter 3.35.7+
- **Language**: Dart 3.9.2+
- **Video Player**: Media Kit 1.1.10
- **State Management**: Provider + Riverpod
- **Storage**: Shared Preferences, Secure Storage
- **HTTP Client**: Dio 5.4.0
- **Window Management**: Window Manager, Desktop Multi Window
- **Encryption**: Encrypt 5.0.3

## 📊 Project Statistics

- **Version**: 1.1.0
- **Lines of Code**: 15,000+ (estimated)
- **Platforms**: 6 (Windows, macOS, Linux, Android, iOS, Web)
- **Features**: 45+ major features
- **Dependencies**: 23+ packages
- **Languages**: 5 (English, Spanish, French, German, Arabic)
- **Themes**: 6 predefined + custom
- **Documentation**: 15+ comprehensive guides

## 🎯 Roadmap

### Current Release (v1.1.0) **[LATEST]**
- ✅ Cross-platform IPTV playback
- ✅ Xtream Codes API integration
- ✅ Floating window with always-on-top
- ✅ Responsive UI for all screen sizes
- ✅ Dark/Light theme support
- ✅ Favorites and search
- ✅ VOD and Series support
- ✅ **Electronic Program Guide (EPG)**
- ✅ **Catch-up TV functionality**
- ✅ **Recording capability**
- ✅ **Multi-language support (5 languages)**
- ✅ **Theme customization (6 presets + custom)**
- ✅ **Keyboard shortcuts configuration**
- ✅ **Parental controls**

### Planned Features (v1.2.0+)
- ☁️ Cloud sync for settings and favorites
- 🔌 Plugin system for extensions
- 📊 Advanced statistics and analytics
- 🎯 Recommended content based on viewing history
- 🌐 More language translations
- 📱 Mobile-specific features (gestures, notifications)
- 🎭 Channel grouping and custom categories
- 📻 Radio station support
- 🔄 Automatic playlist updates

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🐛 Bug Reports & Feature Requests

- **Issues**: [GitHub Issues](https://github.com/dark0venom/IPTV-CASPER/issues)
- **Discussions**: [GitHub Discussions](https://github.com/dark0venom/IPTV-CASPER/discussions)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Media Kit for cross-platform video playback
- All contributors and users of IPTV Casper

## 📧 Contact

- **Repository**: [https://github.com/dark0venom/IPTV-CASPER](https://github.com/dark0venom/IPTV-CASPER)
- **Owner**: dark0venom

---

<div align="center">

**Made with ❤️ using Flutter**

*One codebase. All platforms. Beautiful experience.*

[![Flutter](https://img.shields.io/badge/Flutter-3.35.7+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.txt)
[![Platform](https://img.shields.io/badge/Platform-Windows%20|%20macOS%20|%20Linux%20|%20Android%20|%20iOS%20|%20Web-blue)]()

</div>
