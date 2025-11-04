# Hi-OTT.me Provider Guide

## For Hi-OTT.me (cf.hi-ott.me) Users

Your provider uses a specific format. Here's how to set it up:

### Method 1: Using the App's Auth Dialog (Recommended)

1. Click "Add Playlist"
2. Enter playlist name (e.g., "My IPTV")
3. **For URL, enter**: `http://cf.hi-ott.me`
4. ✅ Check "Requires Authentication"
5. Enter your username: `715a45eb20a3` (or your actual username)
6. Enter your password
7. Click "Add"

The app will automatically try these formats:
- `http://cf.hi-ott.me/get.php?username=XXX&password=YYY&type=m3u_plus`
- `http://cf.hi-ott.me/playlist.m3u?username=XXX&password=YYY`
- `http://username:password@cf.hi-ott.me`
- And more variations...

### Method 2: Direct URL (If you have it)

If your provider gave you a complete URL like:
```
http://cf.hi-ott.me/get.php?username=715a45eb20a3&password=YOUR_PASSWORD&type=m3u_plus
```

Just paste the complete URL and **DON'T** check "Requires Authentication".

### Method 3: Manual Format

Try these URL formats one by one:

**Xtream Codes API format** (most common):
```
http://cf.hi-ott.me/get.php?username=YOUR_USERNAME&password=YOUR_PASSWORD&type=m3u_plus
```

**Simple playlist format**:
```
http://cf.hi-ott.me/playlist.m3u?username=YOUR_USERNAME&password=YOUR_PASSWORD
```

**URL-embedded auth**:
```
http://YOUR_USERNAME:YOUR_PASSWORD@cf.hi-ott.me/get.php?type=m3u_plus
```

### Common Issues

#### ❌ 401 Error (Authentication Failed)
**Possible causes**:
1. Wrong username or password (case-sensitive!)
2. Your subscription expired
3. Wrong URL format for this provider
4. Account locked (too many failed attempts)

**Solutions**:
1. Double-check your credentials (copy-paste to avoid typos)
2. Verify your account is active with your provider
3. Wait 5 minutes if you had multiple failed attempts
4. Contact your provider to verify the correct URL format

#### ❌ Can't connect
1. Check if `cf.hi-ott.me` is accessible from your network
2. Some ISPs block IPTV traffic - try a VPN
3. Check your firewall settings

### Testing Your Credentials

**Test in browser** (replace with your actual credentials):
```
http://cf.hi-ott.me/get.php?username=YOUR_USERNAME&password=YOUR_PASSWORD&type=m3u_plus
```

If it downloads a `.m3u` file or shows M3U content, your credentials are correct!

### Multi-Attempt Feature

The app now tries **5 different authentication methods** automatically:
1. ✅ Standard path with get.php
2. ✅ Xtream Codes format with query params
3. ✅ Playlist.m3u with query params  
4. ✅ URL-embedded authentication
5. ✅ Direct URL with added params

You'll see in the console:
```
🔄 Attempt 1/5: Trying different auth method...
   📥 Status: 401
❌ Method 1 failed: Authentication failed
🔄 Attempt 2/5: Trying different auth method...
   📥 Status: 200
   ✅ Found 150 channels
✅ Success with method 2!
```

### What to Tell Your Provider

If nothing works, contact your provider and ask:

1. **What is the correct playlist URL format?**
   - Is it Xtream Codes API?
   - Is it direct M3U file?
   - Is it something else?

2. **Do I need a specific port number?**
   - Example: `http://cf.hi-ott.me:8080/...`

3. **Is there a specific endpoint?**
   - `/get.php`
   - `/playlist.m3u`  
   - `/player_api.php`

4. **Are my credentials correct?**
   - Confirm username and password
   - Check if case-sensitive
   - Verify account is active

### Advanced: Manual Testing

**Windows PowerShell**:
```powershell
# Test method 1
curl "http://cf.hi-ott.me/get.php?username=YOUR_USER&password=YOUR_PASS&type=m3u_plus"

# Test method 2
curl "http://YOUR_USER:YOUR_PASS@cf.hi-ott.me/get.php?type=m3u_plus"

# Test method 3
curl -u "YOUR_USER:YOUR_PASS" "http://cf.hi-ott.me/playlist.m3u"
```

**Look for**:
- HTTP 200 = Success ✅
- HTTP 401 = Wrong credentials ❌
- HTTP 403 = No permission ❌
- HTTP 404 = Wrong URL ❌

### Example Working Setup

```
Name: My IPTV
URL: http://cf.hi-ott.me
✅ Requires Authentication
Username: 715a45eb20a3
Password: [your password]
```

The app will automatically find the right format!

---

**Updated**: November 3, 2025  
**Feature**: Multi-method authentication (5 attempts)
