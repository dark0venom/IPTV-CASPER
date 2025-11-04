import 'dart:io';
import 'package:http/http.dart' as http;

/// Quick diagnostic for status 884 issue
void main() async {
  print('🔍 HTTP Status 884 Diagnostic Tool\n');
  
  final testUrls = [
    'http://cf.hi-ott.me/get.php?username=715a45eb20a3&password=TEST&type=m3u_plus',
    'http://google.com',
    'http://example.com',
  ];
  
  for (final url in testUrls) {
    print('━' * 60);
    print('Testing: $url');
    print('━' * 60);
    
    try {
      // Test with http package
      print('\n1️⃣ Testing with http package:');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'VLC/3.0.16 LibVLC/3.0.16',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('   Status: ${response.statusCode}');
      print('   Status type: ${response.statusCode.runtimeType}');
      print('   Headers: ${response.headers}');
      print('   Body length: ${response.body.length}');
      
    } catch (e, stackTrace) {
      print('   ❌ Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
    }
    
    try {
      // Test with HttpClient
      print('\n2️⃣ Testing with HttpClient:');
      final client = HttpClient();
      client.userAgent = 'VLC/3.0.16 LibVLC/3.0.16';
      
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response = await request.close().timeout(const Duration(seconds: 10));
      
      print('   Status: ${response.statusCode}');
      print('   Status type: ${response.statusCode.runtimeType}');
      print('   Headers: ${response.headers}');
      print('   Reason phrase: ${response.reasonPhrase}');
      
      client.close();
    } catch (e, stackTrace) {
      print('   ❌ Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
    }
    
    print('\n');
  }
  
  print('━' * 60);
  print('💡 Analysis:');
  print('━' * 60);
  print('If both methods fail with 884, it might be:');
  print('1. Firewall/Antivirus blocking the request');
  print('2. Proxy interfering with the connection');
  print('3. DNS resolution issue');
  print('4. Windows network configuration');
  print('\nIf only http package fails, try switching to HttpClient.');
}
