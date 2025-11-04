# 📺 Xtream Codes API Reference

## Overview
Xtream Codes is the most popular IPTV panel API. This document explains the correct endpoints and parameters.

---

## 🔐 Authentication

All Xtream Codes requests require:
- `username` - Your account username
- `password` - Your account password

These are passed as **URL query parameters** (NOT as HTTP Basic Auth headers).

---

## 📡 API Endpoints

### 1. **get.php** - Playlist Download
**Purpose**: Download M3U playlist with all channels

**Correct Formats**:
```
http://server.com/get.php?username=USER&password=PASS&type=m3u_plus
http://server.com/get.php?username=USER&password=PASS&type=m3u
http://server.com/get.php?username=USER&password=PASS
```

**Parameters**:
- `username` (required) - Your username
- `password` (required) - Your password
- `type` (optional) - Format type
  - `m3u_plus` - Enhanced M3U with EPG data (recommended)
  - `m3u` - Basic M3U format
  - If omitted, server decides

**Returns**: M3U playlist file

**Example**:
```bash
curl "http://server.com/get.php?username=myuser&password=mypass&type=m3u_plus"
```

---

### 2. **player_api.php** - API v2 JSON Interface
**Purpose**: Get channel data in JSON format for dynamic loading

**Correct Formats**:
```
http://server.com/player_api.php?username=USER&password=PASS&action=get_live_streams
http://server.com/player_api.php?username=USER&password=PASS&action=get_vod_streams
http://server.com/player_api.php?username=USER&password=PASS&action=get_series
http://server.com/player_api.php?username=USER&password=PASS
```

**Parameters**:
- `username` (required) - Your username
- `password` (required) - Your password
- `action` (optional) - What to retrieve
  - `get_live_streams` - Live TV channels
  - `get_vod_streams` - Video on Demand
  - `get_series` - TV Series
  - `get_live_categories` - Channel categories
  - If omitted, returns server info

**Returns**: JSON response

**Example**:
```bash
# Get live streams
curl "http://server.com/player_api.php?username=myuser&password=mypass&action=get_live_streams"

# Get server info
curl "http://server.com/player_api.php?username=myuser&password=mypass"
```

**Response Example** (server info):
```json
{
  "user_info": {
    "username": "myuser",
    "password": "mypass",
    "message": "Active",
    "auth": 1,
    "status": "Active",
    "exp_date": "1735689600",
    "is_trial": "0",
    "active_cons": "1",
    "created_at": "1698710400",
    "max_connections": "2",
    "allowed_output_formats": ["m3u8", "ts", "rtmp"]
  },
  "server_info": {
    "url": "http://server.com",
    "port": "80",
    "https_port": "443",
    "server_protocol": "http",
    "rtmp_port": "1935",
    "timezone": "Europe/London",
    "timestamp_now": 1698796800
  }
}
```

---

### 3. **xmltv.php** - EPG Data
**Purpose**: Get Electronic Program Guide (TV schedule)

**Format**:
```
http://server.com/xmltv.php?username=USER&password=PASS
```

**Parameters**:
- `username` (required)
- `password` (required)

**Returns**: XML TV guide data

---

## 🚫 Common Mistakes

### ❌ Wrong: Missing action parameter
```
http://server.com/player_api.php?username=USER&password=PASS
```
This returns only server info, not channel list!

### ✅ Correct: With action parameter
```
http://server.com/player_api.php?username=USER&password=PASS&action=get_live_streams
```

---

### ❌ Wrong: Using HTTP Basic Auth headers
```dart
// Don't do this for Xtream Codes!
headers['Authorization'] = 'Basic base64(username:password)';
request.get('http://server.com/get.php');
```

### ✅ Correct: Credentials in URL
```dart
final url = 'http://server.com/get.php?username=user&password=pass&type=m3u_plus';
request.get(url);
```

---

### ❌ Wrong: URL-embedded credentials
```
http://username:password@server.com/get.php?type=m3u_plus
```
Xtream Codes does NOT support this format!

### ✅ Correct: Query parameters
```
http://server.com/get.php?username=username&password=password&type=m3u_plus
```

---

## 🔍 Authentication Test Order

Our app tries methods in this order:

1. ✅ **get.php with m3u_plus** (BEST - most compatible)
   ```
   http://server.com/get.php?username=USER&password=PASS&type=m3u_plus
   ```

2. ✅ **player_api.php with get_live_streams** (Modern servers)
   ```
   http://server.com/player_api.php?username=USER&password=PASS&action=get_live_streams
   ```

3. ✅ **get.php with m3u** (Fallback)
   ```
   http://server.com/get.php?username=USER&password=PASS&type=m3u
   ```

