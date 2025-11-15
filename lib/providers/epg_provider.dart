import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/epg_program.dart';
import '../services/epg_service.dart';

/// Provider for EPG service
final epgServiceProvider = Provider((ref) => EpgService());

/// Provider for EPG data state
final epgDataProvider = StateNotifierProvider<EpgDataNotifier, EpgDataState>((ref) {
  return EpgDataNotifier(ref.read(epgServiceProvider));
});

/// EPG data state
class EpgDataState {
  final Map<String, List<EpgProgram>> programs;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  EpgDataState({
    this.programs = const {},
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  EpgDataState copyWith({
    Map<String, List<EpgProgram>>? programs,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return EpgDataState(
      programs: programs ?? this.programs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// EPG data notifier
class EpgDataNotifier extends StateNotifier<EpgDataState> {
  final EpgService _epgService;

  EpgDataNotifier(this._epgService) : super(EpgDataState());

  /// Load EPG data from URL
  Future<void> loadEpgData(String epgUrl) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final epgData = await _epgService.fetchEpgData(epgUrl);
      _epgService.updateCache(epgData);

      state = state.copyWith(
        programs: epgData,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load EPG data: $e',
      );
    }
  }

  /// Load EPG for Xtream Codes channel
  Future<void> loadXtreamEpg(
    String serverUrl,
    String username,
    String password,
    String streamId,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final epgData = await _epgService.fetchXtreamEpg(
        serverUrl,
        username,
        password,
        streamId,
      );
      
      _epgService.updateCache(epgData);

      state = state.copyWith(
        programs: {...state.programs, ...epgData},
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load Xtream EPG: $e',
      );
    }
  }

  /// Get current program for channel
  EpgProgram? getCurrentProgram(String channelId) {
    return _epgService.getCurrentProgram(channelId);
  }

  /// Get next program for channel
  EpgProgram? getNextProgram(String channelId) {
    return _epgService.getNextProgram(channelId);
  }

  /// Get programs for channel
  List<EpgProgram> getChannelPrograms(String channelId) {
    return state.programs[channelId] ?? [];
  }

  /// Clear EPG data
  void clearEpg() {
    _epgService.clearCache();
    state = EpgDataState();
  }
}

/// Provider for current program of a specific channel
final currentProgramProvider = Provider.family<EpgProgram?, String>((ref, channelId) {
  final epgState = ref.watch(epgDataProvider);
  final programs = epgState.programs[channelId] ?? [];
  final now = DateTime.now();

  try {
    return programs.firstWhere(
      (p) => p.startTime.isBefore(now) && p.endTime.isAfter(now),
    );
  } catch (e) {
    return null;
  }
});

/// Provider for next program of a specific channel
final nextProgramProvider = Provider.family<EpgProgram?, String>((ref, channelId) {
  final epgState = ref.watch(epgDataProvider);
  final programs = epgState.programs[channelId] ?? [];
  final now = DateTime.now();

  try {
    return programs.firstWhere((p) => p.startTime.isAfter(now));
  } catch (e) {
    return null;
  }
});
