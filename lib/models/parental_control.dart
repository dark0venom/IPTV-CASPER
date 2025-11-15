/// Model for parental control settings
class ParentalControl {
  final bool isEnabled;
  final String? pinCode;
  final List<String> blockedChannelIds;
  final List<String> blockedCategories;
  final List<ContentRating> allowedRatings;
  final TimeRestriction? timeRestriction;
  final bool requirePinForSettings;
  final bool requirePinForAdultContent;

  ParentalControl({
    this.isEnabled = false,
    this.pinCode,
    this.blockedChannelIds = const [],
    this.blockedCategories = const [],
    this.allowedRatings = const [],
    this.timeRestriction,
    this.requirePinForSettings = true,
    this.requirePinForAdultContent = true,
  });

  /// Create disabled parental controls
  factory ParentalControl.disabled() {
    return ParentalControl(isEnabled: false);
  }

  /// Create enabled parental controls with default settings
  factory ParentalControl.enabled() {
    return ParentalControl(
      isEnabled: true,
      requirePinForSettings: true,
      requirePinForAdultContent: true,
    );
  }

  /// Get maximum allowed rating (highest rating in allowedRatings)
  ContentRating? get maxRating {
    if (allowedRatings.isEmpty) return null;
    return allowedRatings.reduce((a, b) => a.index > b.index ? a : b);
  }

  /// Get list of blocked channels (alias for blockedChannelIds)
  List<String> get blockedChannels => blockedChannelIds;

  /// Get restriction start time in minutes (from first day restriction)
  int? get restrictedStartTime {
    if (timeRestriction == null || timeRestriction!.allowedTimes.isEmpty) {
      return null;
    }
    return timeRestriction!.allowedTimes.values.first.startMinutes;
  }

  /// Get restriction end time in minutes (from first day restriction)
  int? get restrictedEndTime {
    if (timeRestriction == null || timeRestriction!.allowedTimes.isEmpty) {
      return null;
    }
    return timeRestriction!.allowedTimes.values.first.endMinutes;
  }

  /// Check if a channel is blocked
  bool isChannelBlocked(String channelId) {
    return blockedChannelIds.contains(channelId);
  }

  /// Check if a category is blocked
  bool isCategoryBlocked(String category) {
    return blockedCategories.any((blocked) => 
      category.toLowerCase().contains(blocked.toLowerCase()));
  }

  /// Check if content with given rating is allowed
  bool isRatingAllowed(ContentRating rating) {
    if (allowedRatings.isEmpty) return true;
    return allowedRatings.contains(rating) || 
           allowedRatings.any((allowed) => allowed.index <= rating.index);
  }

  /// Check if current time is within allowed viewing time
  bool isTimeAllowed() {
    if (timeRestriction == null) return true;
    return timeRestriction!.isAllowed(DateTime.now());
  }

  /// Verify PIN code
  bool verifyPin(String enteredPin) {
    if (pinCode == null) return true;
    return pinCode == enteredPin;
  }

