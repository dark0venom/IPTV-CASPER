# Quick Reference Card - IPTV Casper

## 🚀 First-Time Setup

### 1. Install Flutter
Download: https://docs.flutter.dev/get-started/install/windows
- Extract to `C:\src\flutter`
- Add `C:\src\flutter\bin` to PATH
- Restart terminal

### 2. Install Visual Studio
Download: https://visualstudio.microsoft.com/downloads/
- Select "Desktop development with C++"
- Install Windows 10 SDK

### 3. Verify Installation
```powershell
flutter doctor
```

## ⚡ Quick Commands

```powershell
# Navigate to project
cd "C:\Users\rekca\OneDrive\Desktop\IPTV CASPER"

# Install dependencies
flutter pub get

# Run application (Debug)
flutter run -d windows

# Build application (Release)
flutter build windows --release

# Run automated setup
.\setup.ps1
```

## 📺 Using the App

### Add Playlist
1. Click **+** button
2. Choose **URL** or **File**
3. Enter name and source
4. Click **Add**

### Watch Channels
1. Browse list on left
2. Search or filter
3. Click channel to play
4. Use controls (play, pause, volume, fullscreen)

### Manage Favorites
- Click **★** next to channel
- Click filter **★** to show favorites only

## 🎮 Keyboard Shortcuts
- **Space**: Play/Pause
- **F**: Fullscreen
- **M**: Mute
- **Esc**: Exit fullscreen

## 📁 File Locations

**Executable (Release):**
```
build\windows\runner\Release\iptv_casper.exe
```

**Sample Playlist:**
```
sample_playlist.m3u
```

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Flutter not found | Add to PATH, restart terminal |
| Build fails | Run `flutter doctor`, fix issues |
| Video won't play | Check URL, internet connection |
| No channels | Add playlist using + button |

## 📚 Documentation Files

- `INSTALL.md` - Detailed installation guide
- `SETUP.md` - Application usage guide
- `IMPLEMENTATION_GUIDE.md` - Technical details
- `README.md` - Project overview

## 🎯 Getting Help

1. Check `INSTALL.md` for setup issues
2. Run `flutter doctor -v` for diagnostics
3. Try sample playlist first
4. Check console for error messages

---

**Current Directory:**
```
C:\Users\rekca\OneDrive\Desktop\IPTV CASPER
```

**Sample URL to test:**
```
https://iptv-org.github.io/iptv/index.m3u
```

Have fun watching! 🎬
