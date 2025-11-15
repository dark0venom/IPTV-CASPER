# IPTV Casper v1.1.0 - New Features Guide

## 📺 Electronic Program Guide (EPG)

### Overview
The EPG feature provides a comprehensive TV guide showing current and upcoming programs for all your channels.

### Features
- **Current Program Display**: See what's playing right now on any channel
- **Upcoming Programs**: View the schedule for the next several hours
- **Program Details**: Access full information including:
  - Title and description
  - Start and end times
  - Duration
  - Category/genre
  - Cast and crew (when available)
  - Content rating
  - Episode information for series

### Supported Formats
- **XMLTV**: Industry-standard EPG format
- **Xtream Codes EPG API**: Automatic EPG from Xtream providers
- **JSON Format**: Custom JSON EPG data

### Using EPG
1. **Load EPG Data**:
   - Go to Settings → EPG Settings
   - Enter EPG source URL (XMLTV or Xtream Codes)
   - Click "Load EPG"

2. **View Program Guide**:
   - Press `G` key or click TV Guide button
   - Browse programs by channel
   - Click on any program for details

3. **EPG Integration**:
   - Current program shown in channel info
   - Progress bar for live programs
   - "Next Up" preview
   - Catch-up availability indicators

---

## ⏮️ Catch-up TV

### Overview
Watch previously aired programs that support time-shifting/catch-up.

### Features
- **Program Archive Access**: Watch shows that aired in the past
- **Timeline Navigation**: Jump to any point in a program
- **Watch from Start**: Restart current program from beginning
- **Integrated with EPG**: See which programs support catch-up

### How to Use Catch-up TV
1. **Check Availability**:
   - Look for catch-up icon (⏮️) on program listings
   - Catch-up enabled programs show in EPG

2. **Access Catch-up**:
   - Click on a past program in EPG
   - Select "Watch from Start" for current program
   - Use timeline to navigate within program

3. **Requirements**:
   - Provider must support catch-up/time-shift
   - EPG data must be loaded
   - Program must be within provider's catch-up window

---

## 🔴 Recording Capability

### Overview
Record live TV streams directly to your computer for later viewing.

### Features
- **Live Recording**: Record what's playing now
- **Scheduled Recording**: Set recordings based on EPG
- **Quality Selection**: Choose recording quality
  - Low (480p) - ~1GB/hour
  - Medium (720p) - ~2.5GB/hour
  - High (1080p) - ~5GB/hour
  - Original - Stream's native quality
- **Recording Library**: Manage all your recordings
- **Automatic Start/Stop**: Scheduled recordings start and stop automatically

### How to Record
1. **Record Current Program**:
   - While watching, click Record button (🔴)
   - Choose quality level
   - Recording starts immediately
   - Click Stop when finished

2. **Schedule Recording**:
   - Open EPG (TV Guide)
   - Find program to record
   - Click "Schedule Recording"
   - Select quality and confirm
   - Recording will start/stop automatically

3. **Manage Recordings**:
   - Press `R` or click Recordings button
   - View all recordings (Scheduled, Active, Completed)
   - Play completed recordings
   - Delete unwanted recordings
   - Cancel scheduled recordings

### Recording Storage
- Location: `Documents/IPTV-Casper/Recordings/`
- Format: MP4 (H.264 video, AAC audio)
- Naming: `{Program Title}_{Date-Time}.mp4`

### Requirements
- **FFmpeg**: Must be installed and in system PATH
  - Windows: Download from https://ffmpeg.org
  - Linux: `sudo apt install ffmpeg`
  - macOS: `brew install ffmpeg`
- **Disk Space**: Ensure sufficient storage for recordings
- **Stable Internet**: Required for uninterrupted recording

---

## 🌍 Multi-language Support

### Overview
IPTV Casper supports 5 languages with full UI translation.

### Supported Languages
- 🇬🇧 **English** (Default)
- 🇪🇸 **Spanish** (Español)
- 🇫🇷 **French** (Français)
- 🇩🇪 **German** (Deutsch)
- 🇸🇦 **Arabic** (العربية) - with RTL support

### Changing Language
1. Go to Settings → Language
2. Select your preferred language
3. App will update immediately
4. Setting is saved for future sessions

### Features
- **Complete Translation**: All UI elements translated
- **RTL Support**: Arabic displays right-to-left
- **Date/Time Formatting**: Localized date and time display
- **Number Formatting**: Region-appropriate number formats

---

## 🎨 Theme Customization

### Overview
Personalize IPTV Casper with beautiful themes and color schemes.

### Predefined Themes
1. **IPTV Casper (Default)**: Blue-purple gradient
2. **Modern Dark**: Indigo and teal
3. **Ocean Blue**: Deep blue oceanic theme
4. **Forest Green**: Natural green tones
5. **Sunset Orange**: Warm orange and amber
6. **Midnight Purple**: Deep purple with accents

Each theme includes:
- Light variant for daytime use
- Dark variant for nighttime viewing
- Carefully selected color palettes
- Optimized for IPTV viewing

### Applying Themes
1. Go to Settings → Theme Settings
2. Browse available themes
3. Toggle light/dark mode
4. Click "Apply" to activate
5. Changes take effect immediately

### Creating Custom Themes
1. Select "Custom Theme" option
2. Choose colors for:
   - Primary color
   - Secondary color
   - Background color
   - Surface color
   - Text colors
3. Preview your theme live
4. Save custom theme

---

## ⌨️ Keyboard Shortcuts

### Overview
Powerful keyboard shortcuts for quick access to all features.

### Default Shortcuts

