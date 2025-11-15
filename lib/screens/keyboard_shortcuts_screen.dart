import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/keyboard_shortcut.dart';

/// Screen to view and edit keyboard shortcuts
class KeyboardShortcutsScreen extends StatefulWidget {
  const KeyboardShortcutsScreen({super.key});

  @override
  State<KeyboardShortcutsScreen> createState() => _KeyboardShortcutsScreenState();
}

class _KeyboardShortcutsScreenState extends State<KeyboardShortcutsScreen> {
  List<KeyboardShortcut> shortcuts = DefaultShortcuts.getAll();
  ShortcutCategory selectedCategory = ShortcutCategory.playback;

  @override
  Widget build(BuildContext context) {
    final filteredShortcuts = shortcuts.where((s) => s.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: Row(
        children: [
          _buildCategoryList(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildShortcutsList(filteredShortcuts)),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        children: ShortcutCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return ListTile(
            selected: isSelected,
            leading: Icon(_getCategoryIcon(category)),
            title: Text(_getCategoryName(category)),
            onTap: () => setState(() => selectedCategory = category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShortcutsList(List<KeyboardShortcut> shortcuts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(shortcut.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(shortcut.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shortcut.displayString,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editShortcut(shortcut),
                  tooltip: 'Edit',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(ShortcutCategory category) {
    switch (category) {
      case ShortcutCategory.playback:
        return Icons.play_circle;
      case ShortcutCategory.navigation:
        return Icons.navigation;
      case ShortcutCategory.window:
        return Icons.window;
      case ShortcutCategory.general:
        return Icons.settings;
    }
  }

  String _getCategoryName(ShortcutCategory category) {
    switch (category) {
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

  void _editShortcut(KeyboardShortcut shortcut) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit: ${shortcut.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shortcut.description),
            const SizedBox(height: 16),
            const Text('Press the new key combination...'),
            const SizedBox(height: 8),
            Text('Current: ${shortcut.displayString}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save')),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Shortcuts'),
        content: const Text('Reset all shortcuts to default values?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => shortcuts = DefaultShortcuts.getAll());
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
