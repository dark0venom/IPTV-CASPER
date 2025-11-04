import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/player_provider.dart';
import '../models/vod_item.dart';
import '../models/channel.dart';
import '../utils/responsive.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      // Load categories if empty
      if (contentProvider.vodCategories.isEmpty) {
        await contentProvider.loadVodCategories();
      }
      // Load items if empty
      if (contentProvider.vodItems.isEmpty) {
        await contentProvider.loadVodItems();
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
        title: const Text('Movies'),
        actions: [
          if (contentProvider.vodCategories.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter by category',
              onSelected: (categoryId) {
                contentProvider.setVodCategory(categoryId);
              },
              itemBuilder: (context) {
                return contentProvider.vodCategories.map((category) {
                  final categoryId = category['category_id']?.toString() ?? '';
                  final categoryName = category['category_name']?.toString() ?? 'Unknown';
                  final isSelected = contentProvider.selectedVodCategoryId == categoryId;
                  
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
              if (contentProvider.vodCategories.isEmpty) {
                await contentProvider.loadVodCategories();
              }
              // Reload items
              final categoryId = contentProvider.selectedVodCategoryId;
              await contentProvider.loadVodItems(
                categoryId: categoryId == 'all' ? null : categoryId,
              );
            },
          ),
        ],
      ),
      body: contentProvider.isLoadingVod
          ? const Center(child: CircularProgressIndicator())
          : contentProvider.filteredVodItems.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    if (contentProvider.vodCategories.isEmpty) {
                      await contentProvider.loadVodCategories();
                    }
                    final categoryId = contentProvider.selectedVodCategoryId;
                    await contentProvider.loadVodItems(
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
                              Icons.movie_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No movies available',
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
                    final categoryId = contentProvider.selectedVodCategoryId;
                    await contentProvider.loadVodItems(
                      categoryId: categoryId == 'all' ? null : categoryId,
                    );
                  },
                  child: _buildMovieGrid(
                    contentProvider.filteredVodItems,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                ),
    );
  }

  Widget _buildMovieGrid(List<VodItem> movies, {required bool isDesktop, required bool isTablet}) {
    final crossAxisCount = isDesktop ? 6 : (isTablet ? 4 : 3);
    final aspectRatio = 2 / 3; // Movie poster aspect ratio

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildMovieCard(VodItem movie) {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => _showMovieDetails(movie),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster image
            if (movie.posterUrl != null)
              Image.network(
                movie.posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(movie.name),
              )
            else
              _buildPlaceholder(movie.name),
            
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
                      movie.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (movie.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating!,
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
                  movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: movie.isFavorite ? Colors.red : Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  contentProvider.toggleVodFavorite(movie.id);
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
            Icons.movie,
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

  void _showMovieDetails(VodItem movie) {
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
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildMovieDetailsContent(movie),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieDetailsContent(VodItem movie) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Backdrop
        if (movie.backdropUrl != null)
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  movie.backdropUrl!,
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
                    movie.name,
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
                      movie.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (movie.rating != null)
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
                            movie.rating!,
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
                  if (movie.releaseDate != null)
                    Chip(
                      label: Text(movie.releaseDate!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (movie.duration != null)
                    Chip(
                      label: Text(movie.duration!),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (movie.genre != null)
                    Chip(
                      label: Text(movie.genre!),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Play button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    // Convert VodItem to Channel for player
                    final channel = Channel(
                      name: movie.name,
                      url: movie.streamUrl,
                      logoUrl: movie.posterUrl,
                      groupTitle: 'Movies',
                      tvgId: movie.id,
                    );
                    playerProvider.playChannel(channel);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Movie'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Plot
              if (movie.plot != null) ...[
                Text(
                  'Plot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.plot!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              
              // Cast
              if (movie.cast != null) ...[
                Text(
                  'Cast',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.cast!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              
              // Director
              if (movie.director != null) ...[
                Text(
                  'Director',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.director!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
