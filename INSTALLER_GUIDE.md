# 📦 IPTV Casper - Windows Installer Guide

## ✅ Installer Created Successfully!

You now have a professional Windows installer for IPTV Casper with all the features users expect from commercial software.

---

## 📋 What's Included

### Installer Features
✅ **Professional wizard interface** - Modern Windows installer UI  
✅ **Custom branding** - App icon and visual identity  
✅ **Start Menu integration** - Shortcuts and program group  
✅ **Desktop icon** - Optional desktop shortcut  
✅ **File associations** - Associate .m3u and .m3u8 files  
✅ **Uninstaller** - Clean removal from Windows  
✅ **Documentation** - Includes guides and changelog  
✅ **License agreement** - MIT license display  
✅ **System requirements check** - Validates Windows 10/11  

### Installation Options
- Choose installation directory
- Create desktop shortcut (optional)
- Associate playlist files with IPTV Casper
- Launch app after installation

---

## 🚀 Quick Start

### Build the Installer

```powershell
# Automated build (recommended)
.\build-installer.ps1

# Or manually with Inno Setup
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\setup.iss
```

### Test the Installer

```powershell
# Run the installer
.\installer\output\IPTV-Casper-Setup-v1.0.0.exe
```

---

## 📦 Prerequisites

### 1. Inno Setup (Free)

**Download:** https://jrsoftware.org/isdl.php

**Installation:**
1. Download Inno Setup 6.x (latest stable version)
2. Run the installer
3. Use default installation settings
4. No additional components needed

**Why Inno Setup?**
- Free and open-source
- Professional-looking installers
- Small installer size (~2MB overhead)
- Easy to use and customize
- Widely trusted in the Windows community

### 2. Production Build

Make sure you have a release build ready:

```powershell
flutter build windows --release
.\create-production-package.ps1
```

---

## 📁 File Structure

```
IPTV CASPER/
├── installer/
│   ├── setup.iss              ← Inno Setup script
│   ├── info_before.txt        ← Pre-installation info
│   ├── info_after.txt         ← Post-installation info
│   └── output/
│       └── IPTV-Casper-Setup-v1.0.0.exe  ← Final installer
│
├── production-release/        ← Source files for installer
├── assets/images/
│   ├── app_icon.png          ← PNG icon
│   └── app_icon.ico          ← ICO icon (for installer)
│
├── LICENSE.txt               ← License agreement
├── build-installer.ps1       ← Automated build script
└── convert_icon_to_ico.py    ← Icon converter
```

---

## 🔧 Customization

### Modify Installer Settings

Edit `installer/setup.iss`:

```iss
; Change app information
#define MyAppName "IPTV Casper"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "your-name"
#define MyAppURL "your-website"

; Customize installation
DefaultDirName={autopf}\{#MyAppName}  ; Installation folder
DefaultGroupName={#MyAppName}          ; Start Menu group
SetupIconFile=..\assets\images\app_icon.ico  ; Installer icon
```

### Add Custom Pages

The script includes examples of custom pages and checks. You can add:
- Welcome pages with images
- Custom installation options
- Component selection
- Pre/post-installation tasks

### File Associations

Currently associates .m3u and .m3u8 files. To add more:

```iss
[Registry]
Root: HKCR; Subkey: ".yourext"; ValueType: string; ValueName: ""; 
  ValueData: "IPTVCasperFile"; Tasks: fileassoc
```

---

## 🎨 Branding

### Custom Wizard Images (Optional)

You can add custom images to the installer:

1. **WizardImageFile** (164x314 pixels) - Left side of wizard
2. **WizardSmallImageFile** (55x55 pixels) - Top-right corner

Create images and update `setup.iss`:

```iss
WizardImageFile=installer\wizard-image.bmp
WizardSmallImageFile=installer\wizard-small-image.bmp
```

### Icon Requirements

- **Format:** ICO (multiple sizes in one file)
- **Sizes:** 16x16, 32x32, 48x48, 256x256
- **Automatically created** by `convert_icon_to_ico.py`

---

## 🧪 Testing

### Test Checklist

Before distributing, test the installer:

#### Installation Testing
- [ ] Install on clean Windows 10 machine
- [ ] Install on clean Windows 11 machine
- [ ] Test with different installation paths
- [ ] Verify Start Menu shortcuts work
- [ ] Check desktop icon (if selected)
- [ ] Test file associations (.m3u files open in app)
- [ ] Verify all files are installed correctly

