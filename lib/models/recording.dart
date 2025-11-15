/// Model for scheduled and completed recordings
class Recording {
  final String id;
  final String channelId;
  final String channelName;
  final String? programTitle;
  final DateTime startTime;
  final DateTime endTime;
  final RecordingStatus status;
  final String? filePath;
  final int? fileSize;
  final RecordingQuality quality;
  final String? thumbnailPath;
  final DateTime createdAt;
  final String? errorMessage;

  Recording({
    required this.id,
    required this.channelId,
    required this.channelName,
    this.programTitle,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.filePath,
    this.fileSize,
    this.quality = RecordingQuality.high,
    this.thumbnailPath,
    required this.createdAt,
    this.errorMessage,
  });

  /// Get title (alias for programTitle with fallback)
  String get title => programTitle ?? 'Recording from $channelName';

  /// Get duration in seconds
  int get duration {
    return endTime.difference(startTime).inSeconds;
  }

  /// Get duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Get recording progress (0.0 to 1.0)
  double get progress {
    if (status != RecordingStatus.recording) {
      return status == RecordingStatus.completed ? 1.0 : 0.0;
    }
    final now = DateTime.now();
    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(endTime)) return 1.0;
    
    final total = endTime.difference(startTime).inSeconds;
    final elapsed = now.difference(startTime).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Get file size in MB
  double? get fileSizeMB {
    if (fileSize == null) return null;
    return fileSize! / (1024 * 1024);
  }

  /// Check if recording is scheduled for future
  bool get isScheduled {
    return status == RecordingStatus.scheduled && DateTime.now().isBefore(startTime);
  }

  /// Check if recording is currently in progress
  bool get isRecording {
    return status == RecordingStatus.recording;
  }

  /// Check if recording is completed
  bool get isCompleted {
    return status == RecordingStatus.completed && filePath != null;
  }

  /// Create from JSON
  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      channelName: json['channel_name'] as String,
      programTitle: json['program_title'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: RecordingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RecordingStatus.scheduled,
      ),
      filePath: json['file_path'] as String?,
      fileSize: json['file_size'] as int?,
      quality: RecordingQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => RecordingQuality.high,
      ),
      thumbnailPath: json['thumbnail_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'channel_name': channelName,
      'program_title': programTitle,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name,
      'file_path': filePath,
      'file_size': fileSize,
      'quality': quality.name,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt.toIso8601String(),
      'error_message': errorMessage,
    };
  }

  /// Create a copy with updated fields
  Recording copyWith({
    String? id,
    String? channelId,
    String? channelName,
    String? programTitle,
    DateTime? startTime,
    DateTime? endTime,
    RecordingStatus? status,
    String? filePath,
    int? fileSize,
    RecordingQuality? quality,
    String? thumbnailPath,
    DateTime? createdAt,
    String? errorMessage,
  }) {
    return Recording(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      programTitle: programTitle ?? this.programTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      quality: quality ?? this.quality,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'Recording(title: $programTitle, status: $status, start: $startTime)';
  }
}

/// Recording status enum
enum RecordingStatus {
  scheduled,
  recording,
  completed,
  failed,
  cancelled,
}

/// Recording quality enum
enum RecordingQuality {
  low,      // 480p
  medium,   // 720p
  high,     // 1080p
  original, // Original stream quality
}

extension RecordingQualityExtension on RecordingQuality {
  String get displayName {
    switch (this) {
      case RecordingQuality.low:
        return 'Low (480p)';
      case RecordingQuality.medium:
        return 'Medium (720p)';
      case RecordingQuality.high:
        return 'High (1080p)';
      case RecordingQuality.original:
        return 'Original';
    }
  }

  String get resolution {
    switch (this) {
      case RecordingQuality.low:
        return '854x480';
      case RecordingQuality.medium:
        return '1280x720';
      case RecordingQuality.high:
        return '1920x1080';
      case RecordingQuality.original:
        return 'Original';
    }
  }
}
