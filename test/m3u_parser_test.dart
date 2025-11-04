import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_casper/services/m3u_parser.dart';

void main() {
  group('M3U Parser Tests', () {
    test('Parse M3U content correctly', () {
      const m3uContent = '''
#EXTM3U
#EXTINF:-1 tvg-id="test1" tvg-name="Test Channel 1" tvg-logo="http://example.com/logo1.png" group-title="Entertainment",Test Channel 1
http://example.com/stream1.m3u8
#EXTINF:-1 tvg-id="test2" tvg-name="Test Channel 2" tvg-logo="http://example.com/logo2.png" group-title="Sports",Test Channel 2
http://example.com/stream2.m3u8
''';

      final parser = M3UParser();
      final channels = parser._parseM3UContent(m3uContent);

      expect(channels.length, 2);
      expect(channels[0].name, 'Test Channel 1');
      expect(channels[0].url, 'http://example.com/stream1.m3u8');
      expect(channels[0].logoUrl, 'http://example.com/logo1.png');
      expect(channels[0].groupTitle, 'Entertainment');
      
      expect(channels[1].name, 'Test Channel 2');
      expect(channels[1].groupTitle, 'Sports');
    });

    test('Extract channel name correctly', () {
      const line = '#EXTINF:-1 tvg-id="test",My Test Channel';
      final parser = M3UParser();
      final name = parser._extractChannelName(line);
      
      expect(name, 'My Test Channel');
    });

    test('Extract attributes correctly', () {
      const line = '#EXTINF:-1 tvg-id="abc123" tvg-logo="http://test.com/logo.png" group-title="News",Channel';
      final parser = M3UParser();
      
      expect(parser._extractAttribute(line, 'tvg-id'), 'abc123');
      expect(parser._extractAttribute(line, 'tvg-logo'), 'http://test.com/logo.png');
      expect(parser._extractAttribute(line, 'group-title'), 'News');
    });
  });
}