#### Application Testing
- [ ] App launches after installation
- [ ] All features work (playlists, playback, floating window)
- [ ] No missing DLLs or dependencies
- [ ] Settings are saved correctly
- [ ] Documentation is accessible

#### Uninstallation Testing
- [ ] Uninstaller runs correctly
- [ ] All files are removed
- [ ] Start Menu shortcuts removed
- [ ] Desktop icon removed
- [ ] Registry entries cleaned up
- [ ] Optional: Keep user settings works

### Virtual Machine Testing

**Recommended:** Test on a VM to simulate end-user environment

1. **Download Windows VM:**
   - https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/

2. **VM Software:**
   - VirtualBox (free): https://www.virtualbox.org/
   - VMware Player (free): https://www.vmware.com/

3. **Testing Steps:**
   - Copy installer to VM
   - Run installer
   - Test all features
   - Uninstall
   - Verify cleanup

---

## 🔒 Code Signing (Optional)

### Why Sign the Installer?

✅ Removes "Unknown Publisher" warning  
✅ Prevents SmartScreen blocks  
✅ Builds user trust  
✅ Professional appearance  
✅ Required for some distribution channels  

### How to Sign

**1. Get a Code Signing Certificate**

Providers:
- **SSL.com** - $84/year (affordable)
- **Sectigo** - $199/year (popular)
- **DigiCert** - $474/year (premium)

**2. Sign the Installer**

```powershell
# Using SignTool (Windows SDK)
$certPath = "path\to\certificate.pfx"
$certPass = "your-password"
$installer = "installer\output\IPTV-Casper-Setup-v1.0.0.exe"

signtool sign /f $certPath /p $certPass `
  /t "http://timestamp.digicert.com" `
  /fd SHA256 `
  /d "IPTV Casper Setup" `
  $installer

# Verify signature
signtool verify /pa $installer
```

**3. Sign Multiple Files**

You can sign both:
- The main executable (`iptv_casper.exe`)
- The installer (`IPTV-Casper-Setup-v1.0.0.exe`)

### Signing in Inno Setup

You can automate signing within the installer script:

```iss
[Setup]
SignTool=standard /f "cert.pfx" /p "password" /t "timestamp-url" $f
SignedUninstaller=yes
```

---

## 📤 Distribution

### Option 1: GitHub Releases (Recommended)

**Upload the installer to GitHub Releases:**

1. Go to: https://github.com/dark0venom/IPTV-CASPER/releases
2. Click "Draft a new release"
3. Create tag: `v1.0.0`
4. Upload: `IPTV-Casper-Setup-v1.0.0.exe`
5. Add release notes:

```markdown
# IPTV Casper v1.0.0 - Initial Release

## Windows Installer
Download: [IPTV-Casper-Setup-v1.0.0.exe](link)

**What's New:**
- Initial release with full IPTV functionality
- Floating window with always-on-top
- M3U and Xtream Codes support
- Professional installer with Start Menu integration

**System Requirements:**
- Windows 10 or 11 (64-bit)
- 4GB RAM minimum

**Installation:**
1. Download the installer
2. Run IPTV-Casper-Setup-v1.0.0.exe
3. Follow the installation wizard
4. Launch from Start Menu or Desktop
```

### Option 2: Direct Download

Host the installer on your website:

```html
<a href="IPTV-Casper-Setup-v1.0.0.exe" download>
  Download IPTV Casper v1.0.0 for Windows
</a>
```

### Option 3: Microsoft Store

For Store distribution, you'll need to:
1. Convert installer to MSIX package
2. Submit to Partner Center
3. Pass certification

**Not covered in this guide** - Requires separate setup

---

## 📊 Installer Comparison

### Installer vs. ZIP Package

| Feature | Installer | ZIP Package |
|---------|-----------|-------------|
| **Ease of Use** | ✅ One-click install | Manual extraction |
| **Start Menu** | ✅ Automatic | Manual shortcuts |
| **Uninstaller** | ✅ Included | Manual deletion |
| **File Associations** | ✅ Automatic | Manual setup |
| **Updates** | Can prompt for update | Manual replacement |
| **Professional** | ✅ Very professional | Less professional |
| **Size** | +2MB overhead | Smaller |
| **Portability** | Installed to system | ✅ Fully portable |

**Recommendation:** Offer both options:
- **Installer** for most users (easier)
- **ZIP** for portable/advanced users

---

## 🔧 Advanced Features

### Auto-Update Checking

Add update checking to your app:

```dart
// In your Flutter app
Future<void> checkForUpdates() async {
  final latestVersion = await fetchLatestVersion();
  if (isNewerVersion(latestVersion, currentVersion)) {
    showUpdateDialog();
  }
}
```

