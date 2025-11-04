import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog shown when Cloudflare 884 authentication error occurs
class CloudflareErrorDialog extends StatelessWidget {
  final String serverUrl;
  final String username;
  final String? testUrl;
  
  const CloudflareErrorDialog({
    super.key,
    required this.serverUrl,
    required this.username,
    this.testUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          const Text('Authentication Failed'),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Cloudflare Error 884',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The server rejected your credentials. This could mean:',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint('Username or password is incorrect'),
                    _buildBulletPoint('Account is expired or suspended'),
                    _buildBulletPoint('Wrong server URL'),
                    _buildBulletPoint('Your IP address needs whitelisting'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Your credentials
              const Text(
                'Your Connection Details:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Server', serverUrl),
              _buildInfoRow('Username', username),
              _buildInfoRow('Password', '••••••••', copyable: false),
              
              const SizedBox(height: 20),
              
              // Action steps
              const Text(
                '📋 What to do:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              
              _buildActionCard(
                context,
                icon: Icons.language,
                title: '1. Test in Web Browser',
                description: 'Copy the test URL and open it in your browser to see if credentials work',
                actionLabel: testUrl != null ? 'Copy Test URL' : null,
                onAction: testUrl != null
                    ? () => _copyToClipboard(context, testUrl!, 'Test URL')
                    : null,
              ),
              
              const SizedBox(height: 12),
              
              _buildActionCard(
                context,
                icon: Icons.contact_support,
                title: '2. Contact Your Provider',
                description: 'Ask them to verify:\n'
                    '• Your credentials are correct\n'
                    '• Account is active\n'
                    '• Correct playlist URL format\n'
                    '• If IP whitelisting is needed',
              ),
              
              const SizedBox(height: 12),
              
              _buildActionCard(
                context,
                icon: Icons.refresh,
                title: '3. Double-Check Credentials',
                description: 'Verify there are no typos in username or password. Check if password has special characters.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (testUrl != null)
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Test URL'),
            onPressed: () => _copyToClipboard(context, testUrl!, 'Test URL'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // Could navigate to settings or try again
          },
          child: const Text('Try Different Settings'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Show the Cloudflare error dialog
  static Future<void> show(
    BuildContext context, {
    required String serverUrl,
    required String username,
    String? testUrl,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CloudflareErrorDialog(
        serverUrl: serverUrl,
        username: username,
        testUrl: testUrl,
      ),
    );
  }
}
