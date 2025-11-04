class Playlist {
  final String name;
  final String? url;
  final String? filePath;
  final DateTime addedDate;
  final String? username;
  final String? password;
  final bool requiresAuth;
  final bool isEncrypted; // Flag to indicate if credentials are encrypted

  Playlist({
    required this.name,
    this.url,
    this.filePath,
    required this.addedDate,
    this.username,
    this.password,
    this.requiresAuth = false,
    this.isEncrypted = false,
  });

  /// Convert to JSON for storage (credentials should already be encrypted)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'filePath': filePath,
      'addedDate': addedDate.toIso8601String(),
      'username': username, // Stored as encrypted string
      'password': password, // Stored as encrypted string
      'requiresAuth': requiresAuth,
      'isEncrypted': isEncrypted,
    };
  }

  /// Create from JSON (credentials will be encrypted strings)
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'] as String,
      url: json['url'] as String?,
      filePath: json['filePath'] as String?,
      addedDate: DateTime.parse(json['addedDate'] as String),
      username: json['username'] as String?, // Encrypted string
      password: json['password'] as String?, // Encrypted string
      requiresAuth: json['requiresAuth'] as bool? ?? false,
      isEncrypted: json['isEncrypted'] as bool? ?? false,
    );
  }

  Playlist copyWith({
    String? name,
    String? url,
    String? filePath,
    DateTime? addedDate,
    String? username,
    String? password,
    bool? requiresAuth,
    bool? isEncrypted,
  }) {
    return Playlist(
      name: name ?? this.name,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      addedDate: addedDate ?? this.addedDate,
      username: username ?? this.username,
      password: password ?? this.password,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}
