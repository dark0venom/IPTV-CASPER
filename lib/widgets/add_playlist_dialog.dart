import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/playlist_provider.dart';

class AddPlaylistDialog extends StatefulWidget {
  const AddPlaylistDialog({super.key});

  @override
  State<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<AddPlaylistDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  // M3U URL fields
  final _urlController = TextEditingController();
  final _urlUsernameController = TextEditingController();
  final _urlPasswordController = TextEditingController();
  
  // Xtream Codes fields
  final _xtreamServerController = TextEditingController();
  final _xtreamUsernameController = TextEditingController();
  final _xtreamPasswordController = TextEditingController();
  
  // File path
  final _filePathController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _urlRequiresAuth = false;
  
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _urlUsernameController.dispose();
    _urlPasswordController.dispose();
    _xtreamServerController.dispose();
    _xtreamUsernameController.dispose();
    _xtreamPasswordController.dispose();
    _filePathController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Playlist'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Playlist Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.link),
                      text: 'M3U URL',
                    ),
                    Tab(
                      icon: Icon(Icons.api),
                      text: 'Xtream Codes',
                    ),
                    Tab(
                      icon: Icon(Icons.folder),
                      text: 'Local File',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildM3UUrlTab(),
                    _buildXtreamCodesTab(),
                    _buildLocalFileTab(),
                  ],
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addPlaylist,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildM3UUrlTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Direct M3U/M3U8 Playlist URL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the direct URL to your M3U playlist file.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Playlist URL',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
              hintText: 'http://example.com/playlist.m3u',
            ),
            validator: (value) {
              if (_currentTab == 0 && (value == null || value.isEmpty)) {
                return 'Please enter a URL';
              }
              if (_currentTab == 0 && 
                  !value!.startsWith('http://') &&
                  !value.startsWith('https://')) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _urlRequiresAuth,
            onChanged: (value) {
              setState(() {
                _urlRequiresAuth = value ?? false;
              });
            },
            title: const Text('Requires Authentication'),
            subtitle: const Text('Enable if playlist requires login'),
            contentPadding: EdgeInsets.zero,
          ),
          if (_urlRequiresAuth) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _urlUsernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (_currentTab == 0 && _urlRequiresAuth && (value == null || value.isEmpty)) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _urlPasswordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (_currentTab == 0 && _urlRequiresAuth && (value == null || value.isEmpty)) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildXtreamCodesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xtream Codes API Connection',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your Xtream Codes server details. Most IPTV providers use this format.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _xtreamServerController,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dns),
              hintText: 'http://server.com:8080 or http://server.com',
            ),
            validator: (value) {
              if (_currentTab == 1 && (value == null || value.isEmpty)) {
                return 'Please enter server URL';
              }
              if (_currentTab == 1 && 
                  !value!.startsWith('http://') &&
                  !value.startsWith('https://')) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _xtreamUsernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (_currentTab == 1 && (value == null || value.isEmpty)) {
                return 'Please enter username';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _xtreamPasswordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (_currentTab == 1 && (value == null || value.isEmpty)) {
                return 'Please enter password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The app will automatically construct the playlist URL using the Xtream Codes API format.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalFileTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local M3U File',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an M3U or M3U8 file from your device.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_filePathController.text.isEmpty)
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.file_open),
                label: const Text('Select M3U File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'File selected:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _filePathController.text.split('\\').last,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _filePathController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _isLoading ? null : _pickFile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Choose Different File'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u', 'm3u8'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePathController.text = result.files.single.path!;
      });
    }
  }

  String _buildXtreamCodesUrl() {
    final server = _xtreamServerController.text.trim();
    final username = Uri.encodeComponent(_xtreamUsernameController.text.trim());
    final password = Uri.encodeComponent(_xtreamPasswordController.text.trim());
    
    // Remove trailing slash from server if present
    final baseUrl = server.endsWith('/') ? server.substring(0, server.length - 1) : server;
    
    // Build Xtream Codes API URL for M3U playlist
    // Try without output parameter first as some servers don't support it
    return '$baseUrl/get.php?username=$username&password=$password&type=m3u_plus';
  }

  Future<void> _addPlaylist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    try {
      switch (_currentTab) {
        case 0: // M3U URL
          await playlistProvider.loadPlaylistFromUrl(
            _urlController.text,
            _nameController.text,
            username: _urlRequiresAuth ? _urlUsernameController.text : null,
            password: _urlRequiresAuth ? _urlPasswordController.text : null,
          );
          break;
        case 1: // Xtream Codes
          final xtreamUrl = _buildXtreamCodesUrl();
          // Pass credentials separately so they can be stored and used for API calls
          await playlistProvider.loadPlaylistFromUrl(
            xtreamUrl,
            _nameController.text,
            username: _xtreamUsernameController.text,
            password: _xtreamPasswordController.text,
          );
          break;
        case 2: // Local File
          await playlistProvider.loadPlaylistFromFile(
            _filePathController.text,
            _nameController.text,
          );
          break;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist loaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        final errorMessage = e.toString();
        
        // Check if it's a Cloudflare 884 error
        if (errorMessage.contains('884') || errorMessage.contains('Authentication failed')) {
          // Show detailed Cloudflare error dialog
          final isXtream = _currentTab == 1;
          final serverUrl = isXtream ? _xtreamServerController.text : _urlController.text;
          final username = isXtream ? _xtreamUsernameController.text : _urlUsernameController.text;
          
          // Generate test URL
          String? testUrl;
          if (isXtream && _xtreamServerController.text.isNotEmpty) {
            final server = _xtreamServerController.text.replaceAll(RegExp(r'/$'), '');
            final user = _xtreamUsernameController.text;
            final pass = _xtreamPasswordController.text;
            testUrl = '$server/get.php?username=$user&password=$pass&type=m3u_plus';
          }
          
          // Import and show dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Text('Authentication Failed'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                            const Row(
                              children: [
                                Icon(Icons.shield, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Cloudflare Error 884',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Server rejected credentials. This could mean:',
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            ...[
                              '• Wrong username or password',
                              '• Account expired/suspended',
                              '• Wrong server URL',
                              '• IP needs whitelisting'
                            ].map((text) => Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 2),
                              child: Text(text, style: const TextStyle(fontSize: 12)),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Details:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Server: $serverUrl', style: const TextStyle(fontSize: 13)),
                      Text('Username: $username', style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 16),
                      const Text(
                        '📋 Next Steps:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Test URL in web browser\n'
                        '2. Contact provider to verify:\n'
                        '   • Credentials are correct\n'
                        '   • Account is active\n'
                        '   • Correct URL format\n'
                        '3. Check for typos in password\n'
                        '4. Ask if IP whitelisting needed',
                        style: TextStyle(fontSize: 12),
                      ),
                      if (testUrl != null) ...[
                        const SizedBox(height: 16),
                        SelectableText(
                          'Test URL: $testUrl',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        } else {
          // Show regular error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading playlist: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}
