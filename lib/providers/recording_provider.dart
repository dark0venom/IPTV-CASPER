import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording.dart';
import '../services/recording_service.dart';

/// Provider for recording service
final recordingServiceProvider = Provider((ref) {
  final service = RecordingService();
  service.initialize();
  return service;
});

/// Provider for recordings state
final recordingsProvider = StateNotifierProvider<RecordingsNotifier, RecordingsState>((ref) {
  return RecordingsNotifier(ref.read(recordingServiceProvider));
});

/// Recordings state
class RecordingsState {
  final List<Recording> recordings;
  final bool isLoading;
  final String? error;

  RecordingsState({
    this.recordings = const [],
    this.isLoading = false,
    this.error,
  });

  RecordingsState copyWith({
    List<Recording>? recordings,
    bool? isLoading,
    String? error,
  }) {
    return RecordingsState(
      recordings: recordings ?? this.recordings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get recordings by status
  List<Recording> byStatus(RecordingStatus status) {
    return recordings.where((r) => r.status == status).toList();
  }

  /// Get scheduled recordings
  List<Recording> get scheduled => byStatus(RecordingStatus.scheduled);

  /// Get active recordings
  List<Recording> get active => byStatus(RecordingStatus.recording);

  /// Get completed recordings
  List<Recording> get completed => byStatus(RecordingStatus.completed);

  /// Get failed recordings
  List<Recording> get failed => byStatus(RecordingStatus.failed);
}

/// Recordings notifier
class RecordingsNotifier extends StateNotifier<RecordingsState> {
  final RecordingService _recordingService;

  RecordingsNotifier(this._recordingService) : super(RecordingsState()) {
    _loadRecordings();
  }

  /// Load recordings from service
  void _loadRecordings() {
    state = state.copyWith(
      recordings: _recordingService.recordings,
    );
  }

  /// Schedule a new recording
  Future<void> scheduleRecording({
    required String channelId,
    required String channelName,
    required String streamUrl,
    String? programTitle,
    required DateTime startTime,
    required DateTime endTime,
    RecordingQuality quality = RecordingQuality.high,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _recordingService.scheduleRecording(
        channelId: channelId,
        channelName: channelName,
        streamUrl: streamUrl,
        programTitle: programTitle,
        startTime: startTime,
        endTime: endTime,
        quality: quality,
      );

      _loadRecordings();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to schedule recording: $e',
      );
    }
  }

  /// Cancel a scheduled recording
  Future<void> cancelRecording(String recordingId) async {
    try {
      await _recordingService.cancelRecording(recordingId);
      _loadRecordings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel recording: $e');
    }
  }

  /// Delete a recording
  Future<void> deleteRecording(String recordingId) async {
    try {
      await _recordingService.deleteRecording(recordingId);
      _loadRecordings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete recording: $e');
    }
  }

  /// Refresh recordings list
  void refresh() {
    _loadRecordings();
  }
}