4. ✅ **player_api.php with get_series** (Series-focused servers)
   ```
   http://server.com/player_api.php?username=USER&password=PASS&action=get_series
   ```

5. ✅ **player_api.php basic** (Get server info first)
   ```
   http://server.com/player_api.php?username=USER&password=PASS
   ```

6. ⚠️ **get.php without type** (Let server decide)
   ```
   http://server.com/get.php?username=USER&password=PASS
   ```

7-11. Other fallback methods for non-Xtream servers

---

## 🎯 Provider-Specific Notes

### Cloudflare-Protected Servers (e.g., cf.hi-ott.me)

**Issue**: Returns error 884 "Invalid Authentication"

**Solution**: Use VLC User-Agent
```dart
headers['User-Agent'] = 'VLC/3.0.20 LibVLC/3.0.20';
```

**Why**: Cloudflare often whitelists VLC but blocks generic HTTP clients.

---

### Port Numbers

Some servers require specific ports:
```
http://server.com:8080/get.php?username=USER&password=PASS&type=m3u_plus
http://server.com:25461/get.php?username=USER&password=PASS&type=m3u_plus
```

Common ports:
- `80` - HTTP (default)
- `8080` - Alternative HTTP
- `25461` - Common Xtream port
- `443` - HTTPS

---

## 📝 URL Encoding

Always encode special characters in username/password:

```dart
final encUser = Uri.encodeComponent(username);
final encPass = Uri.encodeComponent(password);
final url = 'http://server.com/get.php?username=$encUser&password=$encPass&type=m3u_plus';
```

**Characters that need encoding**:
- Space → `%20`
- `@` → `%40`
- `#` → `%23`
- `&` → `%26`
- `=` → `%3D`
- `+` → `%2B`

---

## 🧪 Testing Commands

### Test get.php endpoint:
```bash
curl "http://server.com/get.php?username=myuser&password=mypass&type=m3u_plus"
```

### Test player_api.php:
```bash
# Get server info
curl "http://server.com/player_api.php?username=myuser&password=mypass"

# Get channels
curl "http://server.com/player_api.php?username=myuser&password=mypass&action=get_live_streams"
```

### Test with VLC User-Agent:
```bash
curl -A "VLC/3.0.20 LibVLC/3.0.20" "http://server.com/get.php?username=myuser&password=mypass&type=m3u_plus"
```

---

## 🔄 Expected Response Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 200 | Success | ✅ Working correctly |
| 401 | Unauthorized | ❌ Wrong username/password |
| 403 | Forbidden | ❌ Account suspended or IP blocked |
| 404 | Not Found | ❌ Wrong URL/endpoint |
| 884 | Cloudflare Auth Error | ⚠️ Use VLC User-Agent |
| 500 | Server Error | ⚠️ Provider issue, try later |

---

## 💡 Troubleshooting

### Problem: 401 Unauthorized
**Check**:
1. Username is correct (case-sensitive)
2. Password is correct (no typos)
3. Credentials are URL-encoded
4. Account is not expired
5. Using correct endpoint (get.php, not player_api.php)

### Problem: 884 Cloudflare Error
**Solutions**:
1. Use VLC User-Agent
2. Try from different IP address
3. Ask provider to whitelist your IP
4. Use VPN if provider blocks your region

### Problem: Empty Response (0 bytes)
**Possible causes**:
1. Wrong credentials
2. Expired account
3. Server maintenance
4. IP not whitelisted
5. Wrong URL format

### Problem: Response says "401 Unauthorized" in body
**This means**: Credentials are wrong even though HTTP status is 200

---

## 📚 Official Xtream Codes API Endpoints

For reference, here are all official endpoints:

| Endpoint | Purpose | Parameters |
|----------|---------|------------|
| `get.php` | Get M3U playlist | `username`, `password`, `type` |
| `player_api.php` | JSON API v2 | `username`, `password`, `action` |
| `xmltv.php` | EPG data (XML) | `username`, `password` |
| `panel_api.php` | Admin panel API | `username`, `password` (admin) |

---

## ✅ Best Practices

1. ✅ Always use `get.php?...&type=m3u_plus` as first attempt
2. ✅ URL-encode username and password
3. ✅ Use VLC User-Agent for Cloudflare servers
4. ✅ Include action parameter when using player_api.php
5. ✅ Test credentials in browser first
6. ✅ Check server supports Xtream Codes API
7. ✅ Verify account is active before troubleshooting

---

**Last Updated**: November 3, 2025  
**API Version**: Xtream Codes v2  
**Compatibility**: All Xtream Codes based IPTV panels
