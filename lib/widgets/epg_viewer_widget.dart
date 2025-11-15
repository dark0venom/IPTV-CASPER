import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/epg_program.dart';
import '../providers/epg_provider.dart';
import '../models/channel.dart';

/// Widget to display Electronic Program Guide (EPG) for a channel
class EpgViewerWidget extends ConsumerStatefulWidget {
  final Channel channel;
  final bool showCompact;
  final VoidCallback? onProgramSelected;

  const EpgViewerWidget({
    super.key,
    required this.channel,
    this.showCompact = false,
    this.onProgramSelected,
  });

  @override
  ConsumerState<EpgViewerWidget> createState() => _EpgViewerWidgetState();
}

class _EpgViewerWidgetState extends ConsumerState<EpgViewerWidget> {
  @override
  void initState() {
    super.initState();
    // Load EPG data for this channel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.channel.tvgId != null) {
        ref.read(epgDataProvider.notifier).loadEpgData(''); // Will be configured with EPG URL
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final epgState = ref.watch(epgDataProvider);
    final channelId = widget.channel.tvgId ?? widget.channel.name;
    final programs = epgState.programs[channelId] ?? [];
    final isLoading = epgState.isLoading;
    final error = epgState.error;

    if (isLoading && programs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null && programs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load EPG data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(epgDataProvider.notifier).loadEpgData('');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (programs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No program information available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return widget.showCompact
        ? _buildCompactView(context, programs)
        : _buildFullView(context, programs);
  }

  Widget _buildCompactView(BuildContext context, List<EpgProgram> programs) {
    final currentProgram = programs.firstWhere(
      (p) => p.isLive,
      orElse: () => programs.first,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.live_tv,
                size: 16,
                color: currentProgram.isLive
                    ? Colors.red
                    : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                currentProgram.isLive ? 'NOW' : 'NEXT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: currentProgram.isLive
                          ? Colors.red
                          : Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${_formatTime(currentProgram.startTime)} - ${_formatTime(currentProgram.endTime)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentProgram.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (currentProgram.description != null && currentProgram.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              currentProgram.description!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (currentProgram.isLive) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: currentProgram.progress,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullView(BuildContext context, List<EpgProgram> programs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.tv,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Program Guide',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(epgDataProvider.notifier).loadEpgData('');
                },
                tooltip: 'Refresh EPG',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final program = programs[index];
              return _buildProgramCard(context, program);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(BuildContext context, EpgProgram program) {
    final bool canCatchUp = program.hasCatchup && program.hasAired;
    final bool canRecord = !program.hasAired;

    return InkWell(
      onTap: widget.onProgramSelected,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: program.isLive
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: program.isLive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: program.isLive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (program.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (program.hasAired)
                  Icon(
                    Icons.history,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                else
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(program.startTime)} - ${_formatTime(program.endTime)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const Spacer(),
                if (canCatchUp)
                  Tooltip(
                    message: 'Catch-up available',
                    child: Icon(
                      Icons.replay,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              program.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (program.description != null && program.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                program.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (program.category != null && program.category!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(program.category!),
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
            if (program.isLive) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(program.progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        _formatDuration(program.duration),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: program.progress,
                      minHeight: 6,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (canCatchUp || canRecord) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (canCatchUp)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Play catch-up
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Watch'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  if (canCatchUp && canRecord) const SizedBox(width: 8),
                  if (canRecord)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Schedule recording
                        },
                        icon: const Icon(Icons.fiber_manual_record, size: 18),
                        label: const Text('Record'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Compact EPG widget for embedding in channel lists
class CompactEpgWidget extends ConsumerWidget {
  final Channel channel;

  const CompactEpgWidget({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EpgViewerWidget(
      channel: channel,
      showCompact: true,
    );
  }
}