#### Playback
- `Space` - Play/Pause
- `S` - Stop playback
- `↑` - Volume Up
- `↓` - Volume Down
- `M` - Mute/Unmute
- `→` - Seek Forward (10s)
- `←` - Seek Backward (10s)
- `F` - Toggle Fullscreen

#### Navigation
- `Page Down` - Next Channel
- `Page Up` - Previous Channel
- `Ctrl+F` - Search
- `Ctrl+D` - Toggle Favorites View

#### Window
- `Ctrl+P` - Toggle Picture-in-Picture
- `Ctrl+T` - Toggle Always on Top

#### General
- `G` - Toggle EPG/TV Guide
- `R` - Open Recordings
- `Ctrl+B` - Add to Favorites
- `Ctrl+,` - Open Settings

### Customizing Shortcuts
1. Go to Settings → Keyboard Shortcuts
2. Select category (Playback, Navigation, Window, General)
3. Click on shortcut to edit
4. Press new key combination
5. System checks for conflicts
6. Save changes

### Tips
- Use modifier keys (Ctrl, Shift, Alt) for complex shortcuts
- Avoid conflicting with system shortcuts
- Print quick reference guide from settings

---

## 👨‍👩‍👧 Parental Controls

### Overview
Comprehensive parental control system to manage content access.

### Features
- **PIN Protection**: Secure with 4-digit PIN code
- **Content Ratings**: Filter by age-appropriate ratings
- **Channel Blocking**: Block specific channels
- **Category Blocking**: Block entire categories
- **Time Restrictions**: Limit viewing by time and day
- **Protected Settings**: Require PIN to change settings

### Setting Up Parental Controls
1. **Enable and Create PIN**:
   - Go to Settings → Parental Controls
   - Toggle "Enable Parental Controls"
   - Create 4-digit PIN
   - Confirm PIN
   - Keep PIN secure!

2. **Configure Content Ratings**:
   - Select allowed ratings:
     - G (General Audiences)
     - PG (Parental Guidance)
     - PG-13
     - R (Restricted)
     - NC-17 (Adults Only)
   - Higher ratings automatically allow lower ratings

3. **Block Channels**:
   - Browse channel list
   - Mark channels to block
   - Blocked channels hidden from main list
   - PIN required to access

4. **Block Categories**:
   - Select categories to block (e.g., "Adult", "Horror")
   - All channels in category blocked
   - Case-insensitive matching

5. **Set Time Restrictions**:
   - Select days of week
   - Set allowed viewing hours
   - Example: Monday-Friday 6PM-9PM
   - Outside hours require PIN override

### Using Parental Controls
- **Accessing Blocked Content**: Enter PIN when prompted
- **Temporary Override**: PIN grants access until app restart
- **Change Settings**: PIN required to modify parental controls
- **Reset PIN**: Contact app settings if PIN forgotten

### Best Practices
- Use a PIN that children won't guess
- Regularly review blocked content list
- Set appropriate time limits
- Educate children about content ratings
- Periodically check viewing history

---

## 🔧 Technical Notes

### System Requirements for New Features

#### EPG
- Internet connection for EPG data download
- ~50MB storage for EPG cache
- Auto-refresh every hour

#### Recording
- FFmpeg installed and configured
- Minimum 10GB free disk space recommended
- 5Mbps+ internet for HD recording
- Windows 10/11, macOS 10.14+, or Linux

#### Multi-language
- No additional requirements
- 1MB additional storage for translations
- Instant language switching

#### Themes
- No additional requirements
- Themes stored in app preferences
- Custom themes: 100KB storage

#### Keyboard Shortcuts
- No additional requirements
- Shortcuts stored locally
- System-wide shortcuts may conflict

#### Parental Controls
- Secure encrypted storage
- PIN encrypted with AES-256
- Requires app restart after enabling

---

## 📱 Platform-Specific Notes

### Windows
- All features fully supported
- Recording requires FFmpeg in PATH
- Keyboard shortcuts respect Windows conventions

### macOS
- All features fully supported
- Recording requires FFmpeg (install via Homebrew)
- Command key used instead of Ctrl

### Linux
- All features fully supported
- Install FFmpeg via package manager
- GTK 3.0+ required

### Android
- EPG fully supported
- Recording not available (storage limitations)
- Touch gestures instead of keyboard shortcuts
- Parental controls fully supported

### iOS
- EPG fully supported
- Recording not available (iOS limitations)
- Touch gestures instead of keyboard shortcuts
- Parental controls fully supported

### Web
- EPG fully supported
- Recording not available (browser limitations)
- Limited keyboard shortcut support
- Parental controls fully supported

---

## 🆘 Troubleshooting

### EPG Not Loading
- Check internet connection
- Verify EPG URL is correct
- Try different EPG source
- Clear EPG cache and reload

### Recording Fails
- Ensure FFmpeg is installed
- Check disk space
- Verify stream supports recording
- Check error message in recordings list

### Language Not Changing
- Restart application
- Clear app cache
- Reinstall if persistent

### Theme Not Applying
- Try different theme first
- Check for app updates
- Reset to default theme

### Keyboard Shortcuts Not Working
- Check for conflicting system shortcuts
- Ensure app has focus
- Try resetting to defaults
- Check shortcut settings

### Parental Controls PIN Forgotten
- Check secure notes if saved
- May require app reinstall (last resort)
- Future update will add recovery options

---

## 📞 Support

For additional help with new features:
- Check documentation in `docs/` folder
- Visit GitHub Issues
- Join community discussions
- Email support (see README.md)

**Enjoy IPTV Casper v1.1.0!** 🎉
