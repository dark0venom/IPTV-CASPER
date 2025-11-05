import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

/// Entry point for the detached player window
/// This runs in a separate process/window
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🟢 Detached player window starting...');
  debugPrint('   Args: $args');
  
  // Get window ID from args - it's at index 1
  final windowId = args.length > 1 ? int.tryParse(args[1]) ?? 0 : 0;
  
  // Initialize MediaKit
  MediaKit.ensureInitialized();
  
  // Initialize window manager for always-on-top functionality
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(480, 270),
      minimumSize: Size(320, 180),
      center: false,
      backgroundColor: Colors.black,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      alwaysOnTop: true, // Set always on top by default
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.show();
      await windowManager.focus();
      debugPrint('✅ Floating window set to always on top');
    });
  }
  
  // Parse arguments from desktop_multi_window
  // Format: [multi_window, windowId, arg1, arg2, ...]
  String? streamUrl;
  String? channelName;
  
  if (args.length > 2) {
    try {
      // Args starting from index 2 contain our custom arguments
      final argsString = args.skip(2).join(' ');
      debugPrint('   Parsing args: $argsString');
      
      // Parse: "streamUrl: http://..., channelName: Channel Name"
      final parts = argsString.split(',');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.startsWith('streamUrl:')) {
          streamUrl = trimmed.substring('streamUrl:'.length).trim();
          debugPrint('   Extracted streamUrl: $streamUrl');
        } else if (trimmed.startsWith('channelName:')) {
          channelName = trimmed.substring('channelName:'.length).trim();
          debugPrint('   Extracted channelName: $channelName');
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing arguments: $e');
    }
  }
  
  debugPrint('✅ Detached player window ready');
  debugPrint('   Window ID: $windowId');
  debugPrint('   Stream: $streamUrl');
  debugPrint('   Channel: $channelName');
  
  // Run the app - desktop_multi_window handles the window configuration
  runApp(DetachedPlayerApp(
    windowId: windowId,
    streamUrl: streamUrl,
    channelName: channelName ?? 'IPTV Player',
  ));
}

class DetachedPlayerApp extends StatefulWidget {
  final int windowId;
  final String? streamUrl;
  final String channelName;
  
  const DetachedPlayerApp({
    super.key,
    required this.windowId,
    required this.streamUrl,
    required this.channelName,
  });

  @override
  State<DetachedPlayerApp> createState() => _DetachedPlayerAppState();
}

class _DetachedPlayerAppState extends State<DetachedPlayerApp> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isPlaying = false;
  bool _isHovering = false;
  bool _isAlwaysOnTop = true;
  String _currentChannelName = '';

  @override
  void initState() {
    super.initState();
    
    _currentChannelName = widget.channelName;
    
    // Initialize player
    _player = Player();
    _videoController = VideoController(_player);
    
    // Start playback if stream URL is provided
    if (widget.streamUrl != null && widget.streamUrl!.isNotEmpty) {
      _player.open(Media(widget.streamUrl!));
      _player.play();
      _isPlaying = true;
    }
    
    // Listen to playback state
    _player.stream.playing.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });
    
    // Listen for messages from main window
    _setupMessageHandler();
  }
  
  void _setupMessageHandler() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      debugPrint('🔵 Message received: ${call.method}');
      
      if (call.method == 'updateStream') {
        final args = call.arguments as Map<String, dynamic>;
        final streamUrl = args['streamUrl'] as String?;
        final channelName = args['channelName'] as String?;
        
        if (streamUrl != null && channelName != null) {
          await _updateStream(streamUrl, channelName);
        }
      }
      
      return null;
    });
  }
  
  Future<void> _updateStream(String streamUrl, String channelName) async {
    debugPrint('🔄 Updating stream to: $streamUrl');
    
    try {
      await _player.stop();
      await _player.open(Media(streamUrl));
      await _player.play();
      
      setState(() {
        _currentChannelName = channelName;
        _isPlaying = true;
      });
      
      debugPrint('✅ Stream updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating stream: $e');
    }
  }

  @override
  void dispose() {
    try {
      _player.stop();
    } catch (e) {
      debugPrint('❌ Error stopping player in dispose: $e');
    }
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }
  
  Future<void> _toggleAlwaysOnTop() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }
    
    try {
      final newValue = !_isAlwaysOnTop;
      await windowManager.setAlwaysOnTop(newValue);
      
      setState(() {
        _isAlwaysOnTop = newValue;
      });
      
      debugPrint('✅ Always on top set to: $newValue');
    } catch (e) {
      debugPrint('❌ Error toggling always on top: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Stack(
            children: [
              // Video player
              Video(
                controller: _videoController,
                controls: NoVideoControls,
              ),
              
              // Title bar and controls overlay
              AnimatedOpacity(
                opacity: _isHovering ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Title bar
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              // App logo
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2196F3),
                                      Color(0xFF9C27B0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.live_tv_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _currentChannelName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Always on top toggle button
                              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
                                Tooltip(
                                  message: _isAlwaysOnTop ? 'Disable always on top' : 'Enable always on top',
                                  child: IconButton(
                                    icon: Icon(
                                      _isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                                      color: _isAlwaysOnTop ? Colors.green : Colors.white70,
                                      size: 18,
                                    ),
                                    onPressed: _toggleAlwaysOnTop,
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              const SizedBox(width: 4),
                              // Play/Pause button
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: _togglePlayPause,
                                tooltip: _isPlaying ? 'Pause' : 'Play',
                              ),
                              // Close button
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  debugPrint('🔴 Closing detached player window ${widget.windowId}');
                                  try {
                                    // Stop and dispose the player first
                                    await _player.stop();
                                    // Close the window using WindowController
                                    await WindowController.fromWindowId(widget.windowId).close();
                                  } catch (e) {
                                    debugPrint('❌ Error closing window: $e');
                                  }
                                },
                                tooltip: 'Close',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
