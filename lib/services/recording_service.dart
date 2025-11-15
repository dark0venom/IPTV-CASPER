import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recording.dart';

/// Service for managing stream recordings
class RecordingService {
  final List<Recording> _recordings = [];
  final Map<String, Process> _activeRecordings = {};
  final Map<String, Timer> _scheduledRecordings = {};
  
  static const String _recordingsKey = 'recordings_list';

  /// Initialize service and load saved recordings
  Future<void> initialize() async {
    await _loadRecordings();
    _checkScheduledRecordings();
  }

  /// Get all recordings
  List<Recording> get recordings => List.unmodifiable(_recordings);

  /// Get recordings by status
  List<Recording> getRecordingsByStatus(RecordingStatus status) {
    return _recordings.where((r) => r.status == status).toList();
  }

  /// Schedule a new recording
  Future<Recording> scheduleRecording({
    required String channelId,
    required String channelName,
    required String streamUrl,
    String? programTitle,
    required DateTime startTime,
    required DateTime endTime,
    RecordingQuality quality = RecordingQuality.high,
  }) async {
    final recording = Recording(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      channelId: channelId,
      channelName: channelName,
      programTitle: programTitle,
      startTime: startTime,
      endTime: endTime,
      status: RecordingStatus.scheduled,
      quality: quality,
      createdAt: DateTime.now(),
    );

    _recordings.add(recording);
    await _saveRecordings();

    // Schedule the recording
    final timeUntilStart = startTime.difference(DateTime.now());
    if (timeUntilStart.isNegative) {
      // Start immediately if time has passed
      await _startRecording(recording, streamUrl);
    } else {
      // Schedule for future
      _scheduledRecordings[recording.id] = Timer(timeUntilStart, () {
        _startRecording(recording, streamUrl);
      });
    }

    return recording;
  }

  /// Start recording immediately
  Future<void> _startRecording(Recording recording, String streamUrl) async {
    try {
      // Get recordings directory
      final directory = await getRecordingsDirectory();
      final fileName = _generateFileName(recording);
      final filePath = '${directory.path}/$fileName';

      // Update recording status
      final updatedRecording = recording.copyWith(
        status: RecordingStatus.recording,
        filePath: filePath,
      );
      _updateRecording(updatedRecording);

      // Start FFmpeg recording process
      final process = await _startFFmpegRecording(streamUrl, filePath, recording.quality);
      _activeRecordings[recording.id] = process;

      // Schedule stop
      final duration = recording.endTime.difference(recording.startTime);
      Timer(duration, () {
        _stopRecording(recording.id);
      });

    } catch (e) {
      print('Error starting recording: $e');
      final failedRecording = recording.copyWith(
        status: RecordingStatus.failed,
        errorMessage: e.toString(),
      );
      _updateRecording(failedRecording);
    }
  }

  /// Start FFmpeg recording process
  Future<Process> _startFFmpegRecording(
    String streamUrl,
    String outputPath,
    RecordingQuality quality,
  ) async {
    // FFmpeg command for recording
    final args = [
      '-i', streamUrl,
      '-c', 'copy', // Copy codec (no re-encoding)
      '-bsf:a', 'aac_adtstoasc',
      outputPath,
    ];

    // Add quality settings if not original
    if (quality != RecordingQuality.original) {
      // Insert quality parameters before output
      args.insertAll(args.length - 1, [
        '-s', quality.resolution,
        '-b:v', _getBitrate(quality),
      ]);
    }

    return await Process.start('ffmpeg', args);
  }

  /// Get bitrate for quality
  String _getBitrate(RecordingQuality quality) {
    switch (quality) {
      case RecordingQuality.low:
        return '1000k';
      case RecordingQuality.medium:
        return '2500k';
      case RecordingQuality.high:
        return '5000k';
      case RecordingQuality.original:
        return '10000k';
    }
  }

  /// Stop recording
  Future<void> _stopRecording(String recordingId) async {
    final process = _activeRecordings[recordingId];
    if (process != null) {
      process.kill();
      _activeRecordings.remove(recordingId);

      // Update recording status
      final recording = _recordings.firstWhere((r) => r.id == recordingId);
      final file = File(recording.filePath!);
      
      final completedRecording = recording.copyWith(
        status: RecordingStatus.completed,
        fileSize: await file.length(),
      );
      _updateRecording(completedRecording);
    }
  }

  /// Cancel scheduled recording
  Future<void> cancelRecording(String recordingId) async {
    // Cancel timer if scheduled
    _scheduledRecordings[recordingId]?.cancel();
    _scheduledRecordings.remove(recordingId);

    // Stop if currently recording
    if (_activeRecordings.containsKey(recordingId)) {
      await _stopRecording(recordingId);
    }

    // Update status
    final recording = _recordings.firstWhere((r) => r.id == recordingId);
    final cancelledRecording = recording.copyWith(
      status: RecordingStatus.cancelled,
    );
    _updateRecording(cancelledRecording);
  }

  /// Delete recording
  Future<void> deleteRecording(String recordingId) async {
    final recording = _recordings.firstWhere((r) => r.id == recordingId);
    
    // Delete file if exists
    if (recording.filePath != null) {
      final file = File(recording.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Remove from list
    _recordings.removeWhere((r) => r.id == recordingId);
    await _saveRecordings();
  }

  /// Get recordings directory
  Future<Directory> getRecordingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${appDir.path}/IPTV-Casper/Recordings');
    
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    return recordingsDir;
  }

  /// Generate file name for recording
  String _generateFileName(Recording recording) {
    final timestamp = recording.startTime.toIso8601String().replaceAll(':', '-');
    final title = recording.programTitle?.replaceAll(RegExp(r'[^\w\s-]'), '') ?? 'recording';
    return '${title}_$timestamp.mp4';
  }

  /// Update recording in list
  void _updateRecording(Recording recording) {
    final index = _recordings.indexWhere((r) => r.id == recording.id);
    if (index != -1) {
      _recordings[index] = recording;
      _saveRecordings();
    }
  }

  /// Check and start scheduled recordings
  void _checkScheduledRecordings() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      
      for (final recording in _recordings) {
        if (recording.status == RecordingStatus.scheduled &&
            recording.startTime.isBefore(now) &&
            !_activeRecordings.containsKey(recording.id)) {
          // This would need the stream URL - stored separately
          print('Recording ${recording.id} should start but URL not available');
        }
      }
    });
  }

  /// Save recordings to storage
  Future<void> _saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = _recordings.map((r) => r.toJson()).toList();
    await prefs.setString(_recordingsKey, json.encode(recordingsJson));
  }

  /// Load recordings from storage
  Future<void> _loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = prefs.getString(_recordingsKey);
    
    if (recordingsJson != null) {
      final List<dynamic> decoded = json.decode(recordingsJson);
      _recordings.clear();
      _recordings.addAll(
        decoded.map((r) => Recording.fromJson(r as Map<String, dynamic>)),
      );
    }
  }

  /// Dispose service
  void dispose() {
    // Cancel all timers
    for (final timer in _scheduledRecordings.values) {
      timer.cancel();
    }
    _scheduledRecordings.clear();

    // Stop all active recordings
    for (final process in _activeRecordings.values) {
      process.kill();
    }
    _activeRecordings.clear();
  }
}
