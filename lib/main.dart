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
import 'theme/app_theme.dart';
import 'windows/detached_player_entry.dart' as detached_player;

void main(List<String> args) async {
  // Check if this is a sub-window (detached player)
  if (args.firstOrNull == 'multi_window') {
    // This is a sub-window launched by DesktopMultiWindow
    debugPrint('🔵 Main: Sub-window detected, launching detached player');
    detached_player.main(args);
    return;
  }
  
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
      titleBarStyle: TitleBarStyle.normal, // Use native title bar with native window controls
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      // Enable all window controls: minimize, maximize, close
      await windowManager.setMinimizable(true);
      await windowManager.setMaximizable(true);
      await windowManager.setResizable(true);
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
        ChangeNotifierProvider(create: (_) => ContentProvider(null)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'IPTV Casper',
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: MainNavigationScreen(key: mainNavigationKey),
          );
        },
      ),
    );
  }
}
