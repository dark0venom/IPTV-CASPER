import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';

/// Debug widget to show content loading status
class ContentDebugOverlay extends StatelessWidget {
  const ContentDebugOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    
    return Positioned(
      top: 100,
      right: 16,
      child: Material(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Content Debug',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(color: Colors.white24),
              _buildStatusRow(
                'VOD Items',
                contentProvider.vodItems.length.toString(),
                contentProvider.isLoadingVod,
              ),
              _buildStatusRow(
                'VOD Categories',
                contentProvider.vodCategories.length.toString(),
                false,
              ),
              _buildStatusRow(
                'Filtered VOD',
                contentProvider.filteredVodItems.length.toString(),
                false,
              ),
              const SizedBox(height: 8),
              _buildStatusRow(
                'Series Items',
                contentProvider.seriesItems.length.toString(),
                contentProvider.isLoadingSeries,
              ),
              _buildStatusRow(
                'Series Categories',
                contentProvider.seriesCategories.length.toString(),
                false,
              ),
              _buildStatusRow(
                'Filtered Series',
                contentProvider.filteredSeriesItems.length.toString(),
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
