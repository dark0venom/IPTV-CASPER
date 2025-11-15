import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/channel_list.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/mobile_channel_drawer.dart';
import '../widgets/mini_player.dart';
import '../widgets/detached_player_window.dart';
import '../widgets/add_playlist_dialog.dart';
import '../utils/responsive.dart';
import '../services/pip_service.dart';
import '../services/floating_window_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isFullScreen = false;
  bool _showDetachedPlayer = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _showAddPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddPlaylistDialog(),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _toggleDetachedPlayer() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    if (playerProvider.currentChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a channel first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // For Windows/Desktop: Use true floating window with always-on-top
    if ((Platform.isWindows || Platform.isMacOS || Platform.isLinux) && !_showDetachedPlayer) {
      final success = await FloatingWindowService.openFloatingWindow(
        streamUrl: playerProvider.currentChannel!.url,
        channelName: playerProvider.currentChannel!.name,
      );
      
      if (success) {
        setState(() {
          _showDetachedPlayer = true;
        });
        playerProvider.setDetached(true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Floating player opened (Always on top)'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to open floating player'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else if (_showDetachedPlayer) {
      // Close the floating window
      await FloatingWindowService.closeFloatingWindow();
      setState(() {
        _showDetachedPlayer = false;
      });
      playerProvider.setDetached(false);
    }
  }

  Future<void> _enterPictureInPicture() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    if (playerProvider.currentChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a channel first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!PipService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Picture-in-Picture is not supported on this platform'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await PipService.enterPip();
    if (success) {
      // For Windows/Desktop, show the detached player window
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        setState(() {
          _showDetachedPlayer = true;
        });
      }
      playerProvider.setDetached(true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to enter Picture-in-Picture mode'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Fullscreen mode
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            const VideoPlayerWidget(),
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                    onPressed: _toggleFullScreen,
                    tooltip: 'Exit Fullscreen',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Text('IPTV Casper'),
          actions: [
            if (playerProvider.currentChannel != null) ...[
              if (PipService.isSupported)
                IconButton(
                  icon: const Icon(Icons.picture_in_picture_alt),
                  onPressed: _enterPictureInPicture,
                  tooltip: 'Picture-in-Picture',
                ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: _toggleFullScreen,
                tooltip: 'Fullscreen',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: const MobileChannelDrawer(),
        body: Column(
          children: [
            // Video player
            Expanded(
              child: playerProvider.currentChannel != null
                  ? const VideoPlayerWidget()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tv,
                            size: 80,
                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'No channel selected',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (playlistProvider.playlists.isEmpty)
                            ElevatedButton.icon(
                              onPressed: _showAddPlaylistDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Playlist'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Select a channel from the list to start watching',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            // Mini player
            if (playerProvider.currentChannel != null)
              MiniPlayer(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: _showAddPlaylistDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Playlist'),
            tooltip: 'Add Playlist',
          ),
        ),
      );
    }

    // Tablet & Desktop layout
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF9C27B0),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.live_tv_rounded,
              color: Colors.white,
            ),
          ),
        ),
        title: const Text('IPTV Casper'),
        actions: [
          if (playerProvider.currentChannel != null) ...[
            IconButton(
              icon: Icon(
                _showDetachedPlayer ? Icons.picture_in_picture : Icons.picture_in_picture_alt,
                color: _showDetachedPlayer ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: _toggleDetachedPlayer,
              tooltip: _showDetachedPlayer ? 'Attach Player' : 'Detach Player',
            ),
            if (PipService.isSupported)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: _enterPictureInPicture,
                tooltip: 'Picture-in-Picture',
              ),
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: _toggleFullScreen,
              tooltip: 'Fullscreen',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (playerProvider.currentChannel != null) {
                  playerProvider.playChannel(playerProvider.currentChannel!);
                }
              },
              tooltip: 'Refresh',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar with channel list
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isTablet ? 280 : 320,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search channels...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: playlistProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                playlistProvider.searchChannels('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      playlistProvider.searchChannels(value);
                    },
                  ),
                ),
                // Filter options
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: playlistProvider.selectedGroup == null &&
                            !playlistProvider.showFavoritesOnly,
                        onSelected: (selected) {
                          if (selected) {
                            playlistProvider.filterByGroup(null);
                            if (playlistProvider.showFavoritesOnly) {
                              playlistProvider.toggleFavoritesOnly();
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16),
                            SizedBox(width: 4),
                            Text('Favorites'),
                          ],
                        ),
                        selected: playlistProvider.showFavoritesOnly,
                        onSelected: (selected) {
                          playlistProvider.toggleFavoritesOnly();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...playlistProvider.groups.take(5).map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(group),
                            selected: playlistProvider.selectedGroup == group,
                            onSelected: (selected) {
                              playlistProvider.filterByGroup(selected ? group : null);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Channel list
                const Expanded(
                  child: ChannelList(),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content area
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: !_showDetachedPlayer && playerProvider.currentChannel != null
                      ? const VideoPlayerWidget()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showDetachedPlayer ? Icons.picture_in_picture_alt : Icons.tv,
                                size: 120,
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                _showDetachedPlayer
                                    ? 'Player is detached'
                                    : 'No channel selected',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (!_showDetachedPlayer) ...[
                                const SizedBox(height: AppSpacing.md),
                                if (playlistProvider.playlists.isEmpty)
                                  ElevatedButton.icon(
                                    onPressed: _showAddPlaylistDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Playlist'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    'Select a channel from the list to start watching',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                ),
                // Detached player window - floating overlay that stays on top
                if (_showDetachedPlayer)
                  DetachedPlayerWindow(
                    onClose: _toggleDetachedPlayer,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
