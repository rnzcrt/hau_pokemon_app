// lib/services/monster_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/monster.dart';
import 'auth_service.dart';

class MonsterService {
  // ── Auth header builder ───────────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── READ all monsters ─────────────────────────────────────────────────────
  static Future<List<Monster>> getAllMonsters() async {
    final res = await http.get(
      Uri.parse(AppConfig.monstersUrl),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    final List raw = data['data'] ?? [];
    return raw.map((e) => Monster.fromJson(e)).toList();
  }

  // ── CREATE monster ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> addMonster(
      Map<String, dynamic> monster) async {
    final res = await http.post(
      Uri.parse(AppConfig.createMonster),
      headers: await _headers(),
      body: jsonEncode(monster),
    );
    return jsonDecode(res.body);
  }

  // ── UPDATE monster ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateMonster(
      Map<String, dynamic> monster) async {
    final res = await http.put(
      Uri.parse(AppConfig.updateMonster),
      headers: await _headers(),
      body: jsonEncode(monster),
    );
    return jsonDecode(res.body);
  }

  // ── DELETE monster ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteMonster(int monsterId) async {
    final res = await http.delete(
      Uri.parse(AppConfig.deleteMonster),
      headers: await _headers(),
      body: jsonEncode({'monster_id': monsterId}),
    );
    return jsonDecode(res.body);
  }
}
