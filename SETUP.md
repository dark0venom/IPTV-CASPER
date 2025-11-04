# IPTV Casper - Setup Guide

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- Flutter SDK 3.0.0 or higher
- Visual Studio 2019 or higher with C++ build tools

### Installation Steps

1. **Install Flutter SDK**
   - Download from: https://flutter.dev/docs/get-started/install/windows
   - Add Flutter to PATH
   - Run `flutter doctor` to verify installation

2. **Install Dependencies**
   ```powershell
   flutter pub get
   ```

3. **Run the Application**
   ```powershell
   flutter run -d windows
   ```

4. **Build for Release**
   ```powershell
   flutter build windows --release
   ```
   The executable will be in `build\windows\runner\Release\`

## 📖 Usage Guide

### Adding Playlists

#### Method 1: From URL
1. Click the "+" button or use the "Add Playlist" menu
2. Select "URL" option
3. Enter a playlist name and URL
4. Click "Add"

Example URLs:
- `http://example.com/playlist.m3u`
- `https://iptv-org.github.io/iptv/index.m3u`

#### Method 2: From File
1. Click the "+" button
2. Select "File" option
3. Enter a playlist name
4. Click "Select M3U File" and browse for your .m3u or .m3u8 file
5. Click "Add"

### Playing Channels
1. Browse the channel list on the left sidebar
2. Click on any channel to start playback
3. Use the player controls to:
   - Play/Pause
   - Adjust volume
   - Enter fullscreen mode

### Managing Favorites
- Click the star icon next to any channel to add it to favorites
- Use the star filter button to show only favorite channels

### Searching and Filtering
- Use the search bar to find channels by name
- Select a group from the dropdown to filter by category
- Combine search and group filters for precise results

## 🎨 Features

### Video Player
- **Play/Pause**: Space bar or click the play button
- **Volume Control**: Adjust with slider or use mute button
- **Fullscreen**: Click fullscreen button or double-click video
- **Buffer Indicator**: Automatic loading spinner during buffering

### Channel Management
- **Search**: Real-time search across all channels
- **Groups**: Filter channels by group/category
- **Favorites**: Mark and filter favorite channels
- **Channel Info**: View channel name, group, and logo

### Settings
- **Auto-play**: Automatically start playing when selecting a channel
- **Channel Logos**: Toggle display of channel logos
- **Default Volume**: Set startup volume level
- **Aspect Ratio**: Choose video aspect ratio

## 🔧 Troubleshooting

### Video Won't Play
- Ensure the stream URL is valid and accessible
- Check your internet connection
- Try a different channel
- Some streams may require VPN

### No Channels Loading
- Verify the M3U file or URL is correctly formatted
- Check if the URL is accessible in a web browser
- Ensure the file path is correct for local files

### Performance Issues
- Close other applications to free up resources
- Reduce video quality if available in stream
- Check CPU and memory usage

## 📝 M3U Format

The app supports standard M3U/M3U8 playlist formats:

```
#EXTM3U
#EXTINF:-1 tvg-id="channel1" tvg-name="Channel 1" tvg-logo="http://example.com/logo.png" group-title="Entertainment",Channel Name
http://example.com/stream.m3u8
```

### Supported Attributes
- `tvg-id`: Channel ID
- `tvg-name`: Channel name
- `tvg-logo`: Channel logo URL
- `group-title`: Channel category/group

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── channel.dart
│   └── playlist.dart
├── providers/                # State management
│   ├── player_provider.dart
│   ├── playlist_provider.dart
│   └── settings_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   └── m3u_parser.dart
└── widgets/                  # Reusable widgets
    ├── channel_list.dart
    ├── video_player_widget.dart
    └── add_playlist_dialog.dart
```

### Key Dependencies
- `media_kit`: Video playback engine
- `media_kit_video`: Video rendering
- `provider`: State management
- `shared_preferences`: Local storage
- `file_picker`: File selection dialog

## 📄 License

MIT License - Feel free to use and modify as needed.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## ⚠️ Disclaimer

This application is for educational purposes. Users are responsible for ensuring they have the right to access any streams they use with this application.
