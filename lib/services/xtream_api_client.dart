import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../models/vod_item.dart';
import '../models/series_item.dart';

/// Xtream Codes API client - bypasses /get.php by using JSON API directly
/// This works around Cloudflare 884 errors by using player_api.php instead
class XtreamApiClient {
  final String serverUrl;
  final String username;
  final String password;

  XtreamApiClient({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  /// Helper to clean and normalize base URL
  String _cleanBaseUrl(String url) {
    String baseUrl = url.trim();
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    
    // Remove any existing endpoint
    baseUrl = baseUrl
        .replaceAll('/get.php', '')
        .replaceAll('/player_api.php', '')
        .replaceAll('/xmltv.php', '');
    
    return baseUrl;
  }

  /// Get all live TV channels using player_api.php (bypasses Cloudflare /get.php)
  Future<List<Channel>> getLiveChannels() async {
    try {
      print('🔗 Connecting to Xtream API...');
      print('   Server: $serverUrl');
      print('   Username: $username');
      
      // Clean server URL
      String baseUrl = serverUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      // Remove any existing endpoint
      baseUrl = baseUrl
          .replaceAll('/get.php', '')
          .replaceAll('/player_api.php', '')
          .replaceAll('/xmltv.php', '');
      
      // Build API URL for live streams
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_live_streams';
      
      print('   🌐 Fetching live streams from API...');
      
      // Use minimal headers (TiviMate style)
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100', // FFmpeg user agent (most compatible)
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      print('   📥 Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('   ❌ API error: ${response.statusCode}');
        print('   📝 Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        throw Exception('API returned status ${response.statusCode}');
      }
      
      print('   ✅ API response received (${response.body.length} bytes)');
      
      // Parse JSON response
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        print('   ⚠️ Unexpected response format');
        throw Exception('API response is not a list');
      }
      
      print('   📺 Found ${jsonData.length} channels');
      
      // Convert to Channel objects
      final channels = <Channel>[];
      
      for (var item in jsonData) {
        try {
          final streamId = item['stream_id']?.toString() ?? item['id']?.toString() ?? '';
          final name = item['name']?.toString() ?? 'Unknown Channel';
          final logo = item['stream_icon']?.toString() ?? '';
          final categoryId = item['category_id']?.toString() ?? '';
          
          // Build stream URL
          // Format: http://server:port/live/username/password/streamId.ext
          final streamUrl = '$baseUrl/live/$username/$password/$streamId.ts';
          
          final channel = Channel(
            name: name,
            url: streamUrl,
            logoUrl: logo.isNotEmpty ? logo : null,
            groupTitle: categoryId.isNotEmpty ? 'Category $categoryId' : 'Live TV',
            tvgId: streamId,
          );
          
          channels.add(channel);
        } catch (e) {
          print('   ⚠️ Failed to parse channel: $e');
          continue;
        }
      }
      
      print('   ✅ Successfully parsed ${channels.length} channels');
      return channels;
      
    } catch (e) {
      print('   ❌ Error: $e');
      rethrow;
    }
  }
  
  /// Get VOD categories
  Future<List<Map<String, dynamic>>> getVodCategories() async {
    try {
      String baseUrl = _cleanBaseUrl(serverUrl);
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_categories';
      
      print('   🗂️ Fetching VOD categories...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        return [];
      }
      
      print('   ✅ Found ${jsonData.length} VOD categories');
      return List<Map<String, dynamic>>.from(jsonData);
      
    } catch (e) {
      print('   ❌ Error: $e');
      return [];
    }
  }

  /// Get VOD items with full metadata
  Future<List<VodItem>> getVodItems({String? categoryId}) async {
    try {
      String baseUrl = _cleanBaseUrl(serverUrl);
      
      String apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_streams';
      if (categoryId != null && categoryId.isNotEmpty) {
        apiUrl += '&category_id=$categoryId';
      }
      
      print('   🌐 Fetching VOD items${categoryId != null ? ' for category $categoryId' : ''}...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        throw Exception('API response is not a list');
      }
      
      print('   🎬 Found ${jsonData.length} VOD items');
      
      final vodItems = <VodItem>[];
      
      for (var item in jsonData) {
        try {
          final vodItem = VodItem.fromJson(item, baseUrl, username, password);
          vodItems.add(vodItem);
        } catch (e) {
          print('   ⚠️ Failed to parse VOD item: $e');
          continue;
        }
      }
      
      print('   ✅ Successfully parsed ${vodItems.length} VOD items');
      return vodItems;
      
    } catch (e) {
      print('   ❌ Error: $e');
      rethrow;
    }
  }

  /// Get VOD info with full details
  Future<VodItem?> getVodInfo(String vodId) async {
    try {
      String baseUrl = _cleanBaseUrl(serverUrl);
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_info&vod_id=$vodId';
      
      print('   📝 Fetching VOD info for $vodId...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! Map) {
        return null;
      }
      
      // Merge info with main data
      final info = jsonData['info'] as Map<String, dynamic>?;
      final movieData = jsonData['movie_data'] as Map<String, dynamic>?;
      
      if (movieData != null) {
        final mergedData = {...movieData};
        if (info != null) {
          mergedData['info'] = info;
        }
        return VodItem.fromJson(mergedData, baseUrl, username, password);
      }
      
      return null;
      
    } catch (e) {
      print('   ❌ Error: $e');
      return null;
    }
  }

  /// Get VOD streams (legacy - returns Channel objects for backward compatibility)
  Future<List<Channel>> getVodStreams() async {
    try {
      String baseUrl = serverUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      baseUrl = baseUrl
          .replaceAll('/get.php', '')
          .replaceAll('/player_api.php', '')
          .replaceAll('/xmltv.php', '');
      
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_streams';
      
      print('   🌐 Fetching VOD streams from API...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        throw Exception('API response is not a list');
      }
      
      print('   🎬 Found ${jsonData.length} VOD items');
      
      final channels = <Channel>[];
      
      for (var item in jsonData) {
        try {
          final streamId = item['stream_id']?.toString() ?? item['id']?.toString() ?? '';
          final name = item['name']?.toString() ?? 'Unknown Video';
          final logo = item['stream_icon']?.toString() ?? item['cover']?.toString() ?? '';
          final categoryId = item['category_id']?.toString() ?? '';
          final containerExtension = item['container_extension']?.toString() ?? 'mp4';
          
          // Build stream URL for VOD
          final streamUrl = '$baseUrl/movie/$username/$password/$streamId.$containerExtension';
          
          final channel = Channel(
            name: name,
            url: streamUrl,
            logoUrl: logo.isNotEmpty ? logo : null,
            groupTitle: categoryId.isNotEmpty ? 'VOD Category $categoryId' : 'Movies',
            tvgId: streamId,
          );
          
          channels.add(channel);
        } catch (e) {
          continue;
        }
      }
      
      print('   ✅ Successfully parsed ${channels.length} VOD streams');
      return channels;
      
    } catch (e) {
      print('   ❌ Error: $e');
      rethrow;
    }
  }
  
  /// Get series categories
  Future<List<Map<String, dynamic>>> getSeriesCategories() async {
    try {
      String baseUrl = _cleanBaseUrl(serverUrl);
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_series_categories';
      
      print('   🗂️ Fetching series categories...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        return [];
      }
      
      print('   ✅ Found ${jsonData.length} series categories');
      return List<Map<String, dynamic>>.from(jsonData);
      
    } catch (e) {
      print('   ❌ Error: $e');
      return [];
    }
  }

  /// Get series items with full metadata
  Future<List<SeriesItem>> getSeriesItems({String? categoryId}) async {
    try {
      String baseUrl = _cleanBaseUrl(serverUrl);
      
      String apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_series';
      if (categoryId != null && categoryId.isNotEmpty) {
        apiUrl += '&category_id=$categoryId';
      }
      
      print('   🌐 Fetching series items${categoryId != null ? ' for category $categoryId' : ''}...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        throw Exception('API response is not a list');
      }
      
      print('   📺 Found ${jsonData.length} series');
      
      final seriesItems = <SeriesItem>[];
      
      for (var item in jsonData) {
        try {
          final seriesItem = SeriesItem.fromJson(item);
          seriesItems.add(seriesItem);
        } catch (e) {
          print('   ⚠️ Failed to parse series item: $e');
          continue;
        }
      }
      
      print('   ✅ Successfully parsed ${seriesItems.length} series');
      return seriesItems;
      
    } catch (e) {
      print('   ❌ Error: $e');
      rethrow;
    }
  }

  /// Get series info with seasons and episodes
  Future<SeriesItem?> getSeriesInfo(String seriesId) async {
    try {
      String baseUrl = _cleanBaseUrl(serverUrl);
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_series_info&series_id=$seriesId';
      
      print('   📝 Fetching series info for $seriesId...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! Map) {
        return null;
      }
      
      // Parse series info
      final info = jsonData['info'] as Map<String, dynamic>?;
      final episodesData = jsonData['episodes'] as Map<String, dynamic>?;
      
      if (info == null) {
        return null;
      }
      
      // Create base series item
      final seriesData = {
        'series_id': seriesId,
        'name': info['name'] ?? 'Unknown',
        'cover': info['cover'],
        'info': info,
      };
      
      final seriesItem = SeriesItem.fromJson(seriesData);
      
      // Parse seasons and episodes
      if (episodesData != null) {
        final seasons = <Season>[];
        
        for (var seasonKey in episodesData.keys) {
          final seasonNum = int.tryParse(seasonKey) ?? 0;
          final episodesList = episodesData[seasonKey] as List?;
          
          if (episodesList != null) {
            final episodes = <Episode>[];
            
            for (var episodeData in episodesList) {
              try {
                final episode = Episode.fromJson(
                  episodeData as Map<String, dynamic>,
                  baseUrl: baseUrl,
                  username: username,
                  password: password,
                  seriesId: seriesId,
                );
                episodes.add(episode);
              } catch (e) {
                print('   ⚠️ Failed to parse episode: $e');
              }
            }
            
            episodes.sort((a, b) => a.episodeNum.compareTo(b.episodeNum));
            
            final season = Season(
              seasonNumber: seasonNum,
              name: 'Season $seasonNum',
              episodeCount: episodes.length,
              episodes: episodes,
            );
            
            seasons.add(season);
          }
        }
        
        seasons.sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));
        
        return seriesItem.copyWith(seasons: seasons);
      }
      
      return seriesItem;
      
    } catch (e) {
      print('   ❌ Error: $e');
      return null;
    }
  }

