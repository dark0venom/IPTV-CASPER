/// Cloudflare Connection Helper
/// Provides utilities and guidance for connecting to Cloudflare-protected IPTV servers

class CloudflareHelper {
  /// Generate alternative URL formats for Xtream Codes servers
  static List<String> generateXtreamAlternatives(
    String server,
    String username,
    String password,
  ) {
    final cleanServer = server.replaceAll(RegExp(r'/$'), '');
    final encUsername = Uri.encodeComponent(username);
    final encPassword = Uri.encodeComponent(password);
    
    return [
      // Standard Xtream Codes formats
      '$cleanServer/get.php?username=$encUsername&password=$encPassword&type=m3u_plus',
      '$cleanServer/get.php?username=$encUsername&password=$encPassword&type=m3u',
      '$cleanServer/get.php?username=$encUsername&password=$encPassword',
      
      // Player API formats
      '$cleanServer/player_api.php?username=$encUsername&password=$encPassword&action=get_live_streams&type=m3u_plus',
      '$cleanServer/player_api.php?username=$encUsername&password=$encPassword&action=get_live_streams',
      
      // Direct playlist formats
      '$cleanServer/playlist.m3u?username=$encUsername&password=$encPassword',
      '$cleanServer/playlist.m3u8?username=$encUsername&password=$encPassword',
      
      // XMLTV format (some servers)
      '$cleanServer/xmltv.php?username=$encUsername&password=$encPassword',
      
      // Embedded credentials format
      cleanServer.replaceFirst('://', '://$encUsername:$encPassword@') + '/playlist.m3u',
      cleanServer.replaceFirst('://', '://$encUsername:$encPassword@') + '/get.php',
    ];
  }
  
  /// Get troubleshooting steps for Cloudflare 884 error
  static List<String> getTroubleshootingSteps() {
    return [
      '1. Verify your credentials are correct (no typos)',
      '2. Check if your account is active and not expired',
      '3. Contact your provider to confirm the correct URL format',
      '4. Ask if your IP address needs to be whitelisted',
      '5. Try accessing the URL in a web browser first',
      '6. Check if the provider supports the Xtream Codes API',
      '7. Ask for alternative playlist URL formats',
      '8. Verify your subscription includes API access',
    ];
  }
  
  /// Get user-friendly error message for Cloudflare errors
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 884:
        return '''
❌ Authentication Failed (Cloudflare 884)

This error means the server rejected your credentials.

Common causes:
• Wrong username or password
• Account expired or suspended
• Wrong URL format for this provider
• IP address not whitelisted
• Provider doesn't support this connection method

What to do:
1. Double-check your username and password
2. Contact your IPTV provider for help
3. Ask for the exact playlist URL format they support
4. Try the test script: dart test_auth.dart
''';
      
      case 883:
        return '''
❌ Too Many Requests (Cloudflare 883)

The server is rate-limiting your requests.

What to do:
• Wait a few minutes before trying again
• Don't refresh too frequently
• Contact provider if this persists
''';
      
      case 886:
        return '''
❌ Access Denied (Cloudflare 886)

Your access to this server has been blocked.

What to do:
• Contact your provider immediately
• Check if your subscription is active
• Verify your IP is not blocked
''';
      
      default:
        return '''
❌ Cloudflare Error $statusCode

An unexpected Cloudflare error occurred.

What to do:
• Contact your IPTV provider with this error code
• Try again in a few minutes
• Check provider's status page
''';
    }
  }
  
  /// Check if a hostname looks like a Cloudflare-protected server
  static bool isCloudflareHost(String hostname) {
    return hostname.contains('cloudflare') ||
           hostname.startsWith('cf.') ||
           hostname.contains('.cf.') ||
           hostname.contains('-cf-') ||
           hostname.endsWith('.cf') ||
           // Common Cloudflare CDN patterns
           hostname.contains('cdn-') ||
           hostname.contains('.cdn.');
  }
  
  /// Generate curl command for testing
  static String generateCurlCommand(String url) {
    final maskedUrl = url
        .replaceAll(RegExp(r'password=[^&]*'), 'password=YOUR_PASSWORD')
        .replaceAll(RegExp(r':([^@]+)@'), ':YOUR_PASSWORD@');
    
    return '''
# Test this URL in your terminal/PowerShell:
curl -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \\
     -H "Accept: */*" \\
     "$maskedUrl"

# If successful, you should see M3U content starting with #EXTM3U
''';
  }
  
  /// Get browser testing instructions
  static String getBrowserTestInstructions(String url) {
    final maskedUrl = url
        .replaceAll(RegExp(r'password=[^&]*'), 'password=YOUR_PASSWORD')
        .replaceAll(RegExp(r':([^@]+)@'), ':YOUR_PASSWORD@');
    
    return '''
🌐 Test in Web Browser:

1. Open this URL in your browser:
   $maskedUrl

2. What you should see:
   ✅ M3U content (text starting with #EXTM3U)
   ❌ HTML error page (means wrong credentials/URL)
   ❌ Download prompt (check the downloaded file)

3. If you see M3U content:
   • Your credentials work!
   • The app should work with the same settings
   
4. If you see an error:
   • Contact your provider
   • Ask for the correct URL format
''';
  }
}
