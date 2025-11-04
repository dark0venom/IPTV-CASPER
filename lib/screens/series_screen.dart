import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/player_provider.dart';
import '../models/series_item.dart';
import '../models/channel.dart';
import '../utils/responsive.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      // Load categories if empty
      if (contentProvider.seriesCategories.isEmpty) {
        await contentProvider.loadSeriesCategories();
      }
      // Load items if empty
      if (contentProvider.seriesItems.isEmpty) {
        await contentProvider.loadSeriesItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Series'),
        actions: [
          if (contentProvider.seriesCategories.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter by category',
              onSelected: (categoryId) {
                contentProvider.setSeriesCategory(categoryId);
              },
              itemBuilder: (context) {
                return contentProvider.seriesCategories.map((category) {
                  final categoryId = category['category_id']?.toString() ?? '';
                  final categoryName = category['category_name']?.toString() ?? 'Unknown';
                  final isSelected = contentProvider.selectedSeriesCategoryId == categoryId;
                  
                  return PopupMenuItem<String>(
                    value: categoryId,
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check, size: 18),
                        if (isSelected)
                          const SizedBox(width: 8),
                        Expanded(child: Text(categoryName)),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              // Reload categories if empty
              if (contentProvider.seriesCategories.isEmpty) {
                await contentProvider.loadSeriesCategories();
              }
              // Reload items
              final categoryId = contentProvider.selectedSeriesCategoryId;
              await contentProvider.loadSeriesItems(
                categoryId: categoryId == 'all' ? null : categoryId,
              );
            },
          ),
        ],
      ),
      body: contentProvider.isLoadingSeries
          ? const Center(child: CircularProgressIndicator())
          : contentProvider.filteredSeriesItems.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    if (contentProvider.seriesCategories.isEmpty) {
                      await contentProvider.loadSeriesCategories();
                    }
                    final categoryId = contentProvider.selectedSeriesCategoryId;
                    await contentProvider.loadSeriesItems(
                      categoryId: categoryId == 'all' ? null : categoryId,
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tv,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No TV series available',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pull down to refresh or tap the refresh button',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final categoryId = contentProvider.selectedSeriesCategoryId;
                    await contentProvider.loadSeriesItems(
                      categoryId: categoryId == 'all' ? null : categoryId,
                    );
                  },
                  child: _buildSeriesGrid(
                    contentProvider.filteredSeriesItems,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                ),
    );
  }

  Widget _buildSeriesGrid(List<SeriesItem> series, {required bool isDesktop, required bool isTablet}) {
    final crossAxisCount = isDesktop ? 6 : (isTablet ? 4 : 3);
    final aspectRatio = 2 / 3; // Series poster aspect ratio

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: series.length,
      itemBuilder: (context, index) {
        final seriesItem = series[index];
        return _buildSeriesCard(seriesItem);
      },
    );
  }

  Widget _buildSeriesCard(SeriesItem series) {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => _showSeriesDetails(series),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster image
            if (series.posterUrl != null)
              Image.network(
                series.posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(series.name),
              )
            else
              _buildPlaceholder(series.name),
            
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      series.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (series.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            series.rating!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Favorite button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  series.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: series.isFavorite ? Colors.red : Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  contentProvider.toggleSeriesFavorite(series.id);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tv,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSeriesDetails(SeriesItem series) async {
    // Load full series info with episodes
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: FutureBuilder<SeriesItem?>(
              future: contentProvider.getSeriesDetails(series.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final detailedSeries = snapshot.data ?? series;
                
                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildSeriesDetailsContent(detailedSeries),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeriesDetailsContent(SeriesItem series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Backdrop
        if (series.backdropUrl != null)
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  series.backdropUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    series.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and rating
              Row(
                children: [
                  Expanded(
                    child: Text(
                      series.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (series.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            series.rating!,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Metadata
              Wrap(
                spacing: 8,
                children: [
                  if (series.releaseDate != null)
                    Chip(
                      label: Text(series.releaseDate!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (series.genre != null)
                    Chip(
                      label: Text(series.genre!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (series.seasons != null)
                    Chip(
                      label: Text('${series.seasons!.length} Seasons'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Plot
              if (series.plot != null) ...[
                Text(
                  'Plot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  series.plot!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              
              // Seasons and Episodes
              if (series.seasons != null && series.seasons!.isNotEmpty) ...[
                Text(
                  'Seasons & Episodes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...series.seasons!.map((season) => _buildSeasonCard(season)),
              ],
              
              // Cast
              if (series.cast != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Cast',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  series.cast!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonCard(Season season) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('${season.name} (${season.episodes.length} episodes)'),
        children: season.episodes.map((episode) => _buildEpisodeTile(episode)).toList(),
      ),
    );
  }

  Widget _buildEpisodeTile(Episode episode) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    return ListTile(
      leading: episode.posterUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                episode.posterUrl!,
                width: 80,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 45,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.tv, size: 24),
                ),
              ),
            )
          : Container(
              width: 80,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.tv, size: 24),
            ),
      title: Text('Episode ${episode.episodeNum}: ${episode.title}'),
      subtitle: episode.duration != null ? Text(episode.duration!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () {
          // Convert Episode to Channel for player
          final channel = Channel(
            name: episode.title,
            url: episode.streamUrl,
            logoUrl: episode.posterUrl,
            groupTitle: 'Series',
            tvgId: episode.id,
          );
          playerProvider.playChannel(channel);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        // Convert Episode to Channel for player
        final channel = Channel(
          name: episode.title,
          url: episode.streamUrl,
          logoUrl: episode.posterUrl,
          groupTitle: 'Series',
          tvgId: episode.id,
        );
        playerProvider.playChannel(channel);
        Navigator.pop(context);
      },
    );
  }
}
