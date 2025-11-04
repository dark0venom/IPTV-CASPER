import 'package:http/http.dart' as http;

/// Test direct connection bypassing CloudflareClient
Future<void> main() async {
  final url = 'http://cf.hi-ott.me/get.php?username=715a45eb20a3&password=e58b817450&type=m3u_plus';
  
  print('🔍 Testing direct connection with package:http...\n');
  
  // Test 1: Ultra-minimal VLC headers
  print('Test 1: Minimal VLC headers');
  try {
    final response1 = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'VLC/3.0.20 LibVLC/3.0.20',
      },
    ).timeout(Duration(seconds: 10));
    print('✅ Status: ${response1.statusCode}');
    print('📦 Body length: ${response1.body.length} bytes');
    if (response1.statusCode == 200 && response1.body.isNotEmpty) {
      print('🎉 SUCCESS! Connection works with minimal headers\n');
      return;
    }
  } catch (e) {
    print('❌ Failed: $e\n');
  }
  
  // Test 2: VLC with Accept header
  print('Test 2: VLC with Accept header');
  try {
    final response2 = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'VLC/3.0.20 LibVLC/3.0.20',
        'Accept': '*/*',
      },
    ).timeout(Duration(seconds: 10));
    print('✅ Status: ${response2.statusCode}');
    print('📦 Body length: ${response2.body.length} bytes');
    if (response2.statusCode == 200 && response2.body.isNotEmpty) {
      print('🎉 SUCCESS! Connection works with Accept header\n');
      return;
    }
  } catch (e) {
    print('❌ Failed: $e\n');
  }
  
  // Test 3: LibVLC User-Agent
  print('Test 3: LibVLC User-Agent');
  try {
    final response3 = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'LibVLC/3.0.16 (LIVE555 Streaming Media v2021.08.24)',
        'Accept': '*/*',
      },
    ).timeout(Duration(seconds: 10));
    print('✅ Status: ${response3.statusCode}');
    print('📦 Body length: ${response3.body.length} bytes');
    if (response3.statusCode == 200 && response3.body.isNotEmpty) {
      print('🎉 SUCCESS! Connection works with LibVLC\n');
      return;
    }
  } catch (e) {
    print('❌ Failed: $e\n');
  }
  
  // Test 4: IPTV Smarters
  print('Test 4: IPTV Smarters');
  try {
    final response4 = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'IPTV Smarters Pro/3.0.9.4',
        'Accept': '*/*',
      },
    ).timeout(Duration(seconds: 10));
    print('✅ Status: ${response4.statusCode}');
    print('📦 Body length: ${response4.body.length} bytes');
    if (response4.statusCode == 200 && response4.body.isNotEmpty) {
      print('🎉 SUCCESS! Connection works with IPTV Smarters\n');
      return;
    }
  } catch (e) {
    print('❌ Failed: $e\n');
  }
  
  print('❌ All tests failed with error 884');
  print('💡 This means your IP or credentials are blocked by the server');
  print('💡 Try from a different network or contact your provider');
}
