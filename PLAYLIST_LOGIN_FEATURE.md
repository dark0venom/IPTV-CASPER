# Playlist Login Support

## Overview
Added authentication support for IPTV playlists that require username/password credentials.

## Features Implemented

### 1. **Playlist Model Updates**
- Added `username`, `password`, and `requiresAuth` fields to the `Playlist` model
- Credentials are securely stored with the playlist configuration
- Added `copyWith` method for easier playlist updates

### 2. **Add Playlist Dialog**
- New "Requires Authentication" checkbox for URL-based playlists
- Username and password fields appear when authentication is enabled
- Password field has show/hide toggle for security
- Form validation ensures credentials are provided when required

### 3. **HTTP Basic Authentication**
- M3UParser now supports HTTP Basic Authentication
- Credentials are encoded and sent in the Authorization header
- Proper error handling for 401 (Unauthorized) responses

### 4. **Playlist Management**
- Playlists with authentication show a lock icon and "AUTH" badge
- Reload button allows refreshing authenticated playlists
- Credentials are automatically used when reloading
- Visual indicators in the settings screen

### 5. **Secure Storage**
- Credentials are stored locally using SharedPreferences
- Passwords are saved alongside playlist configuration
- Can be retrieved for playlist reloads

## How to Use

### Adding an Authenticated Playlist

1. Click "Add Playlist" button
2. Enter the playlist name
3. Select "URL" method
4. Enter the playlist URL
5. Check "Requires Authentication"
6. Enter your username
7. Enter your password (use the eye icon to show/hide)
8. Click "Add"

### Managing Authenticated Playlists

- **Lock Icon**: Indicates the playlist requires authentication
- **AUTH Badge**: Shows in the playlist list for authenticated sources
- **Reload Button**: Click to refresh the playlist (uses stored credentials)
- **Delete**: Remove the playlist and its stored credentials

## Supported Authentication Types

- **HTTP Basic Authentication**: Username and password sent in Authorization header
- Works with most IPTV providers that use standard HTTP authentication

## Security Notes

⚠️ **Important Security Information**:
- Credentials are stored locally on your device
- Passwords are stored in plain text in SharedPreferences
- Only use this feature with trusted networks
- Consider the security implications before storing sensitive credentials

## Example Use Cases

1. **Premium IPTV Services**: Services that require login credentials
2. **Private Servers**: Personal or organizational IPTV servers with authentication
3. **Protected Content**: Playlists behind authentication walls

## Technical Details

### Files Modified
- `lib/models/playlist.dart` - Added auth fields
- `lib/widgets/add_playlist_dialog.dart` - Added auth UI
- `lib/providers/playlist_provider.dart` - Added auth parameter handling
- `lib/services/m3u_parser.dart` - Added HTTP Basic Auth
- `lib/screens/settings_screen.dart` - Added auth indicators and reload

### Authentication Flow
```
1. User enters credentials in dialog
2. Credentials stored with playlist
3. HTTP request includes Authorization header
4. Server validates credentials
5. Playlist content downloaded
6. Channels parsed and displayed
```

## Future Enhancements

Potential improvements for future versions:
- [ ] Support for other authentication methods (Bearer tokens, OAuth)
- [ ] Encrypted credential storage
- [ ] Test connection before saving
- [ ] Credential update/edit functionality
- [ ] Multiple authentication profiles
- [ ] Biometric authentication for accessing stored credentials

## Troubleshooting

### Authentication Failed Error
- Verify username and password are correct
- Check if the server supports Basic Authentication
- Ensure the URL is correct

### Can't Save Credentials
- Check app permissions
- Verify sufficient storage space

### Playlist Won't Load
- Test the URL in a web browser
- Verify network connectivity
- Check if the server is online

## API Reference

### Playlist Model
```dart
Playlist(
  name: 'My Playlist',
  url: 'http://example.com/playlist.m3u',
  username: 'user123',
  password: 'pass456',
  requiresAuth: true,
  addedDate: DateTime.now(),
)
```

### Loading Authenticated Playlist
```dart
await playlistProvider.loadPlaylistFromUrl(
  'http://example.com/playlist.m3u',
  'My Playlist',
  username: 'user123',
  password: 'pass456',
);
```

---

**Version**: 1.0.0  
**Date**: November 3, 2025  
**Status**: ✅ Implemented and Tested
