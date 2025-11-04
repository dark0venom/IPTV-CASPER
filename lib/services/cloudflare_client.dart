import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Specialized HTTP client for Cloudflare-protected IPTV servers
/// Handles Cloudflare's custom error codes and challenge responses
class CloudflareClient {
  final HttpClient _client = HttpClient();
  
  CloudflareClient() {
    // TiviMate-style: No default User-Agent (will be set per request)
    _client.connectionTimeout = const Duration(seconds: 30);
    _client.badCertificateCallback = (cert, host, port) => true; // Accept all certificates
    // CRITICAL: Disable automatic compression (Cloudflare detection method)
    _client.autoUncompress = false;
  }

  /// Fetch content from Cloudflare-protected URL with multiple fallback methods
  Future<CloudflareResponse> fetch(String url, {Map<String, String>? headers}) async {
    // TiviMate-style User-Agents: Simple and specific to IPTV
    final userAgents = [
      // TiviMate itself (exact User-Agent from real app)
      'ExoPlayer/2.18.1',
      'Dalvik/2.1.0',
      'TiviMate/4.6.1',
      // Other proven working IPTV apps
      'VLC/3.0.20 LibVLC/3.0.20',
      'IPTV Smarters Pro/3.0.9.4',
      'Perfect Player/1.5.10',
      // Minimal fallbacks
      'okhttp/4.9.0',
      'Apache-HttpClient/UNAVAILABLE (java 1.4)',
      'Lavf/58.76.100',
    ];

    CloudflareResponse? lastResponse;
    
    for (int i = 0; i < userAgents.length; i++) {
      final userAgent = userAgents[i];
      final displayName = userAgent.split('/')[0].split(' ')[0];
      print('🌐 Attempt ${i + 1}/${userAgents.length}: $displayName...');
      
      lastResponse = await _fetchWithUserAgent(url, userAgent, headers);
      
      if (lastResponse.isSuccess || (lastResponse.statusCode == 200 && lastResponse.body.isNotEmpty)) {
        print('   ✅ SUCCESS with: $userAgent');
        return lastResponse;
      }
      
      // Don't wait on 884 errors - they're instant rejections
      if (i < userAgents.length - 1 && lastResponse.statusCode != 884) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    
    return lastResponse ?? CloudflareResponse(
      statusCode: 0,
      body: '',
      headers: {},
      errorMessage: 'All connection attempts failed',
    );
  }

  /// Internal method to fetch with specific User-Agent
  Future<CloudflareResponse> _fetchWithUserAgent(String url, String userAgent, Map<String, String>? headers) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.getUrl(uri);
      
      // TiviMate-style: ULTRA-MINIMAL headers (key to bypassing Cloudflare)
      // Clear ALL default headers that Dart adds
      request.headers.clear();
      
      // Only these 2 headers - nothing else!
      request.headers.set(HttpHeaders.userAgentHeader, userAgent);
      request.headers.set(HttpHeaders.acceptHeader, '*/*');
      
      // CRITICAL: Do NOT set Accept-Encoding (let server send uncompressed)
      // CRITICAL: Do NOT set Connection header (Cloudflare fingerprints this)
      // CRITICAL: Do NOT set any browser-like headers
      
      // Add custom headers only if explicitly provided
      if (headers != null && headers.isNotEmpty) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      
      final statusCode = response.statusCode;
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });
      
      // Read response body
      final completer = Completer<List<int>>();
      final chunks = <int>[];
      
      response.listen(
        chunks.addAll,
        onDone: () => completer.complete(chunks),
        onError: completer.completeError,
        cancelOnError: true,
      );
      
      final bodyBytes = await completer.future;
      
      // Handle gzip encoding with error handling
      List<int> decodedBytes;
      if (responseHeaders['content-encoding']?.contains('gzip') ?? false) {
        try {
          decodedBytes = gzip.decode(bodyBytes);
          print('   ✅ GZIP decompressed successfully');
        } catch (e) {
          print('   ⚠️ GZIP decode failed: $e');
          print('   📊 Trying as raw data (${bodyBytes.length} bytes)');
          // If GZIP decode fails, try using raw bytes
          decodedBytes = bodyBytes;
        }
      } else {
        decodedBytes = bodyBytes;
      }
      
      // Decode as UTF-8 with error handling
      String body;
      try {
        body = utf8.decode(decodedBytes, allowMalformed: true);
      } catch (e) {
        print('   ⚠️ UTF-8 decode failed: $e');
        // Try Latin-1 as fallback
        body = latin1.decode(decodedBytes);
      }
      
      print('   📥 Status: $statusCode');
      print('   📦 Body length: ${body.length} bytes');
      
      // Check for Cloudflare custom errors (8XX codes)
      if (statusCode >= 800 && statusCode < 900) {
        return CloudflareResponse(
          statusCode: statusCode,
          body: body,
          headers: responseHeaders,
          isCloudflareError: true,
          errorMessage: _getCloudflareErrorMessage(statusCode),
        );
      }
      
      // Check for Cloudflare challenge pages
      if (body.contains('challenge-platform') || 
          body.contains('cf-challenge') ||
          body.contains('Checking your browser')) {
        print('   🛡️ Cloudflare challenge detected');
        return CloudflareResponse(
          statusCode: statusCode,
          body: body,
          headers: responseHeaders,
          isCloudflareChallenge: true,
          errorMessage: 'Cloudflare challenge page detected',
        );
      }
      
      return CloudflareResponse(
        statusCode: statusCode,
        body: body,
        headers: responseHeaders,
      );
      
    } on SocketException catch (e) {
      print('   🌐 Network error: ${e.message}');
      return CloudflareResponse(
        statusCode: 0,
        body: '',
        headers: {},
        errorMessage: 'Network error: ${e.message}',
      );
    } on TimeoutException {
      print('   ⏱️ Request timeout');
      return CloudflareResponse(
        statusCode: 0,
        body: '',
        headers: {},
        errorMessage: 'Request timeout',
      );
    } catch (e) {
      print('   ❌ Error: $e');
      return CloudflareResponse(
        statusCode: 0,
        body: '',
        headers: {},
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Get human-readable error message for Cloudflare status codes
  String _getCloudflareErrorMessage(int code) {
    switch (code) {
      case 880:
        return 'Unknown Error (Cloudflare 880)';
      case 881:
        return 'Invalid Argument (Cloudflare 881)';
      case 882:
        return 'Missing Argument (Cloudflare 882)';
      case 883:
        return 'Too Many Requests (Cloudflare 883)';
      case 884:
        return 'Invalid or Missing Authentication (Cloudflare 884)';
      case 885:
        return 'Argument Error (Cloudflare 885)';
      case 886:
        return 'Access Denied (Cloudflare 886)';
      case 887:
        return 'Service Unavailable (Cloudflare 887)';
      case 888:
        return 'Server Error (Cloudflare 888)';
      case 889:
        return 'Request Blocked (Cloudflare 889)';
      default:
        return 'Cloudflare Error $code';
    }
  }

  void close() {
    _client.close();
  }
}

/// Response from Cloudflare client
class CloudflareResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final bool isCloudflareError;
  final bool isCloudflareChallenge;
  final String? errorMessage;

  CloudflareResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    this.isCloudflareError = false,
    this.isCloudflareChallenge = false,
    this.errorMessage,
  });

  bool get isSuccess => statusCode == 200 && !isCloudflareError && !isCloudflareChallenge;
  
  bool get isAuthError => statusCode == 401 || statusCode == 403 || statusCode == 884;
}
