class Channel {
  final String name;
  final String url;
  final String? logoUrl;
  final String? groupTitle;
  final String? tvgId;
  final String? tvgName;
  bool isFavorite;

  Channel({
    required this.name,
    required this.url,
    this.logoUrl,
    this.groupTitle,
    this.tvgId,
    this.tvgName,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'logoUrl': logoUrl,
      'groupTitle': groupTitle,
      'tvgId': tvgId,
      'tvgName': tvgName,
      'isFavorite': isFavorite,
    };
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: json['name'] as String,
      url: json['url'] as String,
      logoUrl: json['logoUrl'] as String?,
      groupTitle: json['groupTitle'] as String?,
      tvgId: json['tvgId'] as String?,
      tvgName: json['tvgName'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Channel copyWith({
    String? name,
    String? url,
    String? logoUrl,
    String? groupTitle,
    String? tvgId,
    String? tvgName,
    bool? isFavorite,
  }) {
    return Channel(
      name: name ?? this.name,
      url: url ?? this.url,
      logoUrl: logoUrl ?? this.logoUrl,
      groupTitle: groupTitle ?? this.groupTitle,
      tvgId: tvgId ?? this.tvgId,
      tvgName: tvgName ?? this.tvgName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