  /// Create from JSON
  factory ParentalControl.fromJson(Map<String, dynamic> json) {
    return ParentalControl(
      isEnabled: json['is_enabled'] as bool? ?? false,
      pinCode: json['pin_code'] as String?,
      blockedChannelIds: (json['blocked_channel_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      blockedCategories: (json['blocked_categories'] as List<dynamic>?)?.cast<String>() ?? [],
      allowedRatings: (json['allowed_ratings'] as List<dynamic>?)
          ?.map((r) => ContentRating.values.firstWhere(
                (e) => e.name == r,
                orElse: () => ContentRating.general,
              ))
          .toList() ?? [],
      timeRestriction: json['time_restriction'] != null
          ? TimeRestriction.fromJson(json['time_restriction'] as Map<String, dynamic>)
          : null,
      requirePinForSettings: json['require_pin_for_settings'] as bool? ?? true,
      requirePinForAdultContent: json['require_pin_for_adult_content'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'pin_code': pinCode,
      'blocked_channel_ids': blockedChannelIds,
      'blocked_categories': blockedCategories,
      'allowed_ratings': allowedRatings.map((r) => r.name).toList(),
      'time_restriction': timeRestriction?.toJson(),
      'require_pin_for_settings': requirePinForSettings,
      'require_pin_for_adult_content': requirePinForAdultContent,
    };
  }

  /// Create a copy with updated fields
  ParentalControl copyWith({
    bool? isEnabled,
    String? pinCode,
    List<String>? blockedChannelIds,
    List<String>? blockedCategories,
    List<ContentRating>? allowedRatings,
    TimeRestriction? timeRestriction,
    bool? requirePinForSettings,
    bool? requirePinForAdultContent,
  }) {
    return ParentalControl(
      isEnabled: isEnabled ?? this.isEnabled,
      pinCode: pinCode ?? this.pinCode,
      blockedChannelIds: blockedChannelIds ?? this.blockedChannelIds,
      blockedCategories: blockedCategories ?? this.blockedCategories,
      allowedRatings: allowedRatings ?? this.allowedRatings,
      timeRestriction: timeRestriction ?? this.timeRestriction,
      requirePinForSettings: requirePinForSettings ?? this.requirePinForSettings,
      requirePinForAdultContent: requirePinForAdultContent ?? this.requirePinForAdultContent,
    );
  }
}

/// Content rating enum
enum ContentRating {
  general,      // G - General Audiences
  parentalGuidance, // PG - Parental Guidance
  pg13,         // PG-13
  restricted,   // R - Restricted
  mature,       // NC-17 / Adult
}

extension ContentRatingExtension on ContentRating {
  String get displayName {
    switch (this) {
      case ContentRating.general:
        return 'G (General)';
      case ContentRating.parentalGuidance:
        return 'PG (Parental Guidance)';
      case ContentRating.pg13:
        return 'PG-13';
      case ContentRating.restricted:
        return 'R (Restricted)';
      case ContentRating.mature:
        return 'NC-17 (Mature)';
    }
  }

  String get description {
    switch (this) {
      case ContentRating.general:
        return 'All ages admitted';
      case ContentRating.parentalGuidance:
        return 'Some material may not be suitable for children';
      case ContentRating.pg13:
        return 'Some material may be inappropriate for children under 13';
      case ContentRating.restricted:
        return 'Under 17 requires accompanying parent or adult guardian';
      case ContentRating.mature:
        return 'Adults only';
    }
  }
}

/// Time restriction model
class TimeRestriction {
  final Map<int, TimeRange> allowedTimes; // day of week (1-7) -> time range

  TimeRestriction({required this.allowedTimes});

  /// Check if given time is allowed
  bool isAllowed(DateTime time) {
    final dayOfWeek = time.weekday;
    final timeRange = allowedTimes[dayOfWeek];
    
    if (timeRange == null) return true; // No restriction for this day
    
    final currentMinutes = time.hour * 60 + time.minute;
    return currentMinutes >= timeRange.startMinutes && 
           currentMinutes <= timeRange.endMinutes;
  }

  factory TimeRestriction.fromJson(Map<String, dynamic> json) {
    final Map<int, TimeRange> times = {};
    json.forEach((key, value) {
      final dayOfWeek = int.tryParse(key);
      if (dayOfWeek != null && value is Map<String, dynamic>) {
        times[dayOfWeek] = TimeRange.fromJson(value);
      }
    });
    return TimeRestriction(allowedTimes: times);
  }

  Map<String, dynamic> toJson() {
    return allowedTimes.map((key, value) => MapEntry(key.toString(), value.toJson()));
  }
}

/// Time range model
class TimeRange {
  final int startMinutes; // minutes since midnight
  final int endMinutes;   // minutes since midnight

  TimeRange({required this.startMinutes, required this.endMinutes});

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      startMinutes: json['start_minutes'] as int,
      endMinutes: json['end_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_minutes': startMinutes,
      'end_minutes': endMinutes,
    };
  }

  /// Create from hours and minutes
  factory TimeRange.fromHours(int startHour, int startMinute, int endHour, int endMinute) {
    return TimeRange(
      startMinutes: startHour * 60 + startMinute,
      endMinutes: endHour * 60 + endMinute,
    );
  }

  String get displayString {
    final startHour = startMinutes ~/ 60;
    final startMin = startMinutes % 60;
    final endHour = endMinutes ~/ 60;
    final endMin = endMinutes % 60;
    
    return '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} - '
           '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }
}
