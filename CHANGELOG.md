# Changelog

All notable changes to IPTV Casper will be documented in this file.

## [1.0.0] - 2025-11-04

### 🎉 Initial Release

#### ✨ Features
- **IPTV Playback**
  - M3U playlist support
  - Xtream Codes API integration
  - Live TV channel streaming
  - Video on Demand (VOD)
  - TV Series and episodes support
  - Multiple stream format support (HLS, RTMP, HTTP)

- **Floating Window (Picture-in-Picture)**
  - Detached player window for multitasking
  - Always-on-top mode with pin/unpin toggle
  - Independent playback controls
  - Resizable and movable window
  - Synchronized stream updates
  - Separate process for better performance

- **User Interface**
  - Modern, intuitive design
  - Custom blue-purple gradient branding
  - Professional logo and icons
  - Responsive layout
  - Dark theme optimized for IPTV viewing
  - Quick access controls

- **Playlist Management**
  - Import M3U files from local storage
  - Load playlists from URLs
  - Xtream Codes provider setup
  - Category browsing
  - Search functionality
  - Favorites system

- **Playback Controls**
  - Play/Pause
  - Volume control
  - Seek forward/backward
  - Fullscreen mode
  - Quality selection
  - Subtitle support (where available)

#### 🎨 Branding
- Custom gradient logo (blue-purple theme)
- Professional app icons (16x16 to 1024x1024)
- Consistent visual identity across all screens
- Logo in AppBar and floating window title

#### ⚡ Performance
- Release build with optimizations
- Efficient memory management
- Hardware-accelerated video decoding
- Fast startup time
- Smooth playback

#### 🖥️ Platform Support
- Windows 10/11 (64-bit)
- Optimized for desktop experience
- Multi-monitor support
- High DPI display support

#### 📦 Technical Details
- Built with Flutter 3.35.7
- Dart 3.9.2
- Media Kit 1.1.10 for video playback
- Desktop Multi Window 0.2.1 for floating window
- Window Manager 0.3.9 for always-on-top functionality

### 🔧 Technical Improvements
- Clean architecture with Provider state management
- Modular code structure
- Comprehensive error handling
- Efficient stream management
- Cross-window communication

### 📚 Documentation
- Complete deployment guide
- Floating window implementation guide
- Logo and icon implementation guide
- User manual (README.txt)
- Developer documentation

### 🐛 Known Issues
- None reported in initial release

### 🔜 Planned Features (Future Releases)
- Electronic Program Guide (EPG) support
- Catch-up TV functionality
- Recording capability
- Multi-language support
- Advanced filtering and sorting
- Parental controls
- Theme customization
- Keyboard shortcuts configuration
- Playlist synchronization across devices

---

## Version History

### Version Format
We use [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

---

## How to Update

### For Users
1. Download the latest version from GitHub Releases
2. Extract the new files
3. Replace the old installation folder
4. Launch the application

### For Developers
```bash
# Pull latest changes
git pull origin main

# Get dependencies
flutter pub get

# Build release
flutter build windows --release

# Create production package
.\create-production-package.ps1
```

---

## Contributing

If you'd like to contribute to IPTV Casper:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## Support

- **Issues**: https://github.com/dark0venom/IPTV-CASPER/issues
- **Discussions**: https://github.com/dark0venom/IPTV-CASPER/discussions
- **Email**: [Your support email]

---

## License

[Add your license information]

---

**Thank you for using IPTV Casper!** 🚀
