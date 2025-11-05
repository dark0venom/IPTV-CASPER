# Floating Window (Always on Top) Implementation

## Overview

IPTV Casper now includes a **floating window feature** for Windows, macOS, and Linux that allows you to watch IPTV streams in a separate, always-on-top window that stays visible even when you're working in other applications.

## Features

### ✨ Key Features

- **Always on Top**: Window stays above all other windows by default
- **Draggable**: Move the window by dragging the title bar
- **Resizable**: Resize from the bottom-right corner (maintains 16:9 aspect ratio)
- **Toggle Always-on-Top**: Pin/unpin button to toggle always-on-top behavior
- **Playback Controls**: Play/pause directly from the floating window
- **Automatic Updates**: When you select a new channel, the floating window automatically updates
- **Independent**: Separate process/window - works even if main window is minimized

### 🎮 Controls

#### Title Bar Controls
- **Drag Handle**: Click and drag anywhere on the title bar to move the window
- **Pin Button** (📌): Toggle always-on-top behavior
  - Green pin = Always on top enabled
  - Gray pin = Always on top disabled
- **Play/Pause Button**: Control playback
- **Close Button**: Close the floating window

#### Resize Handle
- **Bottom-Right Corner**: Click and drag to resize
- Automatically maintains 16:9 aspect ratio

## How to Use

### Opening a Floating Window

1. **Select a Channel**: First, select a channel from your playlist
2. **Click Detach Button**: In the main window toolbar, click the Picture-in-Picture icon (📺)
3. **Floating Window Opens**: A new window will open with your stream, always on top

### Switching Channels

- Simply select a different channel in the main window
- The floating window will automatically update to show the new channel

### Closing the Floating Window

- Click the **X** button in the floating window title bar
- Or click the **Detach** button again in the main window toolbar

## Settings

### Accessing Floating Window Settings

1. Open **Settings** from the main window
2. Scroll to the **Floating Window** section
3. Configure your preferences:
   - Default window size
   - Quick size presets (Small, Medium, Large, HD)
   - Apply size to current floating window
   - Focus/close floating window

### Size Presets

- **Small**: 320×180 pixels
- **Medium**: 480×270 pixels (default)
- **Large**: 640×360 pixels
- **HD**: 854×480 pixels

### Custom Size

- Use the **Width** and **Height** sliders to set custom dimensions
- Sizes automatically maintain 16:9 aspect ratio
- Range: 320×180 to 1280×720 pixels

## Technical Details

### Architecture

The floating window implementation uses:

- **desktop_multi_window**: Creates separate window processes
- **window_manager**: Controls window properties (always-on-top, size, position)
- **media_kit**: Handles video playback in the separate window
- **Flutter Provider**: Synchronizes state between main and floating windows

### File Structure

```
lib/
├── services/
│   └── floating_window_service.dart      # Service for managing floating windows
├── windows/
│   └── detached_player_entry.dart        # Entry point for floating window
├── widgets/
│   └── floating_window_settings.dart     # Settings UI widget
├── providers/
│   └── player_provider.dart              # Updated to support floating windows
└── screens/
    └── home_screen.dart                  # Updated with floating window controls
```

### Key Components

#### FloatingWindowService

Located in `lib/services/floating_window_service.dart`

Methods:
- `openFloatingWindow()`: Creates and displays a new floating window
- `closeFloatingWindow()`: Closes the floating window
- `updateStream()`: Updates the stream in an existing floating window
- `resizeFloatingWindow()`: Changes the window size
- `moveFloatingWindow()`: Moves the window to a specific position
- `focusFloatingWindow()`: Brings the window to front

#### DetachedPlayerEntry

Located in `lib/windows/detached_player_entry.dart`

This is the entry point for the floating window process. It:
- Initializes MediaKit for video playback
- Configures window properties (always-on-top by default)
- Handles video player lifecycle
- Listens for messages from the main window
- Provides UI controls in the window

## Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| Windows  | ✅ Yes    | Full support with native always-on-top |
| macOS    | ✅ Yes    | Full support |
| Linux    | ✅ Yes    | Full support |
| Android  | ❌ No     | Use PIP mode instead |
| iOS      | ❌ No     | Use PIP mode instead |
| Web      | ❌ No     | Not applicable |

## Troubleshooting

### Window Not Appearing

**Problem**: Floating window doesn't open when clicking the detach button.

**Solutions**:
1. Make sure you've selected a channel first
2. Check that the stream URL is valid
3. Look for error messages in the console
4. Try closing and reopening the application

### Window Not Staying on Top

**Problem**: Floating window goes behind other windows.

**Solutions**:
1. Click the **pin button** (📌) in the floating window to enable always-on-top
2. Check that the pin icon is green (enabled)
3. Some system windows may override always-on-top behavior

### Playback Issues

**Problem**: Video not playing in floating window.

**Solutions**:
1. Check that the stream is working in the main window first
2. Close and reopen the floating window
3. Try a different channel
4. Check your internet connection

### Window Too Small/Large

**Problem**: Can't see the window properly.

**Solutions**:
1. Use the resize handle in the bottom-right corner
2. Go to Settings > Floating Window and use size presets
3. Adjust using the width/height sliders

## Best Practices

### For Best Experience

1. **Start with Medium Size**: The default 480×270 size works well for most use cases
2. **Position Strategically**: Place the window in a corner where it won't interfere with your work
3. **Use Always-on-Top Wisely**: Disable it when you need to interact with windows behind it
4. **Monitor Performance**: If you experience lag, try a smaller window size

### Performance Tips

- Close the floating window when not in use to save resources
- Use a smaller window size for better performance on lower-end systems
- Ensure your internet connection is stable for smooth streaming

## Keyboard Shortcuts

When the floating window is focused:

- **Space**: Play/Pause (if implemented)
- **Escape**: Can be used to exit fullscreen (if implemented)

## Known Limitations

1. **Single Floating Window**: Only one floating window can be open at a time
2. **Aspect Ratio**: Fixed to 16:9 for optimal video display
3. **System Windows**: Some system dialogs may appear above the floating window
4. **Multi-Monitor**: Window may need manual repositioning when switching monitors

## Future Enhancements

Planned improvements:

- [ ] Multiple floating windows support
- [ ] Hotkey support for quick access
- [ ] Opacity control
- [ ] Remember last position and size
- [ ] Snap to screen edges
- [ ] Virtual desktop support
- [ ] Custom aspect ratios
- [ ] Thumbnail preview when minimized

## API Reference

### FloatingWindowService

#### Static Methods

```dart
// Open a new floating window
static Future<bool> openFloatingWindow({
  required String streamUrl,
  required String channelName,
  double width = 480,
  double height = 270,
})

// Close the floating window
static Future<void> closeFloatingWindow()

// Update stream in existing window
static Future<void> updateStream({
  required String streamUrl,
  required String channelName,
})

// Resize the window
static Future<void> resizeFloatingWindow(Size size)

// Move the window
static Future<void> moveFloatingWindow(Offset position)

// Bring window to front
static Future<void> focusFloatingWindow()
```

#### Static Properties

```dart
// Check if floating window is open
static bool get isFloatingWindowOpen

// Get current window ID
static int? get floatingWindowId
```

## Contributing

To contribute to the floating window feature:

1. Review the code in `lib/services/floating_window_service.dart`
2. Test on all supported platforms (Windows, macOS, Linux)
3. Ensure backward compatibility
4. Update this documentation with any changes

## Support

For issues or questions:
1. Check this documentation first
2. Search existing GitHub issues
3. Create a new issue with:
   - Platform and OS version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

---

**Version**: 1.0.0  
**Last Updated**: November 4, 2025  
**Platforms**: Windows, macOS, Linux
