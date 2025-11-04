import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VoidCallback? onFullScreenToggle;

  const VideoPlayerWidget({
    super.key,
    this.onFullScreenToggle,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _showControls = true;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (playerProvider.videoController == null) {
      return const Center(
        child: Text('Initializing player...'),
      );
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
          _showControls = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Video player
            Video(
              controller: playerProvider.videoController!,
              controls: NoVideoControls,
            ),

            // Custom controls overlay
            if (_showControls || _isHovering)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.2, 0.6, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top bar with channel name
                      _buildTopBar(playerProvider),
                      const Spacer(),
                      // Bottom controls
                      _buildBottomControls(playerProvider),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(PlayerProvider playerProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.tv, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerProvider.currentChannel?.name ?? 'No channel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (playerProvider.currentChannel?.groupTitle != null)
                  Text(
                    playerProvider.currentChannel!.groupTitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onFullScreenToggle != null)
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: widget.onFullScreenToggle,
              tooltip: 'Fullscreen',
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(PlayerProvider playerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar (for VOD, not useful for live TV but kept for completeness)
          if (playerProvider.duration.inSeconds > 0)
            Slider(
              value: playerProvider.position.inSeconds.toDouble(),
              max: playerProvider.duration.inSeconds.toDouble(),
              onChanged: (value) {
                playerProvider.seek(Duration(seconds: value.toInt()));
              },
            ),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause
              IconButton(
                icon: Icon(
                  playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (playerProvider.isPlaying) {
                    playerProvider.pause();
                  } else {
                    playerProvider.play();
                  }
                },
                tooltip: playerProvider.isPlaying ? 'Pause' : 'Play',
              ),
              
              const SizedBox(width: 16),
              
              // Stop
              IconButton(
                icon: const Icon(
                  Icons.stop,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  playerProvider.stop();
                },
                tooltip: 'Stop',
              ),

              const Spacer(),

              // Volume control
              IconButton(
                icon: Icon(
                  playerProvider.isMuted || playerProvider.volume == 0
                      ? Icons.volume_off
                      : playerProvider.volume < 50
                          ? Icons.volume_down
                          : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: () {
                  playerProvider.toggleMute();
                },
                tooltip: 'Mute/Unmute',
              ),
              
              SizedBox(
                width: 120,
                child: Slider(
                  value: playerProvider.volume,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    playerProvider.setVolume(value);
                  },
                ),
              ),
              
              Text(
                '${playerProvider.volume.round()}%',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
