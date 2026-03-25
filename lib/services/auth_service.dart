// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  // ── Register ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String playerName,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'player_name': playerName,
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse(AppConfig.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setInt('player_id', data['player_id']);
      await prefs.setString('player_name', data['player_name']);
      await prefs.setString('username', data['username']);
    }
    return data;
  }

  // ── Token helpers ─────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('player_id');
  }

  static Future<String?> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('player_name');
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // ── Logged-in check ───────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
