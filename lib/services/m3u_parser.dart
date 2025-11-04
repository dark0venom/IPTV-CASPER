import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import 'cloudflare_client.dart';
import 'xtream_api_client.dart';

class M3UParser {
  final CloudflareClient _cfClient = CloudflareClient();
  Future<List<Channel>> parseFromUrl(
    String url, {
    String? username,
    String? password,
  }) async {
    // Check if URL already has credentials in query params (Xtream Codes format)
    final hasCredentialsInUrl = url.contains('username=') && url.contains('password=');
    
    // If URL already has credentials, use it directly without additional auth
    if (hasCredentialsInUrl) {
      print('🔍 Detected Xtream Codes URL format');
      final attempts = [
        url, // Try original URL first
        // Try variations without output parameter
        url.replaceAll('&output=ts', '').replaceAll('output=ts&', '').replaceAll('?output=ts', '?'),
        // Try with different type parameter
        url.contains('type=') 
          ? url.replaceAll(RegExp(r'type=[^&]*'), 'type=m3u')
          : url,
      ];
      
      for (int i = 0; i < attempts.length; i++) {
        try {
          print('🔄 Xtream attempt ${i + 1}/${attempts.length}...');
          final result = await _tryFetchPlaylist(attempts[i], null, null);
          if (result != null && result.isNotEmpty) {
            print('✅ Success with Xtream format ${i + 1}!');
            return result;
          }
        } catch (e) {
          continue;
        }
      }
      
      // Extract server and credentials for troubleshooting
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      final server = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
      final username = params['username'] ?? 'unknown';
      
      print('\n❌ All Xtream Codes attempts failed!');
      print('━' * 60);
      print('� TRYING ALTERNATIVE: Xtream API Direct Connection');
      print('━' * 60);
      print('💡 Bypassing /get.php by using player_api.php JSON endpoint...\n');
      
      // Try using Xtream API client as fallback (bypasses Cloudflare /get.php)
      try {
        final xtreamClient = XtreamApiClient(
          serverUrl: server,
          username: username,
          password: params['password'] ?? '',
        );
        
        print('🔗 Attempting direct API connection...\n');
        final channels = await xtreamClient.getAllContent();
        
        if (channels.isNotEmpty) {
          print('✅ SUCCESS! Retrieved ${channels.length} channels via API\n');
          return channels;
        }
      } catch (e) {
        print('❌ API connection also failed: $e\n');
      }
      
      print('━' * 60);
      print('�🔍 TROUBLESHOOTING STEPS:');
      print('━' * 60);
      print('1. Test in browser: Open this URL and check if it works:');
      print('   $url');
      print('');
      print('2. Verify your credentials with your provider:');
      print('   • Server: $server');
      print('   • Username: $username');
      print('   • Password: (check for typos)');
      print('');
      print('3. Contact your provider and ask:');
      print('   • "What is the exact M3U playlist URL format?"');
      print('   • "Do you support Xtream Codes API?"');
      print('   • "Does my IP need to be whitelisted?"');
      print('');
      print('4. Check your account status:');
      print('   • Is your subscription active?');
      print('   • Has your password changed?');
      print('   • Are there any service restrictions?');
      print('━' * 60);
      
      throw Exception(
        'Authentication failed. Server rejected credentials with error 884.\n\n'
        '🔍 This means:\n'
        '• Cloudflare (server protection) is blocking access\n'
        '• Credentials might be incorrect\n'
        '• Server URL might be wrong\n'
        '• Your IP might need whitelisting\n\n'
        '📞 Next steps:\n'
        '1. Test the URL in your web browser\n'
        '2. Contact your IPTV provider\n'
        '3. Verify your credentials are correct\n'
        '4. Ask provider for the exact URL format'
      );
    }
    
    // Try multiple authentication methods if credentials provided
    if (username != null && password != null) {
      final baseUrl = url.replaceAll(RegExp(r'/$'), '');
      final encUser = Uri.encodeComponent(username);
      final encPass = Uri.encodeComponent(password);
      
      // Try different URL formats (Xtream Codes API compatible)
      // Note: Only add endpoints if URL doesn't already have one
      final hasEndpoint = baseUrl.contains('/get.php') || 
                          baseUrl.contains('/player_api.php') || 
                          baseUrl.contains('/playlist.m3u');
      
      final attempts = <String>[];
      
      if (!hasEndpoint) {
        // Standard Xtream Codes endpoints
        attempts.addAll([
          // 1. Xtream get.php with m3u_plus (MOST COMMON - try first)
          '$baseUrl/get.php?username=$encUser&password=$encPass&type=m3u_plus',
          // 2. Player API with action=get_live_streams (Xtream API v2)
          '$baseUrl/player_api.php?username=$encUser&password=$encPass&action=get_live_streams',
          // 3. Xtream Codes get.php with m3u type
          '$baseUrl/get.php?username=$encUser&password=$encPass&type=m3u',
          // 4. Player API with action=get_series (for VOD/Series)
          '$baseUrl/player_api.php?username=$encUser&password=$encPass&action=get_series',
          // 5. Player API basic (let server decide)
          '$baseUrl/player_api.php?username=$encUser&password=$encPass',
          // 6. Xtream Codes get.php without type
          '$baseUrl/get.php?username=$encUser&password=$encPass',
          // 7. Playlist.m3u with query params
          '$baseUrl/playlist.m3u?username=$encUser&password=$encPass',
          // 8. Playlist.m3u8 (HLS format)
          '$baseUrl/playlist.m3u8?username=$encUser&password=$encPass',
        ]);
      }
      
      // Always try the original URL with credentials
      attempts.addAll([
        // Original URL with query params (if URL already has endpoint)
        url.contains('?') 
          ? '$url&username=$encUser&password=$encPass'
          : '$url?username=$encUser&password=$encPass',
      ]);

      Exception? lastError;
      
      for (int i = 0; i < attempts.length; i++) {
        try {
          final attemptUrl = attempts[i];
          print('🔄 Attempt ${i + 1}/${attempts.length}: ${_getMethodName(i + 1)}');
          final result = await _tryFetchPlaylist(attemptUrl, username, password);
          if (result != null && result.isNotEmpty) {
            print('✅ SUCCESS with ${_getMethodName(i + 1)}!');
            print('   📊 Loaded ${result.length} channels');
            return result;
          }
        } catch (e) {
          lastError = e as Exception;
          print('   ❌ Failed: ${e.toString().split('\n').first}');
          continue;
        }
      }
      
      // All methods failed
      throw lastError ?? Exception('All authentication methods failed. Please check your credentials and URL.');
    }
    
    // No authentication needed
    final result = await _tryFetchPlaylist(url, null, null);
    return result ?? [];
  }