Then in the installer, you can:
- Check for updates on launch
- Prompt user to download new version
- Link to download page

### Silent Installation

Users can install silently (useful for IT deployment):

```powershell
# Silent install with default options
IPTV-Casper-Setup-v1.0.0.exe /SILENT

# Very silent (no progress window)
IPTV-Casper-Setup-v1.0.0.exe /VERYSILENT

# Silent with custom directory
IPTV-Casper-Setup-v1.0.0.exe /SILENT /DIR="C:\MyApps\IPTVCasper"
```

### Upgrade Detection

The installer automatically detects previous installations:
- Prompts to upgrade or install fresh
- Preserves user settings during upgrade
- Updates only changed files

---

## 🐛 Troubleshooting

### Common Issues

**1. "Inno Setup not found"**
- Install Inno Setup from: https://jrsoftware.org/isdl.php
- Ensure it's installed in the default location

**2. "Production build not found"**
```powershell
flutter build windows --release
.\create-production-package.ps1
```

**3. "Icon file not found"**
```powershell
python convert_icon_to_ico.py
```

**4. "File not found" errors during compilation**
- Check paths in `setup.iss`
- Ensure all referenced files exist
- Use relative paths from script location

**5. Installer size is too large**
- Normal: ~35-40MB (includes all dependencies)
- Use `Compression=lzma2/max` for best compression
- Already configured in the script

### Build Errors

If compilation fails:

1. **Open setup.iss in Inno Setup IDE**
```powershell
"C:\Program Files (x86)\Inno Setup 6\Compil32.exe" installer\setup.iss
```

2. **Check the error message** - Usually points to the problem line

3. **Common fixes:**
   - Fix file paths
   - Check syntax
   - Verify all files exist
   - Review line numbers in error

---

## 📝 Maintenance

### Updating for New Versions

**1. Update Version Number**

Edit `installer/setup.iss`:
```iss
#define MyAppVersion "1.1.0"  ; Change version
```

**2. Update Changelog**

Add release notes to:
- `CHANGELOG.md`
- `installer/info_after.txt`

**3. Rebuild**

```powershell
# Build new release
flutter build windows --release

# Build new installer
.\build-installer.ps1
```

**4. Distribute**

Upload new installer as a new GitHub release.

---

## 📚 Additional Resources

### Inno Setup Documentation
- Official docs: https://jrsoftware.org/ishelp/
- Script examples: https://jrsoftware.org/isinfo.php
- Community forums: https://groups.google.com/g/innosetup

### Best Practices
- Always test on clean machine before release
- Sign your installers for better trust
- Provide both installer and ZIP versions
- Include comprehensive release notes
- Version your installers clearly
- Keep installer size reasonable

---

## ✅ Checklist: Ready to Distribute

Before releasing your installer:

### Pre-Release
- [ ] Production build tested and working
- [ ] Installer builds without errors
- [ ] Icon displays correctly
- [ ] License agreement is correct
- [ ] Version numbers are updated
- [ ] Documentation is included
- [ ] Release notes are written

### Testing
- [ ] Tested on clean Windows 10 machine
- [ ] Tested on clean Windows 11 machine
- [ ] All features work after installation
- [ ] Start Menu shortcuts work
- [ ] Desktop icon works (if selected)
- [ ] File associations work
- [ ] Uninstaller removes everything correctly
- [ ] No DLL or dependency errors

### Distribution
- [ ] Installer uploaded to GitHub Releases
- [ ] Release notes published
- [ ] Download links working
- [ ] (Optional) Installer is code-signed
- [ ] Changelog updated
- [ ] Social media announcement prepared

---

## 🎉 Success!

You now have a professional Windows installer for IPTV Casper!

**What you've achieved:**
✅ Professional installation experience  
✅ Windows integration (Start Menu, file associations)  
✅ Easy distribution and updates  
✅ Uninstaller for clean removal  
✅ Industry-standard packaging  

**Your installer includes:**
- Modern wizard interface
- Custom branding
- License agreement
- System requirements checking
- Documentation
- Uninstaller
- File associations

**Ready to share with the world!** 🚀

---

## 📞 Support

For installer issues:
- Check this guide first
- Review Inno Setup documentation
- Test in a clean VM
- Check file paths and permissions

For app issues:
- See other documentation files
- Report on GitHub Issues
- Check CHANGELOG.md

**Repository:** https://github.com/dark0venom/IPTV-CASPER
