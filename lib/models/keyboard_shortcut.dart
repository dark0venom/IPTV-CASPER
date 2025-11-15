import 'package:flutter/services.dart';

/// Model for keyboard shortcut configuration
class KeyboardShortcut {
  final String id;
  final String name;
  final String description;
  final ShortcutCategory category;
  final Set<LogicalKeyboardKey> keySet;
  final bool isEnabled;

  KeyboardShortcut({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.keySet,
    this.isEnabled = true,
  });

  /// Create from JSON
  factory KeyboardShortcut.fromJson(Map<String, dynamic> json) {
    return KeyboardShortcut(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ShortcutCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ShortcutCategory.playback,
      ),
      keySet: _parseKeySet(json['keys'] as List<dynamic>),
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'keySet': keySet.map((k) => k.keyId).toList(),
      'isEnabled': isEnabled,
    };
  }

  /// Parse key set from list of key codes
  static Set<LogicalKeyboardKey> _parseKeySet(List<dynamic> keys) {
    return keys.map((k) => LogicalKeyboardKey.findKeyByKeyId(k as int)).whereType<LogicalKeyboardKey>().toSet();
  }



  /// Get display string for the shortcut
  String get displayString {
    final keys = keySet.toList();
    return keys.map((k) => _getKeyLabel(k)).join(' + ');
  }

  /// Get label for a key
  static String _getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.control || key == LogicalKeyboardKey.controlLeft || key == LogicalKeyboardKey.controlRight) {
      return 'Ctrl';
    }
    if (key == LogicalKeyboardKey.shift || key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
      return 'Shift';
    }
    if (key == LogicalKeyboardKey.alt || key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight) {
      return 'Alt';
    }
    if (key == LogicalKeyboardKey.meta || key == LogicalKeyboardKey.metaLeft || key == LogicalKeyboardKey.metaRight) {
      return 'Win';
    }
    return key.keyLabel.toUpperCase();
  }

  /// Create a copy with updated fields
  KeyboardShortcut copyWith({
    String? id,
    String? name,
    String? description,
    ShortcutCategory? category,
    Set<LogicalKeyboardKey>? keySet,
    bool? isEnabled,
  }) {
    return KeyboardShortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      keySet: keySet ?? this.keySet,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  String toString() {
    return 'KeyboardShortcut(name: $name, keys: $displayString)';
  }
}

/// Shortcut category enum
enum ShortcutCategory {
  playback,
  navigation,
  window,
  general,
}

extension ShortcutCategoryExtension on ShortcutCategory {
  String get displayName {
    switch (this) {
      case ShortcutCategory.playback:
        return 'Playback';
      case ShortcutCategory.navigation:
        return 'Navigation';
      case ShortcutCategory.window:
        return 'Window';
      case ShortcutCategory.general:
        return 'General';
    }
  }
}

/// Default keyboard shortcuts
class DefaultShortcuts {
  /// Get all default shortcuts
  static List<KeyboardShortcut> getAll() => defaults;

  static List<KeyboardShortcut> get defaults => [
    // Playback shortcuts
    KeyboardShortcut(
      id: 'play_pause',
      name: 'Play/Pause',
      description: 'Toggle playback',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.space},
    ),
    KeyboardShortcut(
      id: 'stop',
      name: 'Stop',
      description: 'Stop playback',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.keyS},
    ),
    KeyboardShortcut(
      id: 'volume_up',
      name: 'Volume Up',
      description: 'Increase volume',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.arrowUp},
    ),
    KeyboardShortcut(
      id: 'volume_down',
      name: 'Volume Down',
      description: 'Decrease volume',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.arrowDown},
    ),
    KeyboardShortcut(
      id: 'mute',
      name: 'Mute',
      description: 'Toggle mute',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.keyM},
    ),
    KeyboardShortcut(
      id: 'seek_forward',
      name: 'Seek Forward',
      description: 'Skip forward 10 seconds',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.arrowRight},
    ),
    KeyboardShortcut(
      id: 'seek_backward',
      name: 'Seek Backward',
      description: 'Skip backward 10 seconds',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.arrowLeft},
    ),
    KeyboardShortcut(
      id: 'fullscreen',
      name: 'Fullscreen',
      description: 'Toggle fullscreen',
      category: ShortcutCategory.playback,
      keySet: {LogicalKeyboardKey.keyF},
    ),
    
    // Navigation shortcuts
    KeyboardShortcut(
      id: 'next_channel',
      name: 'Next Channel',
      description: 'Switch to next channel',
      category: ShortcutCategory.navigation,
      keySet: {LogicalKeyboardKey.pageDown},
    ),
    KeyboardShortcut(
      id: 'prev_channel',
      name: 'Previous Channel',
      description: 'Switch to previous channel',
      category: ShortcutCategory.navigation,
      keySet: {LogicalKeyboardKey.pageUp},
    ),
    KeyboardShortcut(
      id: 'search',
      name: 'Search',
      description: 'Open search',
      category: ShortcutCategory.navigation,
      keySet: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyF},
    ),
    KeyboardShortcut(
      id: 'favorites',
      name: 'Favorites',
      description: 'Toggle favorites view',
      category: ShortcutCategory.navigation,
      keySet: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyD},
    ),
    
    // Window shortcuts
    KeyboardShortcut(
      id: 'pip_toggle',
      name: 'Picture-in-Picture',
      description: 'Toggle floating window',
      category: ShortcutCategory.window,
      keySet: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyP},
    ),
    KeyboardShortcut(
      id: 'always_on_top',
      name: 'Always On Top',
      description: 'Toggle always on top',
      category: ShortcutCategory.window,
      keySet: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyT},
    ),
    
    // General shortcuts
    KeyboardShortcut(
      id: 'settings',
      name: 'Settings',
      description: 'Open settings',
      category: ShortcutCategory.general,
      keySet: {LogicalKeyboardKey.control, LogicalKeyboardKey.comma},
    ),
    KeyboardShortcut(
      id: 'add_favorite',
      name: 'Add to Favorites',
      description: 'Add current channel to favorites',
      category: ShortcutCategory.general,
      keySet: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyB},
    ),
    KeyboardShortcut(
      id: 'epg_toggle',
      name: 'Toggle EPG',
      description: 'Show/hide program guide',
      category: ShortcutCategory.general,
      keySet: {LogicalKeyboardKey.keyG},
    ),
    KeyboardShortcut(
      id: 'recordings',
      name: 'Recordings',
      description: 'Open recordings manager',
      category: ShortcutCategory.general,
      keySet: {LogicalKeyboardKey.keyR},
    ),
  ];
}
