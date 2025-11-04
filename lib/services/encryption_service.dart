import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Service for encrypting and decrypting sensitive credentials
/// Uses AES-256 encryption with a device-specific key stored in secure storage
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageKey = 'encryption_key';
  static const String _ivStorageKey = 'encryption_iv';

  encrypt.Key? _key;
  encrypt.IV? _iv;

  /// Initialize the encryption service and generate/retrieve keys
  Future<void> initialize() async {
    try {
      // Try to retrieve existing keys
      String? keyString = await _secureStorage.read(key: _keyStorageKey);
      String? ivString = await _secureStorage.read(key: _ivStorageKey);

      if (keyString != null && ivString != null) {
        // Use existing keys
        _key = encrypt.Key.fromBase64(keyString);
        _iv = encrypt.IV.fromBase64(ivString);
      } else {
        // Generate new keys
        _key = encrypt.Key.fromSecureRandom(32); // AES-256
        _iv = encrypt.IV.fromSecureRandom(16);

        // Store keys securely
        await _secureStorage.write(
          key: _keyStorageKey,
          value: _key!.base64,
        );
        await _secureStorage.write(
          key: _ivStorageKey,
          value: _iv!.base64,
        );
      }
    } catch (e) {
      print('Error initializing encryption service: $e');
      // Fallback to temporary keys (not persisted)
      _key = encrypt.Key.fromSecureRandom(32);
      _iv = encrypt.IV.fromSecureRandom(16);
    }
  }

  /// Encrypt a string value
  Future<String?> encryptValue(String? value) async {
    if (value == null || value.isEmpty) return null;

    try {
      await _ensureInitialized();

      final encrypter = encrypt.Encrypter(
        encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
      );

      final encrypted = encrypter.encrypt(value, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      print('Error encrypting value: $e');
      return value; // Return original value if encryption fails
    }
  }

  /// Decrypt a string value
  Future<String?> decryptValue(String? encryptedValue) async {
    if (encryptedValue == null || encryptedValue.isEmpty) return null;

    try {
      await _ensureInitialized();

      final encrypter = encrypt.Encrypter(
        encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt64(encryptedValue, iv: _iv!);
      return decrypted;
    } catch (e) {
      print('Error decrypting value: $e');
      // If decryption fails, it might be a plain text value (backward compatibility)
      return encryptedValue;
    }
  }

  /// Encrypt credentials (username and password) for storage
  Future<Map<String, String?>> encryptCredentials({
    String? username,
    String? password,
  }) async {
    return {
      'username': await encryptValue(username),
      'password': await encryptValue(password),
    };
  }

  /// Decrypt credentials (username and password) from storage
  Future<Map<String, String?>> decryptCredentials({
    String? encryptedUsername,
    String? encryptedPassword,
  }) async {
    return {
      'username': await decryptValue(encryptedUsername),
      'password': await decryptValue(encryptedPassword),
    };
  }

  /// Hash a password for verification (one-way)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (_key == null || _iv == null) {
      await initialize();
    }
  }

  /// Clear all stored encryption keys (use with caution)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    _key = null;
    _iv = null;
  }

  /// Check if encryption is available
  bool get isInitialized => _key != null && _iv != null;
}