  Future<List<Channel>?> _tryFetchPlaylist(
    String url,
    String? username,
    String? password,
  ) async {
    try {
      // Mask password in logs
      final maskedUrl = url
          .replaceAll(RegExp(r'password=[^&]*'), 'password=****')
          .replaceAll(RegExp(r':([^@]+)@'), ':****@');
      print('   🔗 URL: $maskedUrl');
      
      // Validate URL format before parsing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        print('   ❌ Invalid URL: Must start with http:// or https://');
        return null;
      }
      
      Uri uri;
      try {
        uri = Uri.parse(url);
        print('   ✓ URL parsed successfully');
        print('   🏠 Host: ${uri.host}');
        print('   🚪 Port: ${uri.port}');
        print('   📂 Path: ${uri.path}');
      } catch (e) {
        print('   ❌ URL parsing failed: $e');
        return null;
      }
      
      // Detect if this is a Cloudflare-protected server
      final isCloudflareHost = uri.host.contains('cloudflare') || 
                                uri.host.startsWith('cf.') ||
                                uri.host.contains('.cf.') ||
                                uri.host.contains('-cf-');
      
      if (isCloudflareHost) {
        print('   🛡️ Cloudflare-protected host detected, using specialized client');
        return await _tryFetchWithCloudflare(url);
      }
      
      final Map<String, String> headers = {};
      
      // Add Basic Auth header if credentials provided and not already in URL
      final hasCredentialsInUrl = url.contains('@') || 
                                   (url.contains('username=') && url.contains('password='));
      
      if (username != null && password != null && !hasCredentialsInUrl) {
        final credentials = base64Encode(utf8.encode('$username:$password'));
        headers['Authorization'] = 'Basic $credentials';
        print('   🔐 Using Basic Auth header');
      } else if (hasCredentialsInUrl) {
        print('   🔗 Credentials embedded in URL');
      }
      
      // Add common headers
      headers['User-Agent'] = 'VLC/3.0.16 LibVLC/3.0.16';
      headers['Accept'] = '*/*';
      headers['Connection'] = 'keep-alive';
      
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
      );
      
