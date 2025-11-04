import 'lib/services/xtream_api_client.dart';

Future<void> main() async {
  print('🧪 Testing Xtream API Direct Connection\n');
  print('This bypasses /get.php and uses player_api.php JSON endpoint instead\n');
  
  final client = XtreamApiClient(
    serverUrl: 'http://cf.hi-ott.me',
    username: '715a45eb20a3',
    password: 'e58b817450',
  );
  
  try {
    print('━' * 60);
    print('Starting test...\n');
    
    final channels = await client.getAllContent();
    
    print('\n━' * 60);
    print('✅ SUCCESS!\n');
    print('Total channels retrieved: ${channels.length}');
    print('\nFirst 10 channels:');
    for (var i = 0; i < (channels.length > 10 ? 10 : channels.length); i++) {
      final ch = channels[i];
      print('${i + 1}. ${ch.name} (${ch.groupTitle})');
    }
    print('\n━' * 60);
    
  } catch (e) {
    print('\n━' * 60);
    print('❌ FAILED: $e');
    print('━' * 60);
  }
}
