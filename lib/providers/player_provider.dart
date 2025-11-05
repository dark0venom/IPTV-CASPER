import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/channel.dart';
import '../services/floating_window_service.dart';

class PlayerProvider with ChangeNotifier {
  Player? _player;
  VideoController? _videoController;
  Channel? _currentChannel;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isDetached = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 50.0;
  bool _isMuted = false;

  Player? get player => _player;
  VideoController? get videoController => _videoController;
  Channel? get currentChannel => _currentChannel;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isDetached => _isDetached;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isMuted => _isMuted;

  PlayerProvider() {
    _initializePlayer();
  }

  void _initializePlayer() {
    _player = Player();
    _videoController = VideoController(_player!);

    // Listen to player state changes
    _player!.stream.playing.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _player!.stream.buffering.listen((buffering) {
      _isBuffering = buffering;
      notifyListeners();
    });

    _player!.stream.position.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player!.stream.duration.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
  }

  Future<void> playChannel(Channel channel) async {
    if (_player == null) return;

    try {
      _currentChannel = channel;
      _isBuffering = true;
      notifyListeners();

      await _player!.open(Media(channel.url));
      await _player!.play();
      
      // Update floating window if it's open
      if (_isDetached && FloatingWindowService.isFloatingWindowOpen) {
        await FloatingWindowService.updateStream(
          streamUrl: channel.url,
          channelName: channel.name,
        );
      }
    } catch (e) {
      print('Error playing channel: $e');
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    await _player?.play();
  }

  Future<void> pause() async {
    await _player?.pause();
  }

  Future<void> stop() async {
    await _player?.stop();
    _currentChannel = null;
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    await _player?.setVolume(value);
    notifyListeners();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await _player?.setVolume(0);
    } else {
      await _player?.setVolume(_volume);
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  void setDetached(bool detached) {
    _isDetached = detached;
    notifyListeners();
  }

  void toggleDetached() {
    _isDetached = !_isDetached;
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}
