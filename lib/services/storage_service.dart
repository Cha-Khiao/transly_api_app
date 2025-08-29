import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _boxName = 'auth_box';
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  late Box _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      if (kDebugMode) {
        print('StorageService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing StorageService: $e');
      }
      rethrow;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _box.put(_tokenKey, token);
      if (kDebugMode) {
        print('Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      rethrow;
    }
  }

  String? getToken() {
    try {
      final token = _box.get(_tokenKey);
      if (kDebugMode) {
        print(
          'Retrieved token: ${token != null ? "Token exists" : "No token found"}',
        );
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _box.delete(_tokenKey);
      if (kDebugMode) {
        print('Token deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting token: $e');
      }
      rethrow;
    }
  }

  bool hasToken() {
    final hasToken = _box.containsKey(_tokenKey);
    if (kDebugMode) {
      print('Has token: $hasToken');
    }
    return hasToken;
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _box.put(_userKey, jsonEncode(userData));
      if (kDebugMode) {
        print('User data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      rethrow;
    }
  }

  Map<String, dynamic>? getUser() {
    try {
      final userJson = _box.get(_userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        if (kDebugMode) {
          print('User data retrieved successfully');
        }
        return userData;
      }
      if (kDebugMode) {
        print('No user data found');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  Future<void> deleteUser() async {
    try {
      await _box.delete(_userKey);
      if (kDebugMode) {
        print('User data deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user data: $e');
      }
      rethrow;
    }
  }

  bool hasUser() {
    final hasUser = _box.containsKey(_userKey);
    if (kDebugMode) {
      print('Has user data: $hasUser');
    }
    return hasUser;
  }

  Future<void> clearAll() async {
    try {
      await _box.clear();
      if (kDebugMode) {
        print('All data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all data: $e');
      }
      rethrow;
    }
  }
}
