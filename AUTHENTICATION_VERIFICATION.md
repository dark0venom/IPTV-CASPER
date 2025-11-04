# Authentication Method Verification Guide

## ✅ Current Authentication Implementation

Your IPTV Casper app now supports **5 different authentication methods** that automatically try in sequence when credentials are provided.

### 🔐 Supported Authentication Methods

#### **Method 1: Xtream Codes API (get.php)**
- **Format**: `http://server.com/get.php?username=USER&password=PASS&type=m3u_plus`
- **Best for**: Most IPTV providers (Xtream Codes based)
- **Tab**: Use "Xtream Codes" tab in the app
- **Example**:
  ```
  Server: http://cf.hi-ott.me
  Username: 715a45eb20a3
  Password: your_password
  ```

#### **Method 2: Playlist.m3u with Query Parameters**
- **Format**: `http://server.com/playlist.m3u?username=USER&password=PASS`
- **Best for**: Some custom IPTV servers
- **Tab**: Use "M3U URL" tab with authentication enabled
- **Example**:
  ```
  URL: http://server.com/playlist.m3u
  Username: your_username
  Password: your_password
  ```

#### **Method 3: URL-Embedded Credentials**
- **Format**: `http://USER:PASS@server.com/playlist.m3u`
- **Best for**: Basic HTTP authentication
- **Tab**: Use "M3U URL" tab (enter full URL, no auth checkbox needed)
- **Example**:
  ```
  URL: http://715a45eb20a3:password@cf.hi-ott.me/playlist.m3u
  ```

#### **Method 4: HTTP Basic Auth Header**
- **Format**: Standard URL with Authorization header
- **Best for**: Servers requiring RFC 2617 Basic Authentication
- **Tab**: Use "M3U URL" tab with authentication enabled
- **Example**:
  ```
  URL: http://server.com/playlist.m3u
  Username: your_username
  Password: your_password
  (Uses "Authorization: Basic" header)
  ```

#### **Method 5: Original URL with Query Parameters**
- **Format**: `http://server.com?username=USER&password=PASS`
- **Best for**: Custom API endpoints
- **Tab**: Use "M3U URL" tab with authentication enabled

---

## 🔍 How to Test Authentication

### Option 1: Using the Test Script (Recommended)

1. Open PowerShell in the project folder
2. Run the authentication test script:
   ```powershell
   dart test_auth.dart
   ```
3. Enter your server details when prompted:
   - Server URL (e.g., `http://cf.hi-ott.me`)
   - Username (e.g., `715a45eb20a3`)
   - Password
4. The script will test all 5 methods and show which one works

### Option 2: Using the App

1. Launch the app: `flutter run -d windows`
2. Click the "Add Playlist" button (⊕ icon)
3. Choose your connection method:

   **For Xtream Codes providers:**
   - Go to "Xtream Codes" tab
   - Enter Server URL: `http://cf.hi-ott.me`
   - Enter Username: `715a45eb20a3`
   - Enter Password: (your password)
   - Click "Add"

   **For direct M3U URLs:**
   - Go to "M3U URL" tab
   - Enter the playlist URL
   - Check "Requires Authentication" if needed
   - Enter credentials
   - Click "Add"

4. Watch the console output for detailed logging:
   ```
   🔄 Attempt 1/5: Trying different auth method...
      🔗 URL: http://server.com/get.php?username=USER&password=****
      🔐 Using Basic Auth header
      📥 Status: 200
      ✅ Found 150 channels
   ✅ Success with method 1!
   ```

### Option 3: Manual URL Testing

Test URLs manually using curl or a web browser:

```powershell
# Test Method 1 (Xtream Codes)
curl "http://cf.hi-ott.me/get.php?username=715a45eb20a3&password=YOUR_PASS&type=m3u_plus"

# Test Method 2 (Playlist with params)
curl "http://cf.hi-ott.me/playlist.m3u?username=715a45eb20a3&password=YOUR_PASS"

# Test Method 3 (URL-embedded)
curl "http://715a45eb20a3:YOUR_PASS@cf.hi-ott.me/playlist.m3u"
```

