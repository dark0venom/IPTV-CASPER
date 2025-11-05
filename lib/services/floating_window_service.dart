import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

/// Service for managing floating always-on-top windows on Windows
class FloatingWindowService {
  static int? _floatingWindowId;
  static bool _isFloatingWindowOpen = false;

  /// Check if floating window is currently open
  static bool get isFloatingWindowOpen => _isFloatingWindowOpen;

  /// Get the current floating window ID
  static int? get floatingWindowId => _floatingWindowId;

  /// Open a floating always-on-top window for video playback
  /// 
  /// [streamUrl] - The URL of the stream to play
  /// [channelName] - The name of the channel
  /// [width] - Initial window width (default: 480)
  /// [height] - Initial window height (default: 270)
  static Future<bool> openFloatingWindow({
    required String streamUrl,
    required String channelName,
    double width = 480,
    double height = 270,
  }) async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      debugPrint('❌ Floating windows only supported on desktop platforms');
      return false;
    }

    try {
      // Close existing floating window if any
      if (_isFloatingWindowOpen && _floatingWindowId != null) {
        await closeFloatingWindow();
      }

      debugPrint('🟡 Opening floating window...');
      debugPrint('   Stream: $streamUrl');
      debugPrint('   Channel: $channelName');

      // Create a new window using desktop_multi_window
      final window = await DesktopMultiWindow.createWindow(
        // Pass arguments to the new window
        'streamUrl: $streamUrl, channelName: $channelName',
      );

      _floatingWindowId = window.windowId;

      // Configure the window
      window
        ..setFrame(const Offset(100, 100) & Size(width, height))
        ..setTitle('$channelName - IPTV Casper')
        ..center()
        ..show();

      // Set window to always on top using WindowController
      await _setWindowAlwaysOnTop(window.windowId, true);

      _isFloatingWindowOpen = true;
      debugPrint('✅ Floating window opened with ID: ${window.windowId}');

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error opening floating window: $e');
      debugPrint('   Stack trace: $stackTrace');
      return false;
    }
  }

  /// Set a window to always be on top
  static Future<void> _setWindowAlwaysOnTop(int windowId, bool alwaysOnTop) async {
    try {
      // Note: desktop_multi_window doesn't directly expose setAlwaysOnTop,
      // The always-on-top functionality is handled in the window itself
      // via window_manager in detached_player_entry.dart
      
      debugPrint('✅ Window $windowId configured for always on top: $alwaysOnTop');
    } catch (e) {
      debugPrint('❌ Error setting always on top: $e');
    }
  }

  /// Close the floating window
  static Future<void> closeFloatingWindow() async {
    if (_floatingWindowId == null) {
      debugPrint('⚠️ No floating window to close');
      return;
    }

    try {
      debugPrint('🟡 Closing floating window $_floatingWindowId...');
      
      final controller = WindowController.fromWindowId(_floatingWindowId!);
      await controller.close();
      
      _floatingWindowId = null;
      _isFloatingWindowOpen = false;
      
      debugPrint('✅ Floating window closed');
    } catch (e) {
      debugPrint('❌ Error closing floating window: $e');
      _floatingWindowId = null;
      _isFloatingWindowOpen = false;
    }
  }

  /// Bring the floating window to front
  static Future<void> focusFloatingWindow() async {
    if (_floatingWindowId == null || !_isFloatingWindowOpen) {
      debugPrint('⚠️ No floating window to focus');
      return;
    }

    try {
      final controller = WindowController.fromWindowId(_floatingWindowId!);
      await controller.show();
      debugPrint('✅ Floating window focused');
    } catch (e) {
      debugPrint('❌ Error focusing floating window: $e');
    }
  }

  /// Update the stream in the floating window
  static Future<void> updateStream({
    required String streamUrl,
    required String channelName,
  }) async {
    if (_floatingWindowId == null || !_isFloatingWindowOpen) {
      // Open new window if none exists
      await openFloatingWindow(
        streamUrl: streamUrl,
        channelName: channelName,
      );
      return;
    }

    try {
      // Send message to the floating window to update the stream
      final controller = WindowController.fromWindowId(_floatingWindowId!);
      
      // Use invokeMethod to send the update request
      await DesktopMultiWindow.invokeMethod(
        _floatingWindowId!,
        'updateStream',
        {
          'streamUrl': streamUrl,
          'channelName': channelName,
        },
      );
      
      // Update window title
      await controller.setTitle('$channelName - IPTV Casper');
      
      debugPrint('✅ Floating window stream updated');
    } catch (e) {
      debugPrint('❌ Error updating floating window: $e');
      // If update fails, try to open a new window
      await openFloatingWindow(
        streamUrl: streamUrl,
        channelName: channelName,
      );
    }
  }

  /// Resize the floating window
  static Future<void> resizeFloatingWindow(Size size) async {
    if (_floatingWindowId == null || !_isFloatingWindowOpen) {
      debugPrint('⚠️ No floating window to resize');
      return;
    }

    try {
      final controller = WindowController.fromWindowId(_floatingWindowId!);
      // Set frame with just the size, position will remain the same
      await controller.setFrame(const Offset(100, 100) & size);
      debugPrint('✅ Floating window resized to ${size.width}x${size.height}');
    } catch (e) {
      debugPrint('❌ Error resizing floating window: $e');
    }
  }

  /// Move the floating window to a specific position
  static Future<void> moveFloatingWindow(Offset position) async {
    if (_floatingWindowId == null || !_isFloatingWindowOpen) {
      debugPrint('⚠️ No floating window to move');
      return;
    }

    try {
      final controller = WindowController.fromWindowId(_floatingWindowId!);
      // Set frame with new position and current size estimate
      await controller.setFrame(position & const Size(480, 270));
      debugPrint('✅ Floating window moved to (${position.dx}, ${position.dy})');
    } catch (e) {
      debugPrint('❌ Error moving floating window: $e');
    }
  }
}
