import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/player_provider.dart';
import 'video_player_widget.dart';

/// Detached player window that can float on top of other windows
class DetachedPlayerWindow extends StatefulWidget {
  final VoidCallback? onClose;

  const DetachedPlayerWindow({
    super.key,
    this.onClose,
  });

  @override
  State<DetachedPlayerWindow> createState() => _DetachedPlayerWindowState();
}

class _DetachedPlayerWindowState extends State<DetachedPlayerWindow> {
  bool _isHovering = false;
  Offset _position = const Offset(100, 100);
  Size _size = const Size(400, 225); // 16:9 aspect ratio
  bool _isDragging = false;
  bool _isResizing = false;
  bool _isAlwaysOnTop = true; // Default to always on top

  @override
  void initState() {
    super.initState();
    // Set always on top by default for detached player
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _setAlwaysOnTop(true);
    }
  }

  Future<void> _setAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
      setState(() {
        _isAlwaysOnTop = alwaysOnTop;
      });
    } catch (e) {
      debugPrint('Error setting always on top: $e');
    }
  }

  Future<void> _toggleAlwaysOnTop() async {
    await _setAlwaysOnTop(!_isAlwaysOnTop);
  }

  @override
  void dispose() {
    // Reset always on top when detached player is closed
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.setAlwaysOnTop(false).catchError((e) {
        debugPrint('Error resetting always on top: $e');
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (playerProvider.currentChannel == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: _size.width,
            height: _size.height,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Video player
                const Positioned.fill(
                  child: VideoPlayerWidget(),
                ),

                // Drag handle and controls overlay
                AnimatedOpacity(
                  opacity: _isHovering || _isDragging ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Title bar with drag handle
                        GestureDetector(
                          onPanStart: (details) {
                            setState(() => _isDragging = true);
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _position += details.delta;
                            });
                          },
                          onPanEnd: (details) {
                            setState(() => _isDragging = false);
                          },
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.drag_indicator,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    playerProvider.currentChannel?.name ?? 'IPTV',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Always on Top button
                                if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
                                  Tooltip(
                                    message: _isAlwaysOnTop ? 'Disable Always on Top' : 'Enable Always on Top',
                                    child: IconButton(
                                      icon: Icon(
                                        _isAlwaysOnTop 
                                            ? Icons.push_pin 
                                            : Icons.push_pin_outlined,
                                        color: _isAlwaysOnTop 
                                            ? Theme.of(context).colorScheme.primary 
                                            : Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _toggleAlwaysOnTop,
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                // Play/Pause button
                                IconButton(
                                  icon: Icon(
                                    playerProvider.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (playerProvider.isPlaying) {
                                      playerProvider.pause();
                                    } else {
                                      playerProvider.play();
                                    }
                                  },
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                // Close button
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    // Reset always on top before closing
                                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                                      await windowManager.setAlwaysOnTop(false).catchError((e) {
                                        debugPrint('Error resetting always on top: $e');
                                      });
                                    }
                                    widget.onClose?.call();
                                  },
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Resize handle (bottom-right corner)
                if (_isHovering || _isResizing)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() => _isResizing = true);
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          final newWidth = _size.width + details.delta.dx;
                          final newHeight = _size.height + details.delta.dy;
                          
                          // Maintain 16:9 aspect ratio
                          if (newWidth >= 300 && newHeight >= 169) {
                            _size = Size(newWidth, newWidth * 9 / 16);
                          }
                        });
                      },
                      onPanEnd: (details) {
                        setState(() => _isResizing = false);
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                          ),
                        ),
                        child: const Icon(
                          Icons.zoom_out_map,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
