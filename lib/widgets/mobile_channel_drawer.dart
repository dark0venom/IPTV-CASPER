import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../models/channel.dart';

class MobileChannelDrawer extends StatelessWidget {
  const MobileChannelDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tv,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'IPTV Casper',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${playlistProvider.channels.length} channels',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
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

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
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

          const Divider(),

          // Channel list
          Expanded(
            child: playlistProvider.channels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.playlist_play,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No channels found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: playlistProvider.channels.length,
                    itemBuilder: (context, index) {
                      final channel = playlistProvider.channels[index];
                      final isPlaying =
                          playerProvider.currentChannel?.url == channel.url;

                      return _ChannelListTile(
                        channel: channel,
                        isPlaying: isPlaying,
                        showLogo: settingsProvider.showChannelLogos,
                        onTap: () {
                          playerProvider.playChannel(channel);
                          Navigator.pop(context);
                        },
                        onFavoriteToggle: () {
                          playlistProvider.toggleFavorite(channel);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChannelListTile extends StatelessWidget {
  final Channel channel;
  final bool isPlaying;
  final bool showLogo;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _ChannelListTile({
    required this.channel,
    required this.isPlaying,
    required this.showLogo,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: showLogo && channel.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                channel.logoUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tv, size: 24),
                  );
                },
              ),
            )
          : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tv, size: 24),
            ),
      title: Text(
        channel.name,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: channel.groupTitle != null
          ? Text(
              channel.groupTitle!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 12, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'Playing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(
              channel.isFavorite ? Icons.star : Icons.star_border,
              color: channel.isFavorite ? Colors.amber : null,
            ),
            onPressed: onFavoriteToggle,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
