import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple authentication verification script
/// Run with: dart test_auth.dart
void main() async {
  print('🔍 IPTV Authentication Method Verifier\n');
  
  // Get inputs
  stdout.write('Enter server URL (e.g., http://server.com:8080): ');
  final server = stdin.readLineSync() ?? '';
  
  stdout.write('Enter username: ');
  final username = stdin.readLineSync() ?? '';
  
  stdout.write('Enter password: ');
  final password = stdin.readLineSync() ?? '';
  
  print('\n📡 Testing authentication methods...\n');
  
  // Test different authentication methods
  final methods = [
    {
      'name': 'Method 1: Xtream Codes API (get.php)',
      'url': '${server.replaceAll(RegExp(r'/$'), '')}/get.php?username=$username&password=$password&type=m3u_plus',
    },
    {
      'name': 'Method 2: Playlist.m3u with query params',
      'url': '${server.replaceAll(RegExp(r'/$'), '')}/playlist.m3u?username=$username&password=$password',
    },
    {
      'name': 'Method 3: URL-embedded credentials',
      'url': server.replaceFirst('://', '://$username:$password@'),
    },
    {
      'name': 'Method 4: Direct M3U with Basic Auth',
      'url': '${server.replaceAll(RegExp(r'/$'), '')}/playlist.m3u',
      'useBasicAuth': true,
    },
    {
      'name': 'Method 5: Server root with query params',
      'url': server.contains('?') 
        ? '$server&username=$username&password=$password'
        : '$server?username=$username&password=$password',
    },
  ];
  
  for (int i = 0; i < methods.length; i++) {
    final method = methods[i];
    print('━' * 60);
    print('${method['name']}');
    print('━' * 60);
    
    try {
      final url = method['url'] as String;
      final useBasicAuth = method['useBasicAuth'] as bool? ?? false;
      
      // Mask password in output
      final displayUrl = url
          .replaceAll(password, '****')
          .replaceAll(Uri.encodeComponent(password), '****');
      print('URL: $displayUrl');
      
      final headers = {
        'User-Agent': 'VLC/3.0.16 LibVLC/3.0.16',
        'Accept': '*/*',
        'Connection': 'keep-alive',
      };
      
      if (useBasicAuth) {
        final credentials = base64Encode(utf8.encode('$username:$password'));
        headers['Authorization'] = 'Basic $credentials';
        print('Auth: Basic Authorization header');
      }
      
      print('Requesting...');
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      print('Content-Type: ${response.headers['content-type'] ?? 'unknown'}');
      print('Content-Length: ${response.body.length} bytes');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS!');
        
        // Check if it's valid M3U content
        if (response.body.contains('#EXTM3U')) {
          final channelCount = '#EXTINF:'.allMatches(response.body).length;
          print('📺 Found $channelCount channels');
          print('\n✨ This method works! Use these settings:');
          if (useBasicAuth) {
            print('   Server: ${server.replaceAll(RegExp(r'/$'), '')}/playlist.m3u');
            print('   Username: $username');
            print('   Password: $password');
            print('   Method: Use "M3U URL" tab with authentication enabled');
          } else if (url.contains('get.php')) {
            print('   Server: ${server.replaceAll(RegExp(r'/$'), '')}');
            print('   Username: $username');
            print('   Password: $password');
            print('   Method: Use "Xtream Codes" tab');
          } else {
            print('   URL: $displayUrl');
            print('   Method: Copy this URL to "M3U URL" tab');
          }
        } else {
          print('⚠️ Response is not valid M3U content');
          print('First 200 chars: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        }
      } else if (response.statusCode == 401) {
        print('❌ 401 Unauthorized - Invalid credentials');
      } else if (response.statusCode == 403) {
        print('❌ 403 Forbidden - Access denied');
      } else if (response.statusCode == 404) {
        print('❌ 404 Not Found - Invalid URL path');
      } else {
        print('❌ Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }
  
  print('━' * 60);
  print('🏁 Verification complete!');
  print('━' * 60);
}
