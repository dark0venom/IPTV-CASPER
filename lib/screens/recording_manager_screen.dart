import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording.dart';
import '../providers/recording_provider.dart';

/// Screen to manage recordings
class RecordingManagerScreen extends ConsumerWidget {
  const RecordingManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingsProvider);
    final recordings = recordingState.recordings;
    final isLoading = recordingState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About Recordings',
          ),
        ],
      ),
      body: isLoading && recordings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : recordings.isEmpty
              ? _buildEmptyState(context)
              : _buildRecordingList(context, ref, recordings),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Recordings Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start recording your favorite shows',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.tv),
            label: const Text('Browse Channels'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingList(
    BuildContext context,
    WidgetRef ref,
    List<Recording> recordings,
  ) {
    // Group recordings by status
    final recording = recordings.where((r) => r.status == RecordingStatus.recording).toList();
    final scheduled = recordings.where((r) => r.status == RecordingStatus.scheduled).toList();
    final completed = recordings.where((r) => r.status == RecordingStatus.completed).toList();
    final failed = recordings.where((r) => r.status == RecordingStatus.failed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (recording.isNotEmpty) ...[
          _buildSectionHeader(context, 'Recording Now', Icons.fiber_manual_record, Colors.red),
          ...recording.map((r) => _buildRecordingCard(context, ref, r)),
          const SizedBox(height: 24),
        ],
        if (scheduled.isNotEmpty) ...[
          _buildSectionHeader(context, 'Scheduled', Icons.schedule, Colors.blue),
          ...scheduled.map((r) => _buildRecordingCard(context, ref, r)),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty) ...[
          _buildSectionHeader(context, 'Completed', Icons.check_circle, Colors.green),
          ...completed.map((r) => _buildRecordingCard(context, ref, r)),
          const SizedBox(height: 24),
        ],
        if (failed.isNotEmpty) ...[
          _buildSectionHeader(context, 'Failed', Icons.error, Colors.red),
          ...failed.map((r) => _buildRecordingCard(context, ref, r)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingCard(BuildContext context, WidgetRef ref, Recording recording) {
    final isRecording = recording.status == RecordingStatus.recording;
    final isCompleted = recording.status == RecordingStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isCompleted ? () => _playRecording(context, recording) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recording.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recording.channelName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, recording.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(_formatDateTime(recording.startTime), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(_formatDuration(recording.duration), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              if (isRecording || recording.progress > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: recording.progress),
                const SizedBox(height: 4),
                Text('${(recording.progress * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playRecording(context, recording),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Play'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteRecording(context, ref, recording),
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, RecordingStatus status) {
    Color color;
    String label;
    switch (status) {
      case RecordingStatus.scheduled:
        color = Colors.blue;
        label = 'Scheduled';
      case RecordingStatus.recording:
        color = Colors.red;
        label = 'Recording';
      case RecordingStatus.completed:
        color = Colors.green;
        label = 'Completed';
      case RecordingStatus.failed:
        color = Colors.red;
        label = 'Failed';
      case RecordingStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  void _playRecording(BuildContext context, Recording recording) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playing: ${recording.title}')));
  }

  void _deleteRecording(BuildContext context, WidgetRef ref, Recording recording) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recording'),
        content: Text('Delete "${recording.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(recordingsProvider.notifier).deleteRecording(recording.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.info_outline), SizedBox(width: 8), Text('About Recordings')]),
        content: const Text('FFmpeg must be installed for recording functionality.\n\nQuality options: Source, High (1080p), Medium (720p), Low (480p)'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}