      print('   📥 Status: ${response.statusCode}');
      
      // Check if server is using Cloudflare (by headers)
      final serverHeader = response.headers['server']?.toLowerCase() ?? '';
      if (serverHeader.contains('cloudflare')) {
        print('   🛡️ Cloudflare detected in server header');
      }
      
      // Debug: Show response details for non-standard codes
      if (response.statusCode >= 800 || response.statusCode < 100) {
        print('   ⚠️ Non-standard HTTP status code detected!');
        print('   📋 Response headers: ${response.headers}');
        print('   📝 Response body (first 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
        print('   🔍 This might be a Cloudflare or proxy response');
        
        // If it's a Cloudflare error, retry with Cloudflare client
        if (serverHeader.contains('cloudflare') && response.statusCode >= 800) {
          print('   🔄 Retrying with Cloudflare client...');
          return await _tryFetchWithCloudflare(url);
        }
      }
      
      if (response.statusCode == 200) {
        final body = response.body;
        print('   📦 Content-Type: ${response.headers['content-type'] ?? 'unknown'}');
        print('   📏 Content-Length: ${body.length} bytes');
        
        // Check if it's actually M3U content
        if (!body.contains('#EXTM3U') && !body.contains('#EXTINF:')) {
          print('   ⚠️ Warning: Response does not look like M3U content');
          print('   📝 First 200 chars: ${body.length > 200 ? body.substring(0, 200) : body}');
        }
        
        final channels = _parseM3UContent(body);
        print('   ✅ Found ${channels.length} channels');
        return channels;
      } else if (response.statusCode == 401) {
        print('   🔒 Unauthorized - Invalid credentials');
        print('   💡 Tip: Check username and password are correct');
        return null;
      } else if (response.statusCode == 403) {
        print('   🚫 Forbidden - Access denied');
        print('   💡 Tip: Contact your provider about access permissions');
        return null;
      } else if (response.statusCode == 404) {
        print('   ❓ Not Found - Invalid URL path');
        print('   💡 Tip: Verify the server URL is correct');
        return null;
      } else if (response.statusCode >= 500) {
        print('   🔥 Server Error (${response.statusCode})');
        print('   💡 Tip: Server is having issues, try again later');
        return null;
      } else {
        print('   ⚠️ Unexpected status: ${response.statusCode}');
        print('   📝 Response: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}');
        return null;
      }
    } on SocketException catch (e) {
      print('   🌐 Network error: ${e.message}');
      return null;
    } on TimeoutException {
      print('   ⏱️ Request timeout (15s)');
      return null;
    } on FormatException catch (e) {
      print('   ⚠️ Invalid URL format: $e');
      return null;
    } catch (e) {
      print('   ❌ Error: $e');
      return null;
    }
  }

  Future<List<Channel>> parseFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      return _parseM3UContent(content);
    } catch (e) {
      throw Exception('Error reading file: $e');
    }
  }

  /// Try fetching playlist using Cloudflare-aware client
  Future<List<Channel>?> _tryFetchWithCloudflare(String url) async {
    try {
      print('   🌐 Using Cloudflare client...');
      final response = await _cfClient.fetch(url);
      
      print('   📥 CF Status: ${response.statusCode}');
      
      // Handle Cloudflare challenge
      if (response.isCloudflareChallenge) {
        print('   🛡️ Cloudflare challenge page received');
        print('   💡 Tip: This URL requires browser-based authentication');
        print('   💡 Try accessing the URL in your browser first, then copy the direct playlist link');
        return null;
      }
      
      // Handle Cloudflare custom errors
      if (response.isCloudflareError) {
        print('   ❌ Cloudflare error: ${response.errorMessage}');
        if (response.statusCode == 884) {
          print('   💡 Error 884: Invalid/missing authentication');
          print('   💡 Solutions:');
          print('      1. Verify your username and password are correct');
          print('      2. Check if your account is active');
          print('      3. Try a different URL format (contact your provider)');
          print('      4. Your IP might need to be whitelisted');
        }
        return null;
      }
      
      // Handle authentication errors
      if (response.isAuthError) {
        print('   🔒 Authentication failed (${response.statusCode})');
        return null;
      }
      
      // Success
      if (response.isSuccess) {
        final body = response.body;
        print('   📦 Content-Length: ${body.length} bytes');
        
        // Verify M3U content
        if (!body.contains('#EXTM3U') && !body.contains('#EXTINF:')) {
          print('   ⚠️ Warning: Response does not look like M3U content');
          print('   📝 First 200 chars: ${body.length > 200 ? body.substring(0, 200) : body}');
          return null;
        }
        
        final channels = _parseM3UContent(body);
        print('   ✅ Found ${channels.length} channels via Cloudflare client');
        return channels;
      }
      
      // Other status codes
      print('   ⚠️ Unexpected response: ${response.statusCode}');
      return null;
      
    } catch (e) {
      print('   ❌ Cloudflare client error: $e');
      return null;
    }
  }

  List<Channel> _parseM3UContent(String content) {
    final List<Channel> channels = [];
    final lines = content.split('\n');

    String? currentName;
    String? currentLogoUrl;
    String? currentGroupTitle;
    String? currentTvgId;
    String? currentTvgName;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        // Parse channel metadata
        currentName = _extractChannelName(line);
        currentLogoUrl = _extractAttribute(line, 'tvg-logo');
        currentGroupTitle = _extractAttribute(line, 'group-title');
        currentTvgId = _extractAttribute(line, 'tvg-id');
        currentTvgName = _extractAttribute(line, 'tvg-name');
      } else if (line.isNotEmpty &&
          !line.startsWith('#') &&
          currentName != null) {
        // This line contains the URL
        final channel = Channel(
          name: currentName,
          url: line,
          logoUrl: currentLogoUrl,
          groupTitle: currentGroupTitle,
          tvgId: currentTvgId,
          tvgName: currentTvgName,
        );
        channels.add(channel);

        // Reset for next channel
        currentName = null;
        currentLogoUrl = null;
        currentGroupTitle = null;
        currentTvgId = null;
        currentTvgName = null;
      }
    }

    return channels;
  }

  String? _extractAttribute(String line, String attribute) {
    final pattern = RegExp('$attribute="([^"]*)"', caseSensitive: false);
    final match = pattern.firstMatch(line);
    return match?.group(1);
  }

  String _extractChannelName(String line) {
    // Extract name after the last comma
    final parts = line.split(',');
    if (parts.length > 1) {
      return parts.sublist(1).join(',').trim();
    }
    return 'Unknown Channel';
  }

  /// Get friendly name for connection method
  String _getMethodName(int method) {
    switch (method) {
      case 1: return 'Xtream get.php (m3u_plus)';
      case 2: return 'Player API (get_live_streams)';
      case 3: return 'Xtream get.php (m3u)';
      case 4: return 'Player API (get_series)';
      case 5: return 'Player API (basic)';
      case 6: return 'Xtream get.php (basic)';
      case 7: return 'Playlist.m3u';
      case 8: return 'Playlist.m3u8 (HLS)';
      case 9: return 'Playlist.m3u with credentials';
      case 10: return 'Original URL with params';
      default: return 'Method $method';
    }
  }
}
