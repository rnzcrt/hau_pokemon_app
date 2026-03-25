// lib/screens/catch_monsters_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';
import '../config/app_config.dart';
import '../models/monster.dart';
import '../services/auth_service.dart';

class CatchMonstersScreen extends StatefulWidget {
  const CatchMonstersScreen({super.key});
  @override
  State<CatchMonstersScreen> createState() => _CatchMonstersScreenState();
}

class _CatchMonstersScreenState extends State<CatchMonstersScreen> {
  Position? _position;
  List _detected     = [];
  bool _scanning     = false;
  String _statusMsg  = 'Press Detect to scan for nearby monsters';
  final _audioPlayer = AudioPlayer();

  // ── Location ──────────────────────────────────────────────────────────────
  Future<bool> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _statusMsg = '⚠️ Location services are disabled.');
      return false;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        setState(() => _statusMsg = '⚠️ Location permission denied.');
        return false;
      }
    }
    if (perm == LocationPermission.deniedForever) {
      setState(
          () => _statusMsg = '⚠️ Location permission permanently denied.');
      return false;
    }
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return true;
  }

  // ── Detect monsters ───────────────────────────────────────────────────────
  Future<void> _detectMonsters() async {
    setState(() {
      _scanning   = true;
      _statusMsg  = '📡 Scanning for monsters…';
      _detected   = [];
    });

    final ok = await _getLocation();
    if (!ok || _position == null) {
      setState(() => _scanning = false);
      return;
    }

    try {
      final token = await AuthService.getToken();
      final res = await http.post(
        Uri.parse(AppConfig.detectMonster),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude':  _position!.latitude,
          'longitude': _position!.longitude,
        }),
      );
      final data = jsonDecode(res.body);
      final detected = data['detected'] ?? [];
      setState(() {
        _detected  = detected;
        _scanning  = false;
        _statusMsg = detected.isEmpty
            ? '🔍 No monsters nearby. Try moving around!'
            : '🚨 Monster detected! Act fast!';
      });
      if (detected.isNotEmpty) await _triggerAlarm();
    } catch (_) {
      setState(() {
        _scanning  = false;
        _statusMsg = '❌ Connection failed. Make sure VPN is ON.';
      });
    }
  }

  // ── Alarm (sound + flashlight) ────────────────────────────────────────────
  Future<void> _triggerAlarm() async {
    // Sound
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (_) {}

    // Flashlight blink ×10
    try {
      for (int i = 0; i < 10; i++) {
        await TorchLight.enableTorch();
        await Future.delayed(const Duration(milliseconds: 250));
        await TorchLight.disableTorch();
        await Future.delayed(const Duration(milliseconds: 250));
      }
    } catch (_) {}
  }

  // ── Catch monster ─────────────────────────────────────────────────────────
  Future<void> _catchMonster(Map monster) async {
    final token = await AuthService.getToken();
    try {
      final res = await http.post(
        Uri.parse(AppConfig.catchMonster),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'monster_id': monster['monster_id'],
          'location_id': 1,
          'latitude':    _position!.latitude,
          'longitude':   _position!.longitude,
        }),
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🎉 ${data['message'] ?? 'Monster caught!'}'),
          backgroundColor: Colors.green,
        ));
        setState(() => _detected.remove(monster));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catch failed. Try again.')));
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── GPS coordinates ──────────────────────────────────────────
          if (_position != null)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.blue),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lat: ${_position!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text('Lng: ${_position!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),

          // ── Detect button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.radar, color: Colors.white),
              label: Text(
                _scanning ? 'Scanning…' : 'Detect Monsters',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: _scanning ? null : _detectMonsters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Status message ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _detected.isNotEmpty
                  ? Colors.red.shade50
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _detected.isNotEmpty
                      ? Colors.red.shade200
                      : Colors.grey.shade300),
            ),
            child: Text(
              _statusMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _detected.isNotEmpty ? Colors.red : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Detected monsters list ────────────────────────────────────
          Expanded(
            child: _detected.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.catching_pokemon,
                            size: 70, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _scanning
                              ? 'Searching…'
                              : 'No monsters nearby',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _detected.length,
                    itemBuilder: (ctx, i) {
                      final m = _detected[i];
                      final emoji =
                          Monster.typeEmoji(m['monster_type'] ?? '');
                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                Colors.red.withOpacity(0.1),
                            child: Text(emoji,
                                style: const TextStyle(
                                    fontSize: 26)),
                          ),
                          title: Text(
                            m['monster_name'] ?? 'Unknown',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${m['monster_type']} monster'),
                              Text(
                                '📍 ${m['distance_meters']}m away',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _catchMonster(m),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: const Text('CATCH!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
