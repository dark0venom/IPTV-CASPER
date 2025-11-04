import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/playlist_provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/content_provider.dart';
import 'services/xtream_api_client.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MediaKit for video playback
  MediaKit.ensureInitialized();
  
  // Initialize window manager for desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<PlaylistProvider, ContentProvider>(
          create: (context) => ContentProvider(null),
          update: (context, playlistProvider, previous) {
            // Try to find a valid Xtream playlist
            XtreamApiClient? apiClient;
            
            for (final playlist in playlistProvider.playlists) {
              if (playlist.username != null && playlist.password != null && playlist.url != null) {
                try {
                  // Parse the URL to extract base URL
                  final uri = Uri.parse(playlist.url!);
                  String baseUrl = '${uri.scheme}://${uri.host}';
                  if (uri.hasPort) baseUrl += ':${uri.port}';
                  
                  // Create XtreamApiClient
                  apiClient = XtreamApiClient(
                    serverUrl: baseUrl,
                    username: playlist.username!,
                    password: playlist.password!,
                  );
                  
                  break; // Use first valid playlist
                } catch (e) {
                  debugPrint('Error parsing playlist URL: $e');
                }
              }
            }
            
            return ContentProvider(apiClient);
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'IPTV Casper',
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
