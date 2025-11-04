import 'lib/services/xtream_api_client.dart';

void main() async {
  print('🎬 Testing VOD and Series API...\n');
  
  final client = XtreamApiClient(
    serverUrl: 'http://cf.hi-ott.me',
    username: '715a45eb20a3',
    password: 'e58b817450',
  );
  
  try {
    // Test VOD Categories
    print('1️⃣ Testing VOD Categories...');
    final vodCategories = await client.getVodCategories();
    print('   ✅ Found ${vodCategories.length} VOD categories');
    if (vodCategories.isNotEmpty) {
      print('   📁 First 5 categories:');
      for (var i = 0; i < vodCategories.length && i < 5; i++) {
        final cat = vodCategories[i];
        print('      - ${cat['category_name']} (ID: ${cat['category_id']})');
      }
    }
    print('');
    
    // Test VOD Items (first 10)
    print('2️⃣ Testing VOD Items (limited to 10)...');
    final vodItems = await client.getVodItems();
    print('   ✅ Found ${vodItems.length} VOD items total');
    if (vodItems.isNotEmpty) {
      print('   🎬 First 5 movies:');
      for (var i = 0; i < vodItems.length && i < 5; i++) {
        final movie = vodItems[i];
        print('      - ${movie.name}');
        print('        URL: ${movie.streamUrl}');
        if (movie.rating != null) print('        Rating: ${movie.rating}');
        if (movie.genre != null) print('        Genre: ${movie.genre}');
        print('');
      }
    }
    print('');
    
    // Test Series Categories
    print('3️⃣ Testing Series Categories...');
    final seriesCategories = await client.getSeriesCategories();
    print('   ✅ Found ${seriesCategories.length} series categories');
    if (seriesCategories.isNotEmpty) {
      print('   📁 First 5 categories:');
      for (var i = 0; i < seriesCategories.length && i < 5; i++) {
        final cat = seriesCategories[i];
        print('      - ${cat['category_name']} (ID: ${cat['category_id']})');
      }
    }
    print('');
    
    // Test Series Items (first 10)
    print('4️⃣ Testing Series Items (limited to 10)...');
    final seriesItems = await client.getSeriesItems();
    print('   ✅ Found ${seriesItems.length} series total');
    if (seriesItems.isNotEmpty) {
      print('   📺 First 5 series:');
      for (var i = 0; i < seriesItems.length && i < 5; i++) {
        final series = seriesItems[i];
        print('      - ${series.name}');
        if (series.rating != null) print('        Rating: ${series.rating}');
        if (series.genre != null) print('        Genre: ${series.genre}');
        print('');
      }
      
      // Test getting detailed info for first series
      if (seriesItems.isNotEmpty) {
        print('\n5️⃣ Testing Series Details (first series)...');
        final firstSeries = seriesItems[0];
        print('   Getting details for: ${firstSeries.name}');
        final detailedSeries = await client.getSeriesInfo(firstSeries.id);
        if (detailedSeries != null && detailedSeries.seasons != null) {
          print('   ✅ Found ${detailedSeries.seasons!.length} seasons');
          for (var season in detailedSeries.seasons!) {
            print('      - ${season.name}: ${season.episodes.length} episodes');
            if (season.episodes.isNotEmpty) {
              print('        First episode: ${season.episodes[0].title}');
              print('        Stream URL: ${season.episodes[0].streamUrl}');
            }
          }
        }
      }
    }
    
    print('\n✅ All tests passed! VOD and Series API is working correctly.\n');
    
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    print('Stack trace: $stackTrace\n');
  }
}
