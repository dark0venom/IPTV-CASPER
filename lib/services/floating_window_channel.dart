import 'package:flutter/services.dart';

class FloatingWindowChannel {
  static const MethodChannel _channel = MethodChannel('iptv_casper/floating_window');
  
  /// Create and show a floating window
  static Future<bool> createFloatingWindow({
    required String streamUrl,
    required String channelName,
  }) async {
    try {
      final result = await _channel.invokeMethod('create', {
        'streamUrl': streamUrl,
        'channelName': channelName,
      });
      return result == true;
    } catch (e) {
      print('Error creating floating window: $e');
      return false;
    }
  }
  
  /// Show the floating window
  static Future<void> show() async {
    try {
      await _channel.invokeMethod('show');
    } catch (e) {
      print('Error showing floating window: $e');
    }
  }
  
  /// Hide the floating window
  static Future<void> hide() async {
    try {
      await _channel.invokeMethod('hide');
    } catch (e) {
      print('Error hiding floating window: $e');
    }
  }
  
  /// Close the floating window
  static Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
    } catch (e) {
      print('Error closing floating window: $e');
    }
  }
  
  /// Check if floating window is visible
  static Future<bool> isVisible() async {
    try {
      final result = await _channel.invokeMethod('isVisible');
      return result == true;
    } catch (e) {
      print('Error checking floating window visibility: $e');
      return false;
    }
  }
}
