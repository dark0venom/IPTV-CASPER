import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../providers/playlist_provider.dart';
import '../providers/content_provider.dart';
import '../services/xtream_api_client.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';

// Global key to access navigation state from child screens
final GlobalKey<_MainNavigationScreenState> mainNavigationKey = GlobalKey<_MainNavigationScreenState>();

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isInitializing = true;
  
  // Public method to change tab
  void navigateToTab(int index) {
    if (mounted && index >= 0 && index < 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize ContentProvider with Xtream API client
    _initializeContentProvider();
    
    // Listen for playlist changes and reinitialize ContentProvider
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.addListener(_onPlaylistsChanged);
  }
  
  @override
  void dispose() {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.removeListener(_onPlaylistsChanged);
    super.dispose();
  }
  
  void _onPlaylistsChanged() {
    debugPrint('📋 Playlists changed, reinitializing ContentProvider...');
    _initializeContentProvider();
  }

  Future<void> _initializeContentProvider() async {
    debugPrint('🔄 Starting ContentProvider initialization...');
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);

    // Wait for PlaylistProvider to finish loading from storage
    while (!playlistProvider.isInitialized) {
      debugPrint('⏳ Waiting for PlaylistProvider to initialize...');
      await Future.delayed(const Duration(milliseconds: 50));
    }

    debugPrint('📋 PlaylistProvider initialized, found ${playlistProvider.playlists.length} playlists');
    
    // Try to find a valid Xtream playlist
    XtreamApiClient? apiClient;
    
    for (final playlist in playlistProvider.playlists) {
      debugPrint('🔍 Checking playlist: ${playlist.name}');
      debugPrint('   URL: ${playlist.url}');
      debugPrint('   Has stored username: ${playlist.username != null}');
      debugPrint('   Has stored password: ${playlist.password != null}');
      
      String? username;
      String? password;
      String? baseUrl;
      
      // Try to get credentials from stored fields first
      if (playlist.username != null && playlist.password != null && playlist.url != null) {
        try {
          // Get decrypted credentials
          final decrypted = await playlistProvider.getDecryptedCredentials(playlist);
          if (decrypted != null) {
            username = decrypted['username'] ?? '';
            password = decrypted['password'] ?? '';
          }
        } catch (e) {
          debugPrint('⚠️ Error decrypting credentials: $e');
        }
      }
      
      // If no stored credentials, try to extract from URL (for old playlists)
      if (playlist.url != null && (username == null || username.isEmpty)) {
        debugPrint('🔍 Attempting to extract credentials from URL...');
        try {
          final uri = Uri.parse(playlist.url!);
          final extractedUsername = uri.queryParameters['username'];
          final extractedPassword = uri.queryParameters['password'];
          
          debugPrint('   Found username in URL: ${extractedUsername != null}');
          debugPrint('   Found password in URL: ${extractedPassword != null}');
          
          if (extractedUsername != null && extractedPassword != null) {
            username = extractedUsername;
            password = extractedPassword;
            debugPrint('✅ Extracted credentials from URL: username=$username');
          }
        } catch (e) {
          debugPrint('❌ Error parsing URL: $e');
        }
      }
      
      // Check if we have valid credentials
      if (username != null && username.isNotEmpty && 
          password != null && password.isNotEmpty && 
          playlist.url != null) {
        try {
          // Parse the URL to extract base URL
          final uri = Uri.parse(playlist.url!);
          baseUrl = '${uri.scheme}://${uri.host}';
          if (uri.hasPort) baseUrl += ':${uri.port}';
          
          debugPrint('🎬 Initializing ContentProvider with Xtream API');
          debugPrint('   Server: $baseUrl');
          debugPrint('   Username: $username');
          
          // Create XtreamApiClient
          apiClient = XtreamApiClient(
            serverUrl: baseUrl,
            username: username,
            password: password,
          );
          
          break; // Use first valid playlist
        } catch (e) {
          debugPrint('❌ Error creating Xtream API client: $e');
        }
      }
    }
    
    if (apiClient != null) {
      contentProvider.updateApiClient(apiClient);
      debugPrint('✅ ContentProvider initialized successfully');
      debugPrint('✅ API client is now available: ${contentProvider.hasApiClient}');
    } else {
      debugPrint('⚠️ No valid Xtream playlist found for ContentProvider');
    }
    
    setState(() {
      _isInitializing = false;
    });
    
    debugPrint('🏁 Initialization complete, showing navigation screens');
  }

  List<Widget> get _screens => const [
    HomeScreen(),
    MoviesScreen(),
    SeriesScreen(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.live_tv_outlined),
      selectedIcon: Icon(Icons.live_tv),
      label: 'Live TV',
    ),
    NavigationDestination(
      icon: Icon(Icons.movie_outlined),
      selectedIcon: Icon(Icons.movie),
      label: 'Movies',
    ),
    NavigationDestination(
      icon: Icon(Icons.tv_outlined),
      selectedIcon: Icon(Icons.tv),
      label: 'Series',
    ),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.live_tv_outlined),
      selectedIcon: Icon(Icons.live_tv),
      label: Text('Live TV'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.movie_outlined),
      selectedIcon: Icon(Icons.movie),
      label: Text('Movies'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.tv_outlined),
      selectedIcon: Icon(Icons.tv),
      label: Text('Series'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isMobile) {
      // Mobile: Bottom Navigation Bar
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _destinations,
        ),
      );
    } else {
      // Desktop/Tablet: Navigation Rail
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: isDesktop
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              destinations: _railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    }
  }
}
