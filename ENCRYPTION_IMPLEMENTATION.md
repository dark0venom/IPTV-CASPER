# 🔐 Credential Encryption Implementation

## Overview
All IPTV playlist credentials (username and password) are now **encrypted at rest** using AES-256 encryption. This provides strong security for your stored credentials while maintaining full functionality.

---

## 🛡️ Security Features

### 1. **AES-256-CBC Encryption**
- Industry-standard encryption algorithm
- 256-bit encryption key (32 bytes)
- Cipher Block Chaining (CBC) mode
- 128-bit initialization vector (16 bytes)

### 2. **Secure Key Storage**
- Encryption keys stored in **Flutter Secure Storage**
- Platform-specific secure storage:
  - **Windows**: Windows Credential Store (Credential Manager)
  - **Android**: Android Keystore
  - **iOS**: iOS Keychain
  - **Linux**: Secret Service API / libsecret
  - **macOS**: macOS Keychain

### 3. **Key Management**
- Unique encryption key per device
- Keys generated on first run
- Keys never leave the device
- Persistent across app restarts

---

## 🔄 How It Works

### When Adding a Playlist:
```
1. User enters username/password in plain text
2. Credentials sent to IPTV server (plain text, required for authentication)
3. Server responds with playlist
4. Before saving: Credentials encrypted with AES-256
5. Encrypted credentials stored in SharedPreferences
6. Original plain text discarded
```

### When Loading a Playlist:
```
1. App reads encrypted credentials from storage
2. Credentials decrypted using device key
3. Plain text credentials used for server authentication
4. Playlist loaded successfully
5. Decrypted credentials never saved back to storage
```

### Migration from Old Version:
```
1. On first run with new version
2. App detects plain text credentials in storage
3. Automatically encrypts existing credentials
4. Updates storage with encrypted versions
5. Plain text credentials removed
```

---

## 📁 Files Modified

### Core Files:
- **`lib/services/encryption_service.dart`** (NEW)
  - Main encryption service using AES-256
  - Key generation and storage
  - Encrypt/decrypt methods
  - Password hashing (SHA-256)

- **`lib/models/playlist.dart`**
  - Added `isEncrypted` flag
  - Updated JSON serialization
  - Supports both encrypted and plain text (backward compatible)

- **`lib/providers/playlist_provider.dart`**
  - Initialize encryption service on startup
  - Encrypt credentials before saving
  - Decrypt credentials before use
  - Automatic migration of old playlists

### Dependencies Added:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0  # Secure key storage
  encrypt: ^5.0.3                  # AES encryption
  crypto: ^3.0.3                   # Hashing algorithms
```

---

## 🔒 What Gets Encrypted

### Encrypted:
✅ **Username** - Encrypted in storage  
✅ **Password** - Encrypted in storage  

### Not Encrypted:
❌ **Playlist URL** - Stored in plain text (needed for UI display)  
❌ **Playlist Name** - Stored in plain text (user-visible)  
❌ **Channels List** - Stored in plain text (M3U content)  
❌ **Stream URLs** - Not encrypted (from playlist, used by video player)  

**Why?** Only authentication credentials are sensitive. URLs and channel names are not secret and are needed for app functionality.

---

## 🚀 Usage

### For Users:
**No action required!** Encryption happens automatically:
- New playlists: Credentials encrypted when saved
- Existing playlists: Automatically migrated on first run
- No change to user experience
- No additional passwords or setup

### For Developers:

#### Encrypt credentials:
```dart
final encryptionService = EncryptionService();
await encryptionService.initialize();

final encrypted = await encryptionService.encryptCredentials(
  username: 'myuser',
  password: 'mypassword',
);

// encrypted['username'] -> Base64 encrypted string
// encrypted['password'] -> Base64 encrypted string
```

#### Decrypt credentials:
```dart
final decrypted = await encryptionService.decryptCredentials(
  encryptedUsername: encryptedUser,
  encryptedPassword: encryptedPass,
);

// decrypted['username'] -> Plain text username
// decrypted['password'] -> Plain text password
```

#### Encrypt single value:
```dart
final encryptedValue = await encryptionService.encryptValue('sensitive_data');
final decryptedValue = await encryptionService.decryptValue(encryptedValue);
```

---

## 🔍 Console Output

When the app runs with encryption enabled, you'll see:

```
🔐 Encrypting credentials for storage...
✅ Playlist saved with encrypted credentials

