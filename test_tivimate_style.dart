import 'dart:io';
import 'dart:convert';

/// Test TiviMate-style ultra-minimal headers
Future<void> main() async {
  const url = 'http://cf.hi-ott.me/get.php?username=715a45eb20a3&password=e58b817450&type=m3u_plus';
  
  print('🔍 Testing TiviMate-style connection...\n');
  
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 30);
  client.badCertificateCallback = (cert, host, port) => true;
  client.autoUncompress = false; // CRITICAL: Disable auto-compression
  
  final userAgents = [
    'ExoPlayer/2.18.1',
    'Dalvik/2.1.0',
    'TiviMate/4.6.1',
    'VLC/3.0.20 LibVLC/3.0.20',
    'okhttp/4.9.0',
    'Lavf/58.76.100',
  ];
  
  for (int i = 0; i < userAgents.length; i++) {
    final ua = userAgents[i];
    print('Test ${i + 1}/${userAgents.length}: $ua');
    
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      
      // ULTRA-MINIMAL headers (TiviMate style)
      request.headers.clear();
      request.headers.set(HttpHeaders.userAgentHeader, ua);
      request.headers.set(HttpHeaders.acceptHeader, '*/*');
      
      final response = await request.close().timeout(const Duration(seconds: 10));
      
      final chunks = <int>[];
      await for (var chunk in response) {
        chunks.addAll(chunk);
      }
      
      // Handle potential gzip manually
      List<int> decoded;
      final contentEncoding = response.headers.value('content-encoding');
      if (contentEncoding?.contains('gzip') ?? false) {
        try {
          decoded = gzip.decode(chunks);
          print('   ✅ GZIP decoded');
        } catch (e) {
          decoded = chunks;
          print('   ⚠️ GZIP failed, using raw');
        }
      } else {
        decoded = chunks;
      }
      
      final body = utf8.decode(decoded, allowMalformed: true);
      
      print('   📥 Status: ${response.statusCode}');
      print('   📦 Body: ${body.length} bytes');
      
      if (response.statusCode == 200 && body.isNotEmpty) {
        print('   🎉 SUCCESS! Connection works!\n');
        print('First 500 chars: ${body.substring(0, body.length > 500 ? 500 : body.length)}');
        client.close();
        return;
      } else if (response.statusCode == 884) {
        print('   ❌ Cloudflare 884 (blocked)');
      } else if (response.statusCode == 400) {
        print('   ⚠️ Bad Request - Server says:');
        print('   📝 ${body.trim()}');
      } else {
        print('   ⚠️ Unexpected status - Response:');
        print('   📝 ${body.length > 200 ? body.substring(0, 200) : body}');
      }
      print('');
      
    } catch (e) {
      print('   ❌ Error: $e\n');
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  print('❌ All TiviMate-style attempts failed');
  print('💡 The server is actively blocking this IP/credentials');
  client.close();
}