  /// Get series (legacy - returns Channel objects for backward compatibility)
  Future<List<Channel>> getSeries() async {
    try {
      String baseUrl = serverUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      baseUrl = baseUrl
          .replaceAll('/get.php', '')
          .replaceAll('/player_api.php', '')
          .replaceAll('/xmltv.php', '');
      
      final apiUrl = '$baseUrl/player_api.php?username=$username&password=$password&action=get_series';
      
      print('   🌐 Fetching series from API...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Lavf/58.76.100',
          'Accept': '*/*',
        },
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }
      
      final dynamic jsonData = json.decode(response.body);
      
      if (jsonData is! List) {
        throw Exception('API response is not a list');
      }
      
      print('   📺 Found ${jsonData.length} series');
      
      final channels = <Channel>[];
      
      for (var item in jsonData) {
        try {
          final seriesId = item['series_id']?.toString() ?? item['id']?.toString() ?? '';
          final name = item['name']?.toString() ?? 'Unknown Series';
          final logo = item['cover']?.toString() ?? '';
          final categoryId = item['category_id']?.toString() ?? '';
          
          // For series, we'll create a placeholder URL
          // In a full implementation, you'd need to fetch episodes separately
          final streamUrl = '$baseUrl/series/$username/$password/$seriesId';
          
          final channel = Channel(
            name: name,
            url: streamUrl,
            logoUrl: logo.isNotEmpty ? logo : null,
            groupTitle: categoryId.isNotEmpty ? 'Series Category $categoryId' : 'Series',
            tvgId: seriesId,
          );
          
          channels.add(channel);
        } catch (e) {
          continue;
        }
      }
      
      print('   ✅ Successfully parsed ${channels.length} series');
      return channels;
      
    } catch (e) {
      print('   ❌ Error: $e');
      rethrow;
    }
  }
  
  /// Get all content (Live TV + VOD + Series)
  Future<List<Channel>> getAllContent() async {
    print('📡 Fetching all content from Xtream API...');
    
    final allChannels = <Channel>[];
    
    try {
      // Get live channels
      print('\n1️⃣ Getting Live TV...');
      final liveChannels = await getLiveChannels();
      allChannels.addAll(liveChannels);
      print('   ✅ Added ${liveChannels.length} live channels');
    } catch (e) {
      print('   ⚠️ Failed to get live channels: $e');
    }
    
    try {
      // Get VOD
      print('\n2️⃣ Getting VOD...');
      final vodStreams = await getVodStreams();
      allChannels.addAll(vodStreams);
      print('   ✅ Added ${vodStreams.length} VOD items');
    } catch (e) {
      print('   ⚠️ Failed to get VOD: $e');
    }
    
    try {
      // Get series
      print('\n3️⃣ Getting Series...');
      final series = await getSeries();
      allChannels.addAll(series);
      print('   ✅ Added ${series.length} series');
    } catch (e) {
      print('   ⚠️ Failed to get series: $e');
    }
    
    print('\n✅ Total content retrieved: ${allChannels.length} items\n');
    
    if (allChannels.isEmpty) {
      throw Exception('No content retrieved from API');
    }
    
    return allChannels;
  }
}
