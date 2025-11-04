# Authentication Troubleshooting Guide

## Updated Authentication Methods

The app now supports **multiple authentication methods** automatically:

### 1. **URL-Embedded Credentials** (Most Common)
```
http://username:password@server.com/playlist.m3u
```
The app automatically converts your credentials to this format.

### 2. **Query Parameters**
```
http://server.com/playlist.m3u?username=user&password=pass
```
Supported if the URL already contains username/password parameters.

### 3. **HTTP Basic Authentication**
```
Authorization: Basic base64(username:password)
```
Automatically added as a fallback header.

## What Was Fixed

### ✅ URL Encoding
- Special characters in username/password are now properly encoded
- Fixes issues with passwords containing `@`, `:`, `/`, etc.

### ✅ Multiple Auth Methods
- Tries URL-embedded auth first (most compatible with IPTV)
- Falls back to HTTP Basic Auth header
- Supports query parameters if already in URL

### ✅ Better Error Messages
- Shows specific HTTP status codes (401, 403, 404)
- Indicates authentication vs. network vs. access issues
- Provides actionable error messages

### ✅ Debug Logging
- Logs connection attempts (with password hidden)
- Shows response status codes
- Displays number of channels parsed

## Common Issues & Solutions

### ❌ "Authentication failed (401)"
**Cause**: Invalid username or password

**Solutions**:
1. Double-check your credentials (case-sensitive)
2. Try copying and pasting to avoid typos
3. Verify with your IPTV provider
4. Test credentials in a web browser first

### ❌ "Access denied (403)"
**Cause**: Valid credentials but no permission

**Solutions**:
1. Your account may be expired
2. Check if your IP is allowed
3. Verify your subscription is active
4. Contact your IPTV provider

### ❌ "Playlist not found (404)"
**Cause**: URL is incorrect

**Solutions**:
1. Verify the playlist URL is correct
2. Check for typos in the URL
3. Ensure the path is complete
4. Confirm with your provider

### ❌ "Network error: Cannot reach the server"
**Cause**: Connection issues

**Solutions**:
1. Check your internet connection
2. Verify the server is online
3. Check firewall settings
4. Try a different network

### ❌ "Connection timeout"
**Cause**: Server not responding

**Solutions**:
1. Check your internet speed
2. Server may be overloaded
3. Try again later
4. Contact your provider

## Testing Your Credentials

### Method 1: Browser Test
1. Open your web browser
2. Enter: `http://username:password@yourserver.com/playlist.m3u`
3. If it downloads/shows content, credentials are correct

### Method 2: cURL Test (Windows PowerShell)
```powershell
# Test with Basic Auth
curl -u "username:password" "http://yourserver.com/playlist.m3u"

# Test with URL-embedded auth
curl "http://username:password@yourserver.com/playlist.m3u"
```

### Method 3: Check Console Output
1. Run the app from command line: `flutter run -d windows`
2. Try to load your playlist
3. Look for lines starting with:
   - `📡 Fetching playlist from:` - Shows the URL being used
   - `🔐 Using authentication` - Confirms auth is being used
   - `📥 Response status:` - Shows HTTP response code
   - `✅ Successfully parsed` - Shows if it worked

## Special Characters in Credentials

If your username or password contains special characters:

### These are now handled automatically:
- `@` → `%40`
- `:` → `%3A`
- `/` → `%2F`
- `?` → `%3F`
- `#` → `%23`
- `&` → `%26`
- `=` → `%3D`
- `+` → `%2B`
- ` ` (space) → `%20`

**No need to manually encode** - the app does it for you!

## Different IPTV Provider Formats

### Format 1: Panel-based (Xtream Codes)
```
URL: http://server.com:8080/get.php?username=XXX&password=YYY&type=m3u_plus
```
✅ Use the checkbox and enter username/password separately

### Format 2: Simple Auth
```
URL: http://username:password@server.com/playlist.m3u
```
✅ Either format works - enter credentials separately or in URL

### Format 3: Token-based
```
URL: http://server.com/playlist.m3u?token=XXXXX
```
❌ Don't use authentication checkbox - just paste the complete URL

### Format 4: No Auth
```
URL: http://server.com/public/playlist.m3u
```
❌ Don't enable authentication - just use the URL

## Debug Mode

To see detailed authentication logs:

1. Run from terminal: `flutter run -d windows`
2. Try loading your playlist
3. Watch for these messages:

```
📡 Fetching playlist from: http://server.com/playlist.m3u
🔐 Using authentication with username: myuser
📥 Response status: 200
✅ Successfully parsed 150 channels
```

## Still Not Working?

### Collect This Information:
1. HTTP status code from console (📥 Response status)
2. Exact error message shown
3. IPTV provider name
4. URL format (with credentials removed)
5. Any special characters in your password

### Try These Steps:
1. ✅ Test credentials in web browser
2. ✅ Verify your subscription is active
3. ✅ Check if you can access on other devices
4. ✅ Contact your IPTV provider
5. ✅ Ask provider which auth method they use

## Security Reminder

🔒 **Your credentials are stored locally** on your device only:
- Not sent anywhere except your IPTV server
- Stored in app's local storage
- Passwords hidden in logs (shown as ****)

⚠️ **Security tips**:
- Only use on trusted devices
- Don't share your credentials
- Change password regularly
- Use strong passwords

## Need More Help?

Check the console output when loading playlists - it shows:
- What URL is being accessed
- What authentication method is being used
- What the server responded with
- How many channels were found

This information helps identify exactly where the issue is!

---

**Last Updated**: November 3, 2025  
**Version**: 1.1.0 (Enhanced Authentication)
