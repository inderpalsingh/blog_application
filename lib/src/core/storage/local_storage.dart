import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      print("💾 TOKEN SAVED SUCCESSFULLY");
      print("   - Key: 'token'");
      print("   - Token preview: ${token.substring(0, min(20, token.length))}...");
      print("   - Full token length: ${token.length} characters");

      // Verify it was actually saved
      final verifiedToken = await getToken();
      if (verifiedToken == token) {
        print("   ✅ TOKEN VERIFICATION: SUCCESS");
      } else {
        print("   ❌ TOKEN VERIFICATION: FAILED");
        print("   - Expected: ${token.substring(0, min(20, token.length))}...");
        print("   - Got: ${verifiedToken != null ? verifiedToken.substring(0, min(20, verifiedToken.length)) : 'NULL'}...");
      }
    } catch (e) {
      print("❌ ERROR SAVING TOKEN: $e");
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      print("💾 TOKEN RETRIEVAL:");
      print("   - Key: 'token'");
      print("   - Found: ${token != null ? 'YES' : 'NO'}");
      if (token != null) {
        print("   - Token preview: ${token.substring(0, min(20, token.length))}...");
        print("   - Full token length: ${token.length} characters");
      } else {
        print("   - Token: NULL");
      }

      return token;
    } catch (e) {
      print("❌ ERROR GETTING TOKEN: $e");
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("refreshToken", token);
      print("💾 REFRESH TOKEN SAVED");
      print("   - Key: 'refreshToken'");
      print("   - Token preview: ${token.substring(0, min(20, token.length))}...");
    } catch (e) {
      print("❌ ERROR SAVING REFRESH TOKEN: $e");
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("refreshToken");
      print("💾 REFRESH TOKEN RETRIEVED: ${token != null ? 'YES' : 'NO'}");
      return token;
    } catch (e) {
      print("❌ ERROR GETTING REFRESH TOKEN: $e");
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = jsonEncode(userJson);
      await prefs.setString("user", userString);
      print("💾 USER SAVED SUCCESSFULLY");
      print("   - Key: 'user'");
      print("   - User ID: ${userJson['id']}");
      print("   - User Name: ${userJson['name']}");
      print("   - User Email: ${userJson['email']}");

      // Verify user was saved
      final verifiedUser = await getUser();
      if (verifiedUser != null && verifiedUser['id'] == userJson['id']) {
        print("   ✅ USER VERIFICATION: SUCCESS");
      } else {
        print("   ❌ USER VERIFICATION: FAILED");
      }
    } catch (e) {
      print("❌ ERROR SAVING USER: $e");
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString("user");

      print("💾 USER RETRIEVAL:");
      print("   - Key: 'user'");
      print("   - Found: ${jsonStr != null ? 'YES' : 'NO'}");

      if (jsonStr == null) {
        print("   - User data: NULL");
        return null;
      }

      final userData = jsonDecode(jsonStr);
      print("   - User ID: ${userData['id']}");
      print("   - User Name: ${userData['name']}");
      print("   - User Email: ${userData['email']}");

      return userData;
    } catch (e) {
      print("❌ ERROR GETTING USER: $e");
      return null;
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("💾 STORAGE CLEARED SUCCESSFULLY");
    } catch (e) {
      print("❌ ERROR CLEARING STORAGE: $e");
    }
  }


  Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      print("💾 TOKEN DELETED SUCCESSFULLY");

      // Verify it was actually deleted
      final verifiedToken = await getToken();
      if (verifiedToken == null) {
        print("   ✅ TOKEN DELETION VERIFICATION: SUCCESS");
      } else {
        print("   ❌ TOKEN DELETION VERIFICATION: FAILED");
      }
    } catch (e) {
      print("❌ ERROR DELETING TOKEN: $e");
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("refreshToken");
      print("💾 REFRESH TOKEN DELETED SUCCESSFULLY");

      // Verify it was actually deleted
      final verifiedRefreshToken = await getRefreshToken();
      if (verifiedRefreshToken == null) {
        print("   ✅ REFRESH TOKEN DELETION VERIFICATION: SUCCESS");
      } else {
        print("   ❌ REFRESH TOKEN DELETION VERIFICATION: FAILED");
      }
    } catch (e) {
      print("❌ ERROR DELETING REFRESH TOKEN: $e");
    }
  }

  Future<void> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("user");
      print("💾 USER DELETED SUCCESSFULLY");

      // Verify it was actually deleted
      final verifiedUser = await getUser();
      if (verifiedUser == null) {
        print("   ✅ USER DELETION VERIFICATION: SUCCESS");
      } else {
        print("   ❌ USER DELETION VERIFICATION: FAILED");
      }
    } catch (e) {
      print("❌ ERROR DELETING USER: $e");
    }
  }

  // Optional: Method to delete all auth-related data at once
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      await deleteRefreshToken();
      await deleteUser();
      print("💾 ALL AUTH DATA CLEARED SUCCESSFULLY");
    } catch (e) {
      print("❌ ERROR CLEARING AUTH DATA: $e");
    }
  }



  // Additional method to check all stored keys (for debugging)
  Future<void> debugPrintAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      print("🔍 ALL STORED KEYS:");
      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          print("   - $key: ${value.length > 50 ? '${value.substring(0, 50)}...' : value}");
        } else {
          print("   - $key: $value");
        }
      }
      if (keys.isEmpty) {
        print("   - No keys found in storage");
      }
    } catch (e) {
      print("❌ ERROR READING STORAGE KEYS: $e");
    }
  }



}
