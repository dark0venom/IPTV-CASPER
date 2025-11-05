# Custom Logo and Icon Implementation Guide

## Overview

This guide will help you add custom logos and icons to IPTV Casper for a professional, branded appearance across all platforms.

## 📦 What You Need

### Logo Files (for in-app use)
- **App Logo**: PNG format, transparent background
  - Recommended sizes: 512x512px, 256x256px, 128x128px
  - Location: `assets/images/logo.png`
  
### Icon Files (for application icon)
- **Windows**: `.ico` file with multiple sizes (16x16, 32x32, 48x48, 256x256)
- **Android**: PNG files in various densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS**: PNG files in various sizes (20x20 to 1024x1024)
- **macOS**: `.icns` file
- **Linux**: PNG file (512x512px recommended)

## 🎨 Design Recommendations

### Logo Design Guidelines
- **Theme**: TV/IPTV related (antenna, screen, play button, etc.)
- **Colors**: Use your brand colors (suggested: blue/purple gradient for modern look)
- **Style**: Modern, clean, recognizable at small sizes
- **Format**: Vector-based (SVG) for scalability, export to PNG

### Suggested Logo Concepts for IPTV Casper
1. **TV with Ghost**: A TV screen with a friendly ghost icon (Casper theme)
2. **Signal Waves**: Antenna or signal waves forming a play button
3. **Modern TV Icon**: Stylized flat-screen TV with streaming elements
4. **C Letter**: Stylized "C" incorporating TV/streaming elements

## 📁 File Structure

```
iptv_casper/
├── assets/
│   └── images/
│       ├── logo.png              # Main app logo (512x512)
│       ├── logo_small.png        # Small logo (128x128)
│       ├── splash_logo.png       # Splash screen logo
│       └── app_icon.png          # Base icon for generation
├── windows/
│   └── runner/
│       └── resources/
│           └── app_icon.ico      # Windows application icon
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── res/
│                   ├── mipmap-mdpi/
│                   ├── mipmap-hdpi/
│                   ├── mipmap-xhdpi/
│                   ├── mipmap-xxhdpi/
│                   └── mipmap-xxxhdpi/
├── ios/
│   └── Runner/
│       └── Assets.xcassets/
│           └── AppIcon.appiconset/
└── macos/
    └── Runner/
        └── Assets.xcassets/
            └── AppIcon.appiconset/
```

## 🚀 Quick Setup Steps

### Step 1: Create Your Logo

**Option A: Use a design tool**
- Figma, Adobe Illustrator, Inkscape
- Design at 512x512px or larger
- Export as PNG with transparent background

**Option B: Use an AI tool**
- DALL-E, Midjourney, Stable Diffusion
- Prompt: "Modern IPTV streaming app logo, ghost theme, flat design, blue and purple gradient, transparent background"

**Option C: Hire a designer**
- Fiverr, 99designs, Upwork
- Budget: $20-$100 for a professional logo

### Step 2: Prepare Icon Files

Use **flutter_launcher_icons** package (already added below):

```yaml
# In pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
  windows:
    generate: true
    image_path: "assets/images/app_icon.png"
    icon_size: 256
  macos:
    generate: true
    image_path: "assets/images/app_icon.png"
  linux:
    generate: true
    image_path: "assets/images/app_icon.png"
```

### Step 3: Add Logo to Assets

1. Place your logo file in `assets/images/logo.png`
2. Update `pubspec.yaml` to include the asset
3. Use it in your app

### Step 4: Generate Icons

Run the following command:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This automatically generates all platform-specific icons!

## 💻 Using Logo in Your App

### Main App Bar Logo

```dart
// In your AppBar
AppBar(
  leading: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.asset(
      'assets/images/logo.png',
      width: 32,
      height: 32,
    ),
  ),
  title: const Text('IPTV Casper'),
)
```

### Splash Screen Logo