🔓 Decrypting credentials for playlist reload...
```

During migration:
```
🔐 Migrating playlist "My IPTV" to encrypted storage...
✅ Credentials migration completed
```

---

## 📊 Storage Format

### Before Encryption:
```json
{
  "name": "My IPTV",
  "username": "user123",
  "password": "pass456",
  "requiresAuth": true,
  "isEncrypted": false
}
```

### After Encryption:
```json
{
  "name": "My IPTV",
  "username": "xJ8kL2mP9qR...==",  // Base64 AES-256 encrypted
  "password": "7nM3bV5cX8z...==",  // Base64 AES-256 encrypted
  "requiresAuth": true,
  "isEncrypted": true
}
```

---

## 🛡️ Security Considerations

### ✅ Protected Against:
- **Data at Rest Attacks**: Credentials encrypted in storage
- **Storage Inspection**: Cannot read credentials from files
- **Memory Dumps** (partial): Credentials only in memory during use
- **App Decompilation**: Keys not in app code

### ⚠️ Not Protected Against:
- **Device Compromise**: If device is rooted/jailbroken, keys can be extracted
- **Memory Analysis**: Decrypted credentials briefly in memory during use
- **Network Sniffing**: Credentials sent to server over HTTP (use HTTPS servers)
- **Malware**: Malicious apps with system access can extract keys

### 🔐 Best Practices:
1. ✅ Use HTTPS servers when possible
2. ✅ Keep device updated and secure
3. ✅ Use device lock screen/PIN
4. ✅ Don't root/jailbreak device
5. ✅ Install from official app stores only

---

## 🧪 Testing Encryption

### Test encryption/decryption:
```dart
final encryptionService = EncryptionService();
await encryptionService.initialize();

// Test
final original = 'my_secret_password';
final encrypted = await encryptionService.encryptValue(original);
final decrypted = await encryptionService.decryptValue(encrypted);

assert(original == decrypted); // Should be true
print('Encrypted: $encrypted'); // Base64 string
print('Decrypted: $decrypted'); // Original password
```

### Clear keys (for testing):
```dart
await encryptionService.clearKeys();
// Keys deleted, new ones will be generated on next initialize()
```

---

## 🔄 Backward Compatibility

The implementation is **fully backward compatible**:

1. **Old playlists** (plain text credentials):
   - Still work immediately
   - Automatically migrated on first load
   - No data loss

2. **New playlists**:
   - Automatically use encryption
   - Transparent to user

3. **Mixed state**:
   - Some encrypted, some plain text
   - All work correctly
   - Migration happens gradually

---

## 📱 Platform Support

| Platform | Secure Storage | Status |
|----------|----------------|--------|
| Windows | Credential Manager | ✅ Supported |
| Android | Android Keystore | ✅ Supported |
| iOS | iOS Keychain | ✅ Supported |
| macOS | macOS Keychain | ✅ Supported |
| Linux | Secret Service | ✅ Supported |
| Web | localStorage (encrypted) | ⚠️ Less secure |

**Note**: Web storage is less secure than native platforms. Consider additional security measures for web deployments.

---

## 🐛 Troubleshooting

### Issue: "Encryption failed"
**Solution**: Check if flutter_secure_storage is properly initialized
```dart
await encryptionService.initialize();
```

### Issue: "Decryption failed"
**Causes**:
1. Corrupted encrypted data
2. Keys were cleared
3. Storage was manually edited

**Solution**: The service falls back to plain text if decryption fails (backward compatible)

### Issue: Migration not working
**Check**:
- Console shows "Migrating playlist..." message
- `isEncrypted` flag is set to `true` after migration
- Old credentials still work during migration

---

## 🎯 Summary

✅ **AES-256 encryption** for all credentials  
✅ **Secure key storage** per platform  
✅ **Automatic migration** from plain text  
✅ **Zero user configuration** required  
✅ **Backward compatible** with old versions  
✅ **Console logging** for debugging  
✅ **Production ready** security  

Your IPTV credentials are now **secure at rest** while maintaining full app functionality!

---

**Version**: 1.1.0  
**Date**: November 3, 2025  
**Status**: ✅ Implemented and Tested
