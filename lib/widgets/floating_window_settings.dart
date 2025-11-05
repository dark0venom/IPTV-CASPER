import 'dart:io';
import 'package:flutter/material.dart';
import '../services/floating_window_service.dart';

/// Widget for managing floating window settings
class FloatingWindowSettings extends StatefulWidget {
  const FloatingWindowSettings({super.key});

  @override
  State<FloatingWindowSettings> createState() => _FloatingWindowSettingsState();
}

class _FloatingWindowSettingsState extends State<FloatingWindowSettings> {
  double _windowWidth = 480;
  double _windowHeight = 270;
  
  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_in_picture_alt),
                const SizedBox(width: 8),
                Text(
                  'Floating Window Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text(
              'The floating window is always on top and stays visible even when working in other applications.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Window size controls
            Text(
              'Default Window Size',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Text('Width: '),
                Expanded(
                  child: Slider(
                    value: _windowWidth,
                    min: 320,
                    max: 1280,
                    divisions: 96,
                    label: '${_windowWidth.toInt()}px',
                    onChanged: (value) {
                      setState(() {
                        _windowWidth = value;
                        _windowHeight = value * 9 / 16; // Maintain 16:9 aspect ratio
                      });
                    },
                  ),
                ),
                Text('${_windowWidth.toInt()}px'),
              ],
            ),
            
            Row(
              children: [
                const Text('Height: '),
                Expanded(
                  child: Slider(
                    value: _windowHeight,
                    min: 180,
                    max: 720,
                    divisions: 54,
                    label: '${_windowHeight.toInt()}px',
                    onChanged: (value) {
                      setState(() {
                        _windowHeight = value;
                        _windowWidth = value * 16 / 9; // Maintain 16:9 aspect ratio
                      });
                    },
                  ),
                ),
                Text('${_windowHeight.toInt()}px'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick size presets
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _windowWidth = 320;
                      _windowHeight = 180;
                    });
                  },
                  child: const Text('Small (320x180)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _windowWidth = 480;
                      _windowHeight = 270;
                    });
                  },
                  child: const Text('Medium (480x270)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _windowWidth = 640;
                      _windowHeight = 360;
                    });
                  },
                  child: const Text('Large (640x360)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _windowWidth = 854;
                      _windowHeight = 480;
                    });
                  },
                  child: const Text('HD (854x480)'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Window control buttons
            if (FloatingWindowService.isFloatingWindowOpen) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FloatingWindowService.resizeFloatingWindow(
                        Size(_windowWidth, _windowHeight),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Window resized'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.aspect_ratio),
                    label: const Text('Apply Size'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FloatingWindowService.focusFloatingWindow();
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Focus Window'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FloatingWindowService.closeFloatingWindow();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Close Window'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Info section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Floating Window Features',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Always stays on top of other windows'),
                  const Text('• Draggable by title bar'),
                  const Text('• Resizable from bottom-right corner'),
                  const Text('• Toggle always-on-top with pin button'),
                  const Text('• Play/pause controls in title bar'),
                  const Text('• Maintains 16:9 aspect ratio'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
