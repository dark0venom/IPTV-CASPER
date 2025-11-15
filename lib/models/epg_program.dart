/// Model for EPG (Electronic Program Guide) program information
class EpgProgram {
  final String id;
  final String channelId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? category;
  final String? icon;
  final String? rating;
  final List<String>? actors;
  final List<String>? directors;
  final int? year;
  final String? episodeNum;
  final bool? isCatchupAvailable;

  EpgProgram({
    required this.id,
    required this.channelId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.category,
    this.icon,
    this.rating,
    this.actors,
    this.directors,
    this.year,
    this.episodeNum,
    this.isCatchupAvailable,
  });

  /// Check if the program is currently airing
  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if the program has already aired
  bool get hasAired {
    return DateTime.now().isAfter(endTime);
  }

  /// Check if the program is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  /// Get progress percentage (0-100) if program is live
  double get progress {
    if (!isLive) return 0;
    final now = DateTime.now();
    final total = endTime.difference(startTime).inSeconds;
    final elapsed = now.difference(startTime).inSeconds;
    return (elapsed / total * 100).clamp(0, 100);
  }

  /// Check if catch-up is available for this program
  bool get hasCatchup => isCatchupAvailable ?? false;

  /// Get duration in seconds
  int get duration {
    return endTime.difference(startTime).inSeconds;
  }

  /// Get duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Create from JSON
  factory EpgProgram.fromJson(Map<String, dynamic> json) {
    return EpgProgram(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      category: json['category'] as String?,
      icon: json['icon'] as String?,
      rating: json['rating'] as String?,
      actors: (json['actors'] as List<dynamic>?)?.cast<String>(),
      directors: (json['directors'] as List<dynamic>?)?.cast<String>(),
      year: json['year'] as int?,
      episodeNum: json['episode_num'] as String?,
      isCatchupAvailable: json['is_catchup_available'] as bool?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'category': category,
      'icon': icon,
      'rating': rating,
      'actors': actors,
      'directors': directors,
      'year': year,
      'episode_num': episodeNum,
      'is_catchup_available': isCatchupAvailable,
    };
  }

  /// Create from XMLTV format
  factory EpgProgram.fromXmltv(Map<String, dynamic> xmlData, String channelId) {
    return EpgProgram(
      id: xmlData['@start'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      channelId: channelId,
      title: xmlData['title']?['#text'] ?? xmlData['title'] ?? 'Unknown',
      description: xmlData['desc']?['#text'] ?? xmlData['desc'],
      startTime: _parseXmltvTime(xmlData['@start']),
      endTime: _parseXmltvTime(xmlData['@stop']),
      category: xmlData['category']?['#text'] ?? xmlData['category'],
      icon: xmlData['icon']?['@src'],
      rating: xmlData['rating']?['value'],
      episodeNum: xmlData['episode-num']?['#text'],
    );
  }

  /// Parse XMLTV timestamp format (YYYYMMDDHHmmss +TZ)
  static DateTime _parseXmltvTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return DateTime.now();
    
    try {
      // Format: 20250114120000 +0000
      final cleanTime = timeStr.split(' ')[0];
      final year = int.parse(cleanTime.substring(0, 4));
      final month = int.parse(cleanTime.substring(4, 6));
      final day = int.parse(cleanTime.substring(6, 8));
      final hour = int.parse(cleanTime.substring(8, 10));
      final minute = int.parse(cleanTime.substring(10, 12));
      final second = int.parse(cleanTime.substring(12, 14));
      
      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'EpgProgram(title: $title, start: $startTime, end: $endTime)';
  }
}
