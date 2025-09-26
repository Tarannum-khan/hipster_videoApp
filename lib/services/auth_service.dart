import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://reqres.in/api';
  static const String _userKey = 'current_user';

  Future<User?> login(String email, String password) async {
    try {
      // Allow any email from user list (and generally any email) with password 123456
      if (password == '123456') {
        final localPart = email.contains('@') ? email.split('@')[0] : email;
        final parts = localPart.split('.');
        String firstName = parts.isNotEmpty && parts[0].isNotEmpty
            ? parts[0][0].toUpperCase() + parts[0].substring(1)
            : 'User';
        String lastName = parts.length > 1 && parts[1].isNotEmpty
            ? parts[1][0].toUpperCase() + parts[1].substring(1)
            : '';
        final sanitizedId = localPart.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
        // Basic avatar selection for known demos; defaults otherwise
        String avatar = 'https://i.pravatar.cc/150?u=$email';
        if (email.toLowerCase() == 'john.doe@test.com') {
          avatar = 'https://i.pravatar.cc/150?img=1';
          firstName = 'John';
          lastName = 'Doe';
        } else if (email.toLowerCase() == 'jane.smith@test.com') {
          avatar = 'https://i.pravatar.cc/150?img=2';
          firstName = 'Jane';
          lastName = 'Smith';
        }

        final user = User(
          id: sanitizedId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          avatar: avatar,
          isOnline: true,
        );
        await _saveUser(user);
        return user;
      }

      // Try with ReqRes API for demo
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Fetch user details
        final userResponse = await http.get(
          Uri.parse('$_baseUrl/users/1'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body)['data'];
          final user = User.fromJson(userData);
          await _saveUser(user);
          return user;
        }
      }

      throw Exception('Invalid credentials');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return User.fromJson(userData);
    }
    
    return null;
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}

