import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Service to handle Picture-in-Picture (PIP) functionality across platforms
class PipService {
  static const MethodChannel _channel = MethodChannel('com.iptvcastper/pip');
  
  /// Check if PIP is supported on the current platform
  static bool get isSupported {
    if (Platform.isAndroid) {
      return true; // Android 8.0+ supports PIP
    } else if (Platform.isIOS) {
      return true; // iOS 14+ supports PIP
    } else if (Platform.isMacOS) {
      return true; // macOS supports PIP
    } else if (Platform.isWindows) {
      return true; // Windows 10+ supports compact overlay
    } else if (Platform.isLinux) {
      return true; // Linux supports floating windows
    }
    return false; // Web doesn't support native PIP yet
  }

  /// Enter Picture-in-Picture mode
  static Future<bool> enterPip() async {
    try {
      if (Platform.isAndroid) {
        return await _enterAndroidPip();
      } else if (Platform.isIOS) {
        return await _enterIOSPip();
      } else if (Platform.isMacOS) {
        return await _enterMacOSPip();
      } else if (Platform.isWindows) {
        // Windows: Use detached window instead of native PiP
        // The detached window is already implemented and working
        debugPrint('Windows PiP: Using detached window mode');
        return true; // Return true to indicate success
      } else if (Platform.isLinux) {
        return await _enterLinuxPip();
      }
      return false;
    } catch (e) {
      debugPrint('Error entering PIP: $e');
      return false;
    }
  }

  /// Exit Picture-in-Picture mode
  static Future<bool> exitPip() async {
    try {
      if (Platform.isAndroid) {
        return await _exitAndroidPip();
      } else if (Platform.isIOS) {
        return await _exitIOSPip();
      } else if (Platform.isMacOS) {
        return await _exitMacOSPip();
      } else if (Platform.isWindows) {
        // Windows: Close detached window
        debugPrint('Windows PiP: Closing detached window mode');
        return true;
      } else if (Platform.isLinux) {
        return await _exitLinuxPip();
      }
      return false;
    } catch (e) {
      debugPrint('Error exiting PIP: $e');
      return false;
    }
  }

  /// Check if currently in PIP mode
  static Future<bool> isInPipMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('isInPipMode');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // Platform-specific implementations

  static Future<bool> _enterAndroidPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('enterPip');
      return result ?? false;
    } catch (e) {
      debugPrint('Android PIP error: $e');
      return false;
    }
  }

  static Future<bool> _exitAndroidPip() async {
    // Android PIP exits automatically when user taps
    return true;
  }

  static Future<bool> _enterIOSPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('enterPip');
      return result ?? false;
    } catch (e) {
      debugPrint('iOS PIP error: $e');
      return false;
    }
  }

  static Future<bool> _exitIOSPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('exitPip');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _enterMacOSPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('enterPip');
      return result ?? false;
    } catch (e) {
      debugPrint('macOS PIP error: $e');
      return false;
    }
  }

  static Future<bool> _exitMacOSPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('exitPip');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // Windows uses detached window mode instead of native PiP
  // No need for platform channel implementation

  static Future<bool> _enterLinuxPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('enterPip');
      return result ?? false;
    } catch (e) {
      debugPrint('Linux PIP error: $e');
      return false;
    }
  }

  static Future<bool> _exitLinuxPip() async {
    try {
      final result = await _channel.invokeMethod<bool>('exitPip');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