---

## 🐛 Troubleshooting

### Status Code 884
This is **not a standard HTTP status code**. Possible causes:
- The URL is invalid or malformed
- The server is not responding correctly
- Network connectivity issues
- Firewall blocking the request

**Solutions:**
1. Verify your server URL is correct
2. Check if the server is online
3. Try accessing the URL in a web browser
4. Check firewall settings
5. Try the test script to see detailed error messages

### Status Code 401 (Unauthorized)
- **Cause**: Invalid credentials
- **Solution**: Double-check username and password

### Status Code 403 (Forbidden)
- **Cause**: Server denies access (even with valid credentials)
- **Solution**: Contact your IPTV provider

### Status Code 404 (Not Found)
- **Cause**: Incorrect URL path
- **Solution**: Verify the server URL and path

### All Methods Failed
If all 5 methods fail:
1. Run the test script to see detailed errors
2. Contact your IPTV provider for the correct URL format
3. Check if your provider uses a custom authentication method

---

## 📊 Console Logging Explained

The app now provides detailed logging for each authentication attempt:

```
🔄 Attempt 1/5: Trying different auth method...
   🔗 URL: http://server.com/get.php?username=USER&password=****
   🔐 Using Basic Auth header
   📥 Status: 200
   ✅ Found 150 channels
✅ Success with method 1!
```

**Symbols:**
- 🔄 = Attempting authentication
- 🔗 = URL being tested (password masked)
- 🔐 = Using HTTP Basic Auth header
- 📥 = HTTP response status
- ✅ = Success
- ❌ = Failed attempt
- 🔒 = Unauthorized (401)
- 🚫 = Forbidden (403)
- ❓ = Not Found (404)
- ⚠️ = Unexpected error
- 🌐 = Network error
- ⏱️ = Timeout

---

## ✨ Best Practices

1. **Start with Xtream Codes tab** - Most providers use this format
2. **Check console output** - Detailed logs help diagnose issues
3. **Run test script first** - Verify credentials before using the app
4. **Contact provider** - Ask for the correct URL format if unsure
5. **Keep credentials secure** - Passwords are masked in logs

---

## 🎯 Verification Checklist

- [x] **Multi-method authentication** - 5 different formats supported
- [x] **Automatic fallback** - Tries all methods sequentially
- [x] **Detailed logging** - Shows each attempt with status codes
- [x] **Password masking** - Credentials hidden in console output
- [x] **Timeout handling** - 15-second timeout per attempt
- [x] **Error handling** - Graceful failure with helpful messages
- [x] **VLC User-Agent** - Better server compatibility
- [x] **Tabbed interface** - Separate UI for each connection type
- [x] **Credential validation** - Form validation before submission
- [x] **Test script** - Standalone verification tool

---

## 📞 Need Help?

If authentication still fails after trying all methods:

1. **Run the test script**: `dart test_auth.dart`
2. **Check the logs** in the console output
3. **Contact your IPTV provider** and ask:
   - What authentication method do they use?
   - What is the correct playlist URL format?
   - Do they support M3U format?

---

## 🔧 Technical Details

### Implementation Files
- `lib/services/m3u_parser.dart` - Authentication logic
- `lib/widgets/add_playlist_dialog.dart` - UI with 3 tabs
- `test_auth.dart` - Standalone verification script

### Headers Sent
```
User-Agent: VLC/3.0.16 LibVLC/3.0.16
Accept: */*
Connection: keep-alive
Authorization: Basic [base64] (when applicable)
```

### Timeout
- 15 seconds per authentication attempt
- Total maximum: 75 seconds (5 attempts × 15s)

### Security
- Passwords are masked in console output
- Credentials stored securely in SharedPreferences
- HTTPS supported for secure transmission
