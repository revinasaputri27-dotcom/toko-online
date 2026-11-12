import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import 'api_exception.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<Map<String, dynamic>> login(String email, String password) {
    return _authenticate('/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) {
    return _authenticate('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> _authenticate(
    String path,
    Map<String, String> body,
  ) async {
    final http.Response response;
    try {
      response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Pastikan backend berjalan di port 3000, lalu coba lagi.',
      );
    }
    final decoded = decodeApiResponse(response);
    final data = decoded['data'] as Map<String, dynamic>;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, data['token'] as String);
    await preferences.setString(_userKey, jsonEncode(data['user']));
    return data;
  }

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final userJson = preferences.getString(_userKey);
    if (userJson == null) return null;
    final user = jsonDecode(userJson);
    if (user is! Map<String, dynamic>) {
      throw const FormatException('Data profil tersimpan tidak valid.');
    }
    return user;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_userKey);
  }
}
