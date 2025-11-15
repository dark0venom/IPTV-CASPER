import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/epg_program.dart';

/// Service for fetching and managing EPG (Electronic Program Guide) data
class EpgService {
  final Dio _dio = Dio();
  final Map<String, List<EpgProgram>> _epgCache = {};
  DateTime? _lastFetchTime;

  /// Fetch EPG data from URL (XMLTV or JSON format)
  Future<Map<String, List<EpgProgram>>> fetchEpgData(String epgUrl) async {
    try {
      final response = await _dio.get(epgUrl);
      
      if (response.statusCode == 200) {
        // Determine format and parse accordingly
        if (epgUrl.contains('.xml') || epgUrl.contains('xmltv')) {
          return _parseXmltvFormat(response.data);
        } else {
          return _parseJsonFormat(response.data);
        }
      }
      
      return {};
    } catch (e) {
      print('Error fetching EPG data: $e');
      return {};
    }
  }

  /// Parse XMLTV format EPG data
  Map<String, List<EpgProgram>> _parseXmltvFormat(dynamic xmlData) {
    final Map<String, List<EpgProgram>> epgData = {};
    
    try {
      // Basic XMLTV parsing (simplified version)
      // In production, use xml package for proper parsing
      final String xmlString = xmlData is String ? xmlData : xmlData.toString();
      
      // This is a placeholder - implement proper XML parsing with xml package
      // For now, return empty data
      print('XMLTV parsing requires xml package - implement with proper XML parser');
      
    } catch (e) {
      print('Error parsing XMLTV: $e');
    }
    
    return epgData;
  }

  /// Parse JSON format EPG data
  Map<String, List<EpgProgram>> _parseJsonFormat(dynamic jsonData) {
    final Map<String, List<EpgProgram>> epgData = {};
    
    try {
      final Map<String, dynamic> data = jsonData is String 
          ? json.decode(jsonData) 
          : jsonData as Map<String, dynamic>;
      
      if (data.containsKey('epg')) {
        final epgList = data['epg'] as Map<String, dynamic>;
        
        epgList.forEach((channelId, programs) {
          if (programs is List) {
            epgData[channelId] = programs
                .map((p) => EpgProgram.fromJson(p as Map<String, dynamic>))
                .toList();
          }
        });
      }
    } catch (e) {
      print('Error parsing JSON EPG: $e');
    }
    
    return epgData;
  }

  /// Get EPG programs for a specific channel
  List<EpgProgram> getChannelPrograms(String channelId) {
    return _epgCache[channelId] ?? [];
  }

  /// Get current program for a channel
  EpgProgram? getCurrentProgram(String channelId) {
    final programs = getChannelPrograms(channelId);
    final now = DateTime.now();
    
    try {
      return programs.firstWhere(
        (p) => p.startTime.isBefore(now) && p.endTime.isAfter(now),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get next program for a channel
  EpgProgram? getNextProgram(String channelId) {
    final programs = getChannelPrograms(channelId);
    final now = DateTime.now();
    
    try {
      return programs.firstWhere((p) => p.startTime.isAfter(now));
    } catch (e) {
      return null;
    }
  }

  /// Get programs for a specific time range
  List<EpgProgram> getProgramsByTimeRange(
    String channelId,
    DateTime start,
    DateTime end,
  ) {
    final programs = getChannelPrograms(channelId);
    return programs.where((p) {
      return (p.startTime.isAfter(start) || p.startTime.isAtSameMomentAs(start)) &&
             (p.endTime.isBefore(end) || p.endTime.isAtSameMomentAs(end));
    }).toList();
  }

  /// Fetch EPG from Xtream Codes API
  Future<Map<String, List<EpgProgram>>> fetchXtreamEpg(
    String serverUrl,
    String username,
    String password,
    String streamId,
  ) async {
    try {
      final epgUrl = '$serverUrl/player_api.php?username=$username&password=$password&action=get_short_epg&stream_id=$streamId&limit=10';
      
      final response = await _dio.get(epgUrl);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, List<EpgProgram>> epgData = {};
        
        if (data is Map && data.containsKey('epg_listings')) {
          final listings = data['epg_listings'] as List<dynamic>;
          
          final programs = listings.map((listing) {
            return EpgProgram(
              id: listing['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
              channelId: streamId,
              title: listing['title'] ?? 'Unknown',
              description: listing['description'],
              startTime: DateTime.parse(listing['start']),
              endTime: DateTime.parse(listing['stop']),
              isCatchupAvailable: listing['has_archive'] == '1',
            );
          }).toList();
          
          epgData[streamId] = programs;
        }
        
        return epgData;
      }
      
      return {};
    } catch (e) {
      print('Error fetching Xtream EPG: $e');
      return {};
    }
  }

  /// Update EPG cache
  void updateCache(Map<String, List<EpgProgram>> epgData) {
    _epgCache.clear();
    _epgCache.addAll(epgData);
    _lastFetchTime = DateTime.now();
  }

  /// Check if cache is stale (older than 1 hour)
  bool isCacheStale() {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!).inHours >= 1;
  }

  /// Clear EPG cache
  void clearCache() {
    _epgCache.clear();
    _lastFetchTime = null;
  }

  /// Get all cached channel IDs with EPG data
  List<String> getCachedChannels() {
    return _epgCache.keys.toList();
  }
}
