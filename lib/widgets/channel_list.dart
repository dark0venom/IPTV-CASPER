import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';

class ChannelList extends StatelessWidget {
  const ChannelList({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (playlistProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: playlistProvider.channels.length,
      itemBuilder: (context, index) {
        final channel = playlistProvider.channels[index];
        final isPlaying = playerProvider.currentChannel?.url == channel.url;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: isPlaying ? const Color(0xFF2E3350) : null,
          child: ListTile(
            leading: settingsProvider.showChannelLogos && channel.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      channel.logoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.tv, size: 48);
                      },
                    ),
                  )
                : const Icon(Icons.tv),
            title: Text(
              channel.name,
              style: TextStyle(
                fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: channel.groupTitle != null
                ? Text(
                    channel.groupTitle!,
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPlaying)
                  const Icon(
                    Icons.play_circle_filled,
                    color: Colors.green,
                  ),
                IconButton(
                  icon: Icon(
                    channel.isFavorite ? Icons.star : Icons.star_border,
                    color: channel.isFavorite ? Colors.amber : null,
                  ),
                  onPressed: () {
                    playlistProvider.toggleFavorite(channel);
                  },
                ),
              ],
            ),
            onTap: () {
              playerProvider.playChannel(channel);
            },
          ),
        );
      },
    );
  }
}
