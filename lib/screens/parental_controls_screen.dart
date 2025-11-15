import 'package:flutter/material.dart';
import '../models/parental_control.dart';

/// Screen for parental controls settings
class ParentalControlsScreen extends StatefulWidget {
  const ParentalControlsScreen({super.key});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  ParentalControl control = ParentalControl.disabled();
  final pinController = TextEditingController();
  bool showPin = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parental Controls'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEnableSection(),
          if (control.isEnabled) ...[
            const SizedBox(height: 24),
            _buildPinSection(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildBlockedChannelsSection(),
            const SizedBox(height: 24),
            _buildTimeRestrictionsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnableSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: control.isEnabled ? Colors.green : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parental Controls', style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        control.isEnabled ? 'Enabled' : 'Disabled',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: control.isEnabled ? Colors.green : Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: control.isEnabled,
                  onChanged: (value) {
                    if (value) {
                      _showSetupDialog();
                    } else {
                      _showDisableDialog();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PIN Protection', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('PIN is required to access restricted content', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _changePIN,
              icon: const Icon(Icons.lock),
              label: const Text('Change PIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Content Rating Filter', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Block content above this rating', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ...ContentRating.values.map((rating) {
              return RadioListTile<ContentRating>(
                title: Text(_getRatingName(rating)),
                subtitle: Text(_getRatingDescription(rating)),
                value: rating,
                groupValue: control.maxRating,
                onChanged: (value) {
                  if (value != null) {
                    // Set allowedRatings to include this rating and all less restrictive ones
                    final ratings = ContentRating.values.where((r) => r.index <= value.index).toList();
                    setState(() => control = control.copyWith(allowedRatings: ratings));
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedChannelsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Blocked Channels', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _addBlockedChannel,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (control.blockedChannels.isEmpty)
              Text('No blocked channels', style: Theme.of(context).textTheme.bodySmall)
            else
              ...control.blockedChannels.map((channel) {
                return ListTile(
                  leading: const Icon(Icons.block),
                  title: Text(channel),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        final channels = List<String>.from(control.blockedChannels);
                        channels.remove(channel);
                        control = control.copyWith(blockedChannelIds: channels);
                      });
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRestrictionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Restrictions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Restrict viewing during specific times', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(control.restrictedStartTime != null
                        ? _formatTime(control.restrictedStartTime!)
                        : 'Not set'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(control.restrictedEndTime != null
                        ? _formatTime(control.restrictedEndTime!)
                        : 'Not set'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingName(ContentRating rating) {
    switch (rating) {
      case ContentRating.general:
        return 'G';
      case ContentRating.parentalGuidance:
        return 'PG';
      case ContentRating.pg13:
        return 'PG-13';
      case ContentRating.restricted:
        return 'R';
      case ContentRating.mature:
        return 'NC-17';
    }
  }

  String _getRatingDescription(ContentRating rating) {
    switch (rating) {
      case ContentRating.general:
        return 'Suitable for all audiences';
      case ContentRating.parentalGuidance:
        return 'Parental guidance suggested';
      case ContentRating.pg13:
        return 'Parents strongly cautioned';
      case ContentRating.restricted:
        return 'Restricted';
      case ContentRating.mature:
        return 'Adults only';
    }
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  void _showSetupDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Up Parental Controls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a 4-digit PIN to protect restricted content'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                setState(() => control = control.copyWith(isEnabled: true, pinCode: pinController.text));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showDisableDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable Parental Controls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter PIN to disable parental controls'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (control.verifyPin(pinController.text)) {
                setState(() => control = ParentalControl.disabled());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _changePIN() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change PIN'),
        content: const Text('PIN change functionality coming soon'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  void _addBlockedChannel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block Channel'),
        content: const Text('Select channels to block from the main channel list'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  void _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        final timeMinutes = time.hour * 60 + time.minute;
        // For simplicity, apply to all days (1-7)
        final existingRestriction = control.timeRestriction;
        final Map<int, TimeRange> allowedTimes = {};
        
        for (int day = 1; day <= 7; day++) {
          final existingRange = existingRestriction?.allowedTimes[day];
          if (isStartTime) {
            allowedTimes[day] = TimeRange(
              startMinutes: timeMinutes,
              endMinutes: existingRange?.endMinutes ?? 1439, // default to 23:59
            );
          } else {
            allowedTimes[day] = TimeRange(
              startMinutes: existingRange?.startMinutes ?? 0,
              endMinutes: timeMinutes,
            );
          }
        }
        
        control = control.copyWith(
          timeRestriction: TimeRestriction(allowedTimes: allowedTimes),
        );
      });
    }
  }
}
