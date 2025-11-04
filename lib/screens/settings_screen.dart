import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/playlist_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1D1E33),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Playback Settings
          const Text(
            'Playback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-play channels'),
                  subtitle: const Text('Automatically play when selecting a channel'),
                  value: settingsProvider.autoPlay,
                  onChanged: (value) {
                    settingsProvider.setAutoPlay(value);
                  },
                ),
                ListTile(
                  title: const Text('Default Volume'),
                  subtitle: Slider(
                    value: settingsProvider.defaultVolume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${settingsProvider.defaultVolume.round()}%',
                    onChanged: (value) {
                      settingsProvider.setDefaultVolume(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Display Settings
          const Text(
            'Display',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show channel logos'),
                  subtitle: const Text('Display logos in the channel list'),
                  value: settingsProvider.showChannelLogos,
                  onChanged: (value) {
                    settingsProvider.setShowChannelLogos(value);
                  },
                ),
                ListTile(
                  title: const Text('Player Aspect Ratio'),
                  subtitle: DropdownButton<String>(
                    value: settingsProvider.playerAspectRatio,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '16:9', child: Text('16:9')),
                      DropdownMenuItem(value: '4:3', child: Text('4:3')),
                      DropdownMenuItem(value: 'fit', child: Text('Fit to screen')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        settingsProvider.setPlayerAspectRatio(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Playlist Management
          const Text(
            'Playlists',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: const Text('Loaded Playlists'),
                  subtitle: Text('${playlistProvider.playlists.length} playlist(s)'),
                ),
                const Divider(),
                ...playlistProvider.playlists.map((playlist) {
                  return ListTile(
                    leading: playlist.requiresAuth
                        ? const Icon(Icons.lock, size: 20)
                        : const Icon(Icons.playlist_play, size: 20),
                    title: Row(
                      children: [
                        Expanded(child: Text(playlist.name)),
                        if (playlist.requiresAuth)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AUTH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      playlist.url ?? playlist.filePath ?? 'Unknown source',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (playlist.url != null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reload playlist',
                            onPressed: () async {
                              try {
                                await playlistProvider.reloadPlaylist(playlist);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Playlist reloaded successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error reloading: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeletePlaylistConfirmation(
                              context,
                              playlist.name,
                              () {
                                playlistProvider.removePlaylist(playlist);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
                if (playlistProvider.playlists.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      'Clear All Data',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      _showClearAllConfirmation(context, playlistProvider);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('IPTV Casper'),
                  subtitle: Text('Version 1.0.0'),
                ),
                ListTile(
                  title: Text('A modern IPTV player for Windows'),
                  subtitle: Text('Built with Flutter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistConfirmation(
    BuildContext context,
    String playlistName,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "$playlistName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(
    BuildContext context,
    PlaylistProvider playlistProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will remove all playlists, channels, and favorites. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              playlistProvider.clearAllChannels();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
