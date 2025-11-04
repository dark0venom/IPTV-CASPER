/// Model for TV Series
class SeriesItem {
  final String id;
  final String name;
  final String? posterUrl;
  final String? backdropUrl;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? rating;
  final String categoryId;
  final String categoryName;
  final int? episodeRunTime;
  final String? youtubeTrailer;
  bool isFavorite;
  List<Season>? seasons;

  SeriesItem({
    required this.id,
    required this.name,
    this.posterUrl,
    this.backdropUrl,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.rating,
    required this.categoryId,
    required this.categoryName,
    this.episodeRunTime,
    this.youtubeTrailer,
    this.isFavorite = false,
    this.seasons,
  });

  factory SeriesItem.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>?;
    
    return SeriesItem(
      id: json['series_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Series',
      posterUrl: json['cover']?.toString() ?? info?['cover']?.toString(),
      backdropUrl: info?['backdrop_path']?.toString().isNotEmpty == true 
          ? info!['backdrop_path'].toString() 
          : null,
      plot: info?['plot']?.toString() ?? info?['description']?.toString(),
      cast: info?['cast']?.toString(),
      director: info?['director']?.toString(),
      genre: info?['genre']?.toString(),
      releaseDate: info?['releasedate']?.toString() ?? info?['release_date']?.toString(),
      rating: info?['rating']?.toString() ?? info?['rating_5based']?.toString(),
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? 'Series',
      episodeRunTime: info?['episode_run_time'] != null 
          ? int.tryParse(info!['episode_run_time'].toString()) 
          : null,
      youtubeTrailer: info?['youtube_trailer']?.toString(),
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'plot': plot,
      'cast': cast,
      'director': director,
      'genre': genre,
      'releaseDate': releaseDate,
      'rating': rating,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'episodeRunTime': episodeRunTime,
      'youtubeTrailer': youtubeTrailer,
      'isFavorite': isFavorite,
      'seasons': seasons?.map((s) => s.toJson()).toList(),
    };
  }

  SeriesItem copyWith({
    String? id,
    String? name,
    String? posterUrl,
    String? backdropUrl,
    String? plot,
    String? cast,
    String? director,
    String? genre,
    String? releaseDate,
    String? rating,
    String? categoryId,
    String? categoryName,
    int? episodeRunTime,
    String? youtubeTrailer,
    bool? isFavorite,
    List<Season>? seasons,
  }) {
    return SeriesItem(
      id: id ?? this.id,
      name: name ?? this.name,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      plot: plot ?? this.plot,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      episodeRunTime: episodeRunTime ?? this.episodeRunTime,
      youtubeTrailer: youtubeTrailer ?? this.youtubeTrailer,
      isFavorite: isFavorite ?? this.isFavorite,
      seasons: seasons ?? this.seasons,
    );
  }
}

/// Model for Season
class Season {
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? airDate;
  final String? overview;
  final String? posterUrl;
  final List<Episode> episodes;

  Season({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.airDate,
    this.overview,
    this.posterUrl,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    final episodesJson = json['episodes'] as List?;
    final episodes = episodesJson?.map((e) => Episode.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    
    return Season(
      seasonNumber: json['season_number'] ?? 0,
      name: json['name']?.toString() ?? 'Season ${json['season_number']}',
      episodeCount: json['episode_count'] ?? episodes.length,
      airDate: json['air_date']?.toString(),
      overview: json['overview']?.toString(),
      posterUrl: json['cover']?.toString(),
      episodes: episodes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season_number': seasonNumber,
      'name': name,
      'episode_count': episodeCount,
      'air_date': airDate,
      'overview': overview,
      'posterUrl': posterUrl,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model for Episode
class Episode {
  final String id;
  final int episodeNum;
  final String title;
  final String streamUrl;
  final String? plot;
  final String? duration;
  final String? rating;
  final String? releaseDate;
  final String? posterUrl;
  final String containerExtension;

  Episode({
    required this.id,
    required this.episodeNum,
    required this.title,
    required this.streamUrl,
    this.plot,
    this.duration,
    this.rating,
    this.releaseDate,
    this.posterUrl,
    this.containerExtension = 'mp4',
  });

  factory Episode.fromJson(Map<String, dynamic> json, {String? baseUrl, String? username, String? password, String? seriesId}) {
    final episodeId = json['id']?.toString() ?? '';
    final containerExt = json['container_extension']?.toString() ?? 'mp4';
    
    // Build stream URL if credentials provided
    String streamUrl = '';
    if (baseUrl != null && username != null && password != null && episodeId.isNotEmpty) {
      streamUrl = '$baseUrl/series/$username/$password/$episodeId.$containerExt';
    }
    
    final info = json['info'] as Map<String, dynamic>?;
    
    return Episode(
      id: episodeId,
      episodeNum: json['episode_num'] ?? 0,
      title: json['title']?.toString() ?? info?['title']?.toString() ?? 'Episode ${json['episode_num']}',
      streamUrl: streamUrl,
      plot: info?['plot']?.toString() ?? info?['description']?.toString(),
      duration: info?['duration']?.toString() ?? json['duration']?.toString(),
      rating: info?['rating']?.toString(),
      releaseDate: info?['releasedate']?.toString() ?? info?['air_date']?.toString(),
      posterUrl: info?['movie_image']?.toString() ?? json['cover']?.toString(),
      containerExtension: containerExt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episode_num': episodeNum,
      'title': title,
      'streamUrl': streamUrl,
      'plot': plot,
      'duration': duration,
      'rating': rating,
      'releaseDate': releaseDate,
      'posterUrl': posterUrl,
      'containerExtension': containerExtension,
    };
  }
}