```dart
// Create a splash screen widget
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash_logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'IPTV Casper',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

### Floating Window Logo

```dart
// In detached_player_entry.dart title bar
Row(
  children: [
    Image.asset(
      'assets/images/logo_small.png',
      width: 20,
      height: 20,
    ),
    const SizedBox(width: 8),
    const Text('IPTV Casper'),
  ],
)
```

## 🎨 Creating a Simple Logo with Code

If you want to create a simple logo programmatically:

```dart
// lib/widgets/app_logo.dart
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AppLogo({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor,
            logoColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: logoColor.withOpacity(0.3),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // TV screen
          Center(
            child: Container(
              width: size * 0.7,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
            ),
          ),
          // Play button
          Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: size * 0.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Platform-Specific Configuration

### Windows Icon (Manual Method)

1. **Create ICO file**:
   - Use online tool: https://icoconvert.com/
   - Upload your PNG (512x512)
   - Select sizes: 16, 32, 48, 256
   - Download as `app_icon.ico`

2. **Place in project**:
   ```
   windows/runner/resources/app_icon.ico
   ```

3. **Update Runner.rc**:
   ```cpp
   // In windows/runner/Runner.rc
   IDI_APP_ICON ICON "resources\\app_icon.ico"
   ```

### Android Icon

Generated automatically by flutter_launcher_icons, or manually:
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

### iOS Icon

Generated automatically, or use Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select `Runner` > `Assets.xcassets` > `AppIcon`
3. Drag and drop icon files

## 📝 Best Practices

### Icon Design
✅ **DO:**
- Use simple, recognizable shapes
- Ensure visibility at 16x16px
- Use consistent color scheme
- Test on light and dark backgrounds
- Export at 2x resolution for sharpness

❌ **DON'T:**
- Use too much detail (won't scale well)
- Use thin lines (< 2px)
- Use small text
- Use photos or gradients (for icons)

### Logo Design
✅ **DO:**
- Keep it professional
- Use brand colors consistently
- Make it memorable
- Ensure readability at small sizes
- Use transparent background (PNG)

❌ **DON'T:**
- Use copyrighted images
- Make it too complex
- Use more than 3-4 colors
- Forget mobile viewing sizes

## 🎯 Sample Logo Designs

### Design 1: TV Ghost Logo
```
A stylized TV screen with a friendly ghost face inside
Colors: Blue (#2196F3) and Purple (#9C27B0) gradient
Style: Flat, modern, minimalist
```

### Design 2: Signal Logo
```
Concentric signal waves forming a "C" shape
Colors: Teal (#00BCD4) to Indigo (#3F51B5)
Style: Tech-inspired, clean lines
```

### Design 3: Play TV Logo
```
Triangle play button inside a TV frame
Colors: Red (#F44336) to Orange (#FF9800)
Style: Bold, instantly recognizable
```

## 🔍 Testing Your Logo

### Visual Test Checklist
- [ ] Looks good at 512x512 (large)
- [ ] Recognizable at 48x48 (medium)
- [ ] Still visible at 16x16 (small)
- [ ] Works on white background
- [ ] Works on black background
- [ ] Works on colored backgrounds
- [ ] Transparent edges clean
- [ ] No jagged edges

### In-App Test Checklist
- [ ] AppBar logo displays correctly
- [ ] Splash screen logo centered
- [ ] Floating window icon visible
- [ ] Windows taskbar icon clear
- [ ] App list icon recognizable

## 📚 Resources

### Design Tools (Free)
- **Figma**: https://figma.com
- **Canva**: https://canva.com
- **GIMP**: https://gimp.org
- **Inkscape**: https://inkscape.org

### Icon Generators
- **Icon Generator**: https://icon.kitchen
- **ICO Converter**: https://icoconvert.com
- **App Icon Generator**: https://appicon.co

### Stock Icons/Graphics
- **Flaticon**: https://flaticon.com
- **Icons8**: https://icons8.com
- **Font Awesome**: https://fontawesome.com

## 🚀 Quick Start with Placeholder

If you want to start immediately with a placeholder:

1. Create a simple gradient logo using the AppLogo widget above
2. Take a screenshot at 512x512
3. Use it as your base icon
4. Replace with professional logo later

## 📦 Example pubspec.yaml Configuration

```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/images/logo.png
    - assets/images/logo_small.png
    - assets/images/splash_logo.png
```

---

**Next Steps:**
1. Design or obtain your logo/icon
2. Place files in correct directories
3. Run `flutter pub run flutter_launcher_icons`
4. Rebuild your app
5. Test on all platforms

For professional branding, consider hiring a designer. A good logo is a one-time investment that significantly impacts your app's identity!
