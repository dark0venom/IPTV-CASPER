import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _autoPlay = true;
  bool _showChannelLogos = true;
  bool _isDarkMode = true;
  double _defaultVolume = 50.0;
  String _playerAspectRatio = '16:9';

  bool get autoPlay => _autoPlay;
  bool get showChannelLogos => _showChannelLogos;
  bool get isDarkMode => _isDarkMode;
  double get defaultVolume => _defaultVolume;
  String get playerAspectRatio => _playerAspectRatio;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoPlay = prefs.getBool('autoPlay') ?? true;
    _showChannelLogos = prefs.getBool('showChannelLogos') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _defaultVolume = prefs.getDouble('defaultVolume') ?? 50.0;
    _playerAspectRatio = prefs.getString('playerAspectRatio') ?? '16:9';
    notifyListeners();
  }

  Future<void> setAutoPlay(bool value) async {
    _autoPlay = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoPlay', value);
    notifyListeners();
  }

  Future<void> setShowChannelLogos(bool value) async {
    _showChannelLogos = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showChannelLogos', value);
    notifyListeners();
  }

  Future<void> setDefaultVolume(double value) async {
    _defaultVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('defaultVolume', value);
    notifyListeners();
  }
  Future<void> setPlayerAspectRatio(String value) async {
    _playerAspectRatio = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerAspectRatio', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }
}
