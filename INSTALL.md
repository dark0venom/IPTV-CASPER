# 🚀 IPTV Casper - Installation & Setup

## ⚠️ Prerequisites Installation

### Step 1: Install Flutter SDK

#### Download Flutter
1. Visit: https://docs.flutter.dev/get-started/install/windows
2. Download the latest Flutter SDK (stable channel)
3. Extract the ZIP file to a location like `C:\src\flutter`
4. **Important**: Do NOT install Flutter in a directory that requires elevated privileges (like `C:\Program Files`)

#### Add Flutter to PATH
1. Open **Start Menu** → Search for "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables..." button
4. Under "User variables", find and select "Path", then click "Edit"
5. Click "New" and add the path to Flutter's bin directory: `C:\src\flutter\bin`
6. Click "OK" on all dialogs
7. **Restart your terminal** for changes to take effect

#### Verify Installation
Open a new PowerShell window and run:
```powershell
flutter --version
```

You should see Flutter version information.

### Step 2: Install Visual Studio (C++ Build Tools)

Flutter Windows apps require Visual Studio with C++ build tools.

#### Option 1: Install Visual Studio Community (Recommended)
1. Download from: https://visualstudio.microsoft.com/downloads/
2. During installation, select:
   - "Desktop development with C++"
   - Windows 10 SDK
3. Complete the installation (may take 30-60 minutes)

#### Option 2: Install Build Tools Only
1. Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
2. Install "Build Tools for Visual Studio 2022"
3. Select "Desktop development with C++"

### Step 3: Run Flutter Doctor

Open PowerShell and run:
```powershell
flutter doctor
```

This will check your environment and display any issues. Address any problems it finds.

Expected output should show:
- ✓ Flutter (Channel stable, version X.X.X)
- ✓ Windows Version (Windows 10 or later)
- ✓ Visual Studio (version X.X.X or later)

---

## 📦 Setup IPTV Casper

Once Flutter is installed, follow these steps:

### Step 1: Navigate to Project Directory
```powershell
cd "C:\Users\rekca\OneDrive\Desktop\IPTV CASPER"
```

### Step 2: Install Dependencies
```powershell
flutter pub get
```

### Step 3: Enable Windows Desktop
```powershell
flutter config --enable-windows-desktop
```

### Step 4: Run the Application

#### Debug Mode (for development):
```powershell
flutter run -d windows
```

#### Release Mode (optimized build):
```powershell
flutter build windows --release
```

The executable will be created at:
```
build\windows\runner\Release\iptv_casper.exe
```

---

## 🎬 Quick Start (After Installation)

### Using the PowerShell Setup Script
```powershell
.\setup.ps1
```

This automated script will:
1. Check Flutter installation
2. Install dependencies
3. Offer to run or build the application

### Manual Commands

**Install dependencies:**
```powershell
flutter pub get
```

**Run in debug mode:**
```powershell
flutter run -d windows
```

**Build release version:**
```powershell
flutter build windows --release
```

**Run tests:**
```powershell
flutter test
```

---

## 📝 Using the Application

### First Launch

1. The app will open with an empty channel list
2. Click the **+** (plus) button to add a playlist

### Add Sample Playlist

**Quick Test:**
1. Click the **+** button
2. Select "File" tab
3. Enter name: "Sample Playlist"
4. Click "Select M3U File"
5. Navigate to the project folder and select `sample_playlist.m3u`
6. Click "Add"

**From URL:**
1. Click the **+** button
2. Select "URL" tab
3. Enter a name for your playlist
4. Enter the M3U URL
5. Click "Add"

### Watch Channels

1. Browse the channel list on the left
2. Use the search box to find channels
3. Filter by category using the dropdown
4. Click any channel to start playing
5. Use player controls (play/pause, volume, fullscreen)

---

## 🔧 Troubleshooting

### Flutter Not Found
**Error**: `flutter : The term 'flutter' is not recognized...`

**Solution**:
1. Verify Flutter is installed in `C:\src\flutter` (or your chosen location)
2. Check that `C:\src\flutter\bin` is in your PATH
3. **Restart your terminal/PowerShell**
4. Run: `flutter --version`

### Visual Studio Not Found
**Error**: `Flutter doctor` shows Visual Studio issues

**Solution**:
1. Install Visual Studio with "Desktop development with C++"
2. Restart your computer
3. Run: `flutter doctor -v`

### Dependencies Failed to Install
**Error**: `flutter pub get` fails

**Solution**:
1. Check your internet connection
2. Try: `flutter pub cache repair`
3. Then: `flutter pub get`

### Video Won't Play
**Issue**: Video player shows black screen

**Solution**:
1. Verify the stream URL is accessible
2. Check your internet connection
3. Try the sample playlist first
4. Some streams may require VPN

### Build Errors
**Error**: Build fails with C++ errors

**Solution**:
1. Run: `flutter doctor -v` and fix any issues
2. Ensure Visual Studio C++ tools are installed
3. Try: `flutter clean` then `flutter pub get`
4. Rebuild: `flutter build windows`

---

## 📂 Project Structure Overview

```
IPTV CASPER/
├── lib/                    # Application source code
│   ├── main.dart          # Entry point
│   ├── models/            # Data models
│   ├── providers/         # State management
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   └── widgets/           # Reusable components
├── windows/               # Windows-specific files
├── test/                  # Unit tests
├── pubspec.yaml           # Dependencies
└── sample_playlist.m3u    # Sample playlist for testing
```

---

## 🎯 Next Steps

1. **Install Flutter** (if not already installed)
2. **Run `flutter doctor`** to verify setup
3. **Navigate to project directory**
4. **Run `flutter pub get`** to install dependencies
5. **Use `setup.ps1`** or run manually
6. **Add a playlist** and start watching!

---

## 📚 Additional Resources

- **Flutter Documentation**: https://docs.flutter.dev/
- **MediaKit Documentation**: https://pub.dev/packages/media_kit
- **Flutter Windows Desktop**: https://docs.flutter.dev/platform-integration/windows

---

## ⚡ Quick Reference Commands

```powershell
# Check Flutter
flutter --version
flutter doctor

# Project setup
cd "C:\Users\rekca\OneDrive\Desktop\IPTV CASPER"
flutter pub get

# Run application
flutter run -d windows

# Build release
flutter build windows --release

# Run tests
flutter test

# Clean build
flutter clean

# Repair dependencies
flutter pub cache repair
```

---

## 🎉 Ready to Go!

Once Flutter is installed and `flutter doctor` shows no issues, you're ready to run your IPTV player!

**Quick Launch**: Run `.\setup.ps1` and choose option 1.

Enjoy your IPTV player! 📺✨
