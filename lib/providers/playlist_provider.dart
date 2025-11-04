import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/channel.dart';
import '../models/playlist.dart';
import '../services/m3u_parser.dart';
import '../services/encryption_service.dart';

class PlaylistProvider with ChangeNotifier {
  List<Channel> _channels = [];
  List<Channel> _filteredChannels = [];
  List<Playlist> _playlists = [];
  String _searchQuery = '';
  String? _selectedGroup;
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  final EncryptionService _encryptionService = EncryptionService();

  List<Channel> get channels => _showFavoritesOnly 
      ? _filteredChannels.where((c) => c.isFavorite).toList() 
      : _filteredChannels;
  List<Playlist> get playlists => _playlists;
  List<String> get groups {
    final groupSet = _channels
        .where((c) => c.groupTitle != null)
        .map((c) => c.groupTitle!)
        .toSet();
    return groupSet.toList()..sort();
  }
  String get searchQuery => _searchQuery;
  String? get selectedGroup => _selectedGroup;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  PlaylistProvider() {
    _initializeAndLoad();
  }

  /// Initialize encryption service and load stored data
  Future<void> _initializeAndLoad() async {
    await _encryptionService.initialize();
    await _loadFromStorage();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load channels
    final channelsJson = prefs.getString('channels');
    if (channelsJson != null) {
      final List<dynamic> channelsList = json.decode(channelsJson);
      _channels = channelsList.map((c) => Channel.fromJson(c)).toList();
      _filteredChannels = List.from(_channels);
    }

    // Load playlists with encrypted credentials
    final playlistsJson = prefs.getString('playlists');
    if (playlistsJson != null) {
      final List<dynamic> playlistsList = json.decode(playlistsJson);
      _playlists = playlistsList.map((p) => Playlist.fromJson(p)).toList();
      
      // Migrate old playlists to encrypted format
      await _migrateToEncryption();
    }

    notifyListeners();
  }

  /// Migrate existing plain-text credentials to encrypted format
  Future<void> _migrateToEncryption() async {
    bool needsMigration = false;

    for (int i = 0; i < _playlists.length; i++) {
      final playlist = _playlists[i];
      
      // Check if playlist has credentials but is not encrypted
      if ((playlist.username != null || playlist.password != null) && 
          !playlist.isEncrypted) {
        
        print('🔐 Migrating playlist "${playlist.name}" to encrypted storage...');
        
        // Encrypt credentials
        final encryptedCreds = await _encryptionService.encryptCredentials(
          username: playlist.username,
          password: playlist.password,
        );

        // Update playlist with encrypted credentials
        _playlists[i] = playlist.copyWith(
          username: encryptedCreds['username'],
          password: encryptedCreds['password'],
          isEncrypted: true,
        );

        needsMigration = true;
      }
    }

    if (needsMigration) {
      await _saveToStorage();
      print('✅ Credentials migration completed');
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save channels
    final channelsJson = json.encode(_channels.map((c) => c.toJson()).toList());
    await prefs.setString('channels', channelsJson);

    // Save playlists
    final playlistsJson = json.encode(_playlists.map((p) => p.toJson()).toList());
    await prefs.setString('playlists', playlistsJson);
  }

  Future<void> loadPlaylistFromUrl(
    String url, 
    String name, {
    String? username,
    String? password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final parser = M3UParser();
      
      // Use plain-text credentials for fetching (required for HTTP authentication)
      final channels = await parser.parseFromUrl(
        url,
        username: username,
        password: password,
      );
      
      _channels = channels;
      _filteredChannels = List.from(_channels);
      
      // Encrypt credentials before storing
      String? encryptedUsername;
      String? encryptedPassword;
      
      if (username != null || password != null) {
        print('🔐 Encrypting credentials for storage...');
        final encryptedCreds = await _encryptionService.encryptCredentials(
          username: username,
          password: password,
        );
        encryptedUsername = encryptedCreds['username'];
        encryptedPassword = encryptedCreds['password'];
      }
      
      final playlist = Playlist(
        name: name,
        url: url,
        addedDate: DateTime.now(),
        username: encryptedUsername,
        password: encryptedPassword,
        requiresAuth: username != null && password != null,
        isEncrypted: true,
      );
      
      _playlists.removeWhere((p) => p.url == url);
      _playlists.add(playlist);
      
      await _saveToStorage();
      print('✅ Playlist saved with encrypted credentials');
    } catch (e) {
      print('Error loading playlist: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlaylistFromFile(String filePath, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final parser = M3UParser();
      final channels = await parser.parseFromFile(filePath);
      
      _channels = channels;
      _filteredChannels = List.from(_channels);
      
      final playlist = Playlist(
        name: name,
        filePath: filePath,
        addedDate: DateTime.now(),
      );
      
      _playlists.removeWhere((p) => p.filePath == filePath);
      _playlists.add(playlist);
      
      await _saveToStorage();
    } catch (e) {
      print('Error loading playlist: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchChannels(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByGroup(String? group) {
    _selectedGroup = group;
    _applyFilters();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredChannels = _channels.where((channel) {
      final matchesSearch = _searchQuery.isEmpty ||
          channel.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesGroup = _selectedGroup == null ||
          channel.groupTitle == _selectedGroup;
      
      return matchesSearch && matchesGroup;
    }).toList();
    
    notifyListeners();
  }

  Future<void> toggleFavorite(Channel channel) async {
    final index = _channels.indexWhere((c) => c.url == channel.url);
    if (index != -1) {
      _channels[index] = channel.copyWith(isFavorite: !channel.isFavorite);
      _applyFilters();
      await _saveToStorage();
    }
  }

  Future<void> removePlaylist(Playlist playlist) async {
    _playlists.remove(playlist);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> reloadPlaylist(Playlist playlist) async {
    if (playlist.url != null) {
      // Decrypt credentials before using them for authentication
      String? username;
      String? password;
      
      if (playlist.isEncrypted && (playlist.username != null || playlist.password != null)) {
        print('🔓 Decrypting credentials for playlist reload...');
        final decryptedCreds = await _encryptionService.decryptCredentials(
          encryptedUsername: playlist.username,
          encryptedPassword: playlist.password,
        );
        username = decryptedCreds['username'];
        password = decryptedCreds['password'];
      } else {
        // Backward compatibility: use plain text if not encrypted
        username = playlist.username;
        password = playlist.password;
      }
      
      await loadPlaylistFromUrl(
        playlist.url!,
        playlist.name,
        username: username,
        password: password,
      );
    } else if (playlist.filePath != null) {
      await loadPlaylistFromFile(
        playlist.filePath!,
        playlist.name,
      );
    }
  }

  /// Get decrypted credentials for a playlist
  Future<Map<String, String>?> getDecryptedCredentials(Playlist playlist) async {
    if (playlist.username == null && playlist.password == null) {
      return null;
    }
    
    if (playlist.isEncrypted) {
      final decrypted = await _encryptionService.decryptCredentials(
        encryptedUsername: playlist.username,
        encryptedPassword: playlist.password,
      );
      return {
        'username': decrypted['username'] ?? '',
        'password': decrypted['password'] ?? '',
      };
    } else {
      // Return plain text credentials (backward compatibility)
      return {
        'username': playlist.username ?? '',
        'password': playlist.password ?? '',
      };
    }
  }

  Future<void> clearAllChannels() async {
    _channels.clear();
    _filteredChannels.clear();
    _playlists.clear();
    await _saveToStorage();
    notifyListeners();
  }
}
